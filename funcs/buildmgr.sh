#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function buildmgr_ci () {
  cd -- "$BAGAPATH" || return $?
  exec </dev/null || return $?$(echo "E: Failed to abandon stdin!" >&2)
  exec 2>&1 # because GitHub fails to time-sync stdout and stderr.
  diag_platform || return $?
  ci_import_env || return $?
  mkdir --parents -- "$FWDEST_DIR" || return $?
  mkdir --parents -- "$LOGS_DIR" || return $?

  # Quick stuff first, to fail early if baking would be futile:
  snip_run '' ./util/prepare_basic_config.sh || return $?
  snip_run '' copy_custom_dotfiles || return $?
  fwsrc_clone || return $?

  local MCU_PLATFORM="$(guess_mcu_platform)"
  echo "D: Target platform was guessed as: ${MCU_PLATFORM:-?? unknown ??}"
  [ -n "$MCU_PLATFORM" ] || return 3
  export MCU_PLATFORM

  debug_status_report_relevant_dirs
  buildmgr_commence_fallible
  local BUILD_RV=$?
  echo "##### overall build rv=$BUILD_RV #####"

  [ "$BUILD_RV" == 0 ] || debug_status_report_relevant_dirs
  return "$BUILD_RV"
}


function ci_import_env () {
  local SRC="$INPUT_CI_IMPORT_ENV"
  [ -n "$SRC" ] || return 0
  local PAIRS=()
  [ "${SRC:0:1}" == / ] || SRC="$INGREDIENTS_REPO_DIR/$SRC"
  readarray -t PAIRS <"$SRC" || return $?
  export "${PAIRS[@]}"
}


function make_or_warn () {
  snip_run '' make "$@" && return 0
  echo "W: Failed to make $* (rv=$?), expect follow-up failures!" >&2
}


function apply_user_hotfixes () {
  local HOTFIXES_DIR="$1"; shift
  snip_run "$FUNCNAME $HOTFIXES_DIR" \
    in_dir "$HOTFIXES_DIR" eval "$@" || return $?
}


function buildmgr_commence_fallible () {
  local -A BUILD=()
  local BUILD_STRATEGY="${BUILD_STRATEGY:-run_build_script}"
  local BUILD_SCRIPT_CMD="${INPUT_FIRMWARE_BUILD_CMD:-run_docker_build_script}"
  local BUILD_SCRIPT_CTR=0

  apply_user_hotfixes "$INGREDIENTS_REPO_DIR" \
    "$INPUT_RECIPE_HOTFIX_CMD" || return $?

  snip_oppofunc on_before_custom_config || return $?
  snip_run '' "$MCU_PLATFORM"_copy_custom_config || return $?
  snip_oppofunc on_after_custom_config || return $?

  case "$MCU_PLATFORM" in
    esp32 )
      "$MCU_PLATFORM"_prepare_build || return $?;;
  esac

  snip_oppofunc on_buildchain_ready || return $?
  $BUILD_STRATEGY || return $?
  snip_run '' diag_find_output_files
  move_output_files || return $?
}


function run_docker_build_script () { IMAGE_NAME='IMAGE_NAME' /opt/build; }


function run_build_script () {
  BUILD[rv]='retry'
  while [ "${BUILD[rv]}" == retry ]; do
    (( BUILD_SCRIPT_CTR += 1))
    export BUILD_SCRIPT_CTR
    export BUILD_LOG_FILE="$LOGS_DIR/$(
      printf %03g "$BUILD_SCRIPT_CTR").log"
    snip_oppofunc on_before_"$FUNCNAME" || return $?
    with_log_tee "$BUILD_LOG_FILE" snip_run \
      "build attempt #$BUILD_SCRIPT_CTR" "$BUILD_SCRIPT_CMD"
    BUILD[rv]=$?
    snip_oppofunc on_after_"$FUNCNAME" || return $?
  done
  return "${BUILD[rv]}"
}







[ "$1" == --lib ] && return 0; buildmgr_cli "$@"; exit $?
