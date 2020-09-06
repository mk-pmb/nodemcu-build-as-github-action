#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function buildmgr_ci () {
  cd -- "$BAGAPATH" || return $?
  exec </dev/null || return $?$(echo "E: Failed to abandon stdin!" >&2)
  exec 2>&1 # because GitHub fails to time-sync stdout and stderr.
  diag_platform || return $?
  ci_import_env || return $?
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
  banner rv "$BUILD_RV"
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

  snip_run buildmgr_early_cleanup || return $?

  snip_oppofunc on_before_custom_config || return $?
  local PLAT_INCL_PREFIX="$INGREDIENTS_REPO_DIR/$MCU_PLATFORM."
  snip_run '' "$MCU_PLATFORM"_copy_custom_config || return $?
  snip_oppofunc on_after_custom_config || return $?

  case "$MCU_PLATFORM" in
    esp32 )
      "$MCU_PLATFORM"_prepare_build || return $?;;
  esac

  snip_oppofunc on_buildchain_ready || return $?
  $BUILD_STRATEGY || return $?
  export_output_files || return $?
}


function buildmgr_early_cleanup () {
  # Let's clean up early to ensure the build isn't accidentially
  # contaminated. This has to be done before other build preparations,
  # because the latter may create files that will be needed by the
  # actual build, so cleaning up later would potentially sabotage them.
  make $INPUT_BUILD_CUSTOM_MAKE_OPTS clean
}


function run_docker_build_script () {
  local MAKE_OPT="$INPUT_BUILD_CUSTOM_MAKE_OPTS"
  local GHA_TGT="$INPUT_BUILD_CUSTOM_MAKE_TARGETS"
  local MAKE_TGT="$BUILD_MAKE_TARGETS"
  if [ -n "$MAKE_TGT" ]; then
    [ -z "$GHA_TGT" ] || return 3$(
      echo "E: Build targets cannot be set in both env and GHA config." >&2)
  else
    MAKE_TGT="$GHA_TGT"
  fi
  [ -n "$MAKE_TGT" ] || MAKE_TGT='all'  # no clean! see buildmgr_early_cleanup

  local BCMD=(
    env
    IMAGE_NAME="${IMAGE_NAME:-IMAGE_NAME}"
    BUILD_MAKE_TARGETS="$MAKE_OPT $MAKE_TGT"
    /opt/build
    )
  echo "D: effective build command:$(printf ' ‹%s›' "${BCMD[@]}")"
  "${BCMD[@]}" || return $?
}


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


function buildmgr_plain_copy_dir_if_exists () {
  local SRC="$1"; shift
  local DEST="$1"; shift
  if [ -z "$DEST" ]; then
    DEST="$SRC"
    SRC="${DEST//\//.}"
  fi
  SRC="${PLAT_INCL_PREFIX}$SRC"
  if [ ! -d "$SRC" ]; then
    echo "D: Not a directory: $SRC"
    return 0
  fi
  snip_ls "$SRC/" || true
  cp --verbose --recursive --no-target-directory \
    -- "$SRC/" "$FWSRCDIR/$DEST/" || return $?
}







[ "$1" == --lib ] && return 0; buildmgr_cli "$@"; exit $?
