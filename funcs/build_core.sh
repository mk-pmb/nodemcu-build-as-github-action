#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_ci () {
  cd -- "$BAGAPATH" || return $?
  exec </dev/null || return $?$(echo "E: Failed to abandon stdin!" >&2)
  exec 2>&1 # because GitHub fails to time-sync stdout and stderr.
  diag_platform || return $?

  # Quick stuff first, to fail early if baking would be futile:
  mkdir --parents -- "$FWDEST_DIR" || return $?
  snip_run '' copy_custom_dotfiles || return $?
  fwsrc_clone || return $?

  local MCU_PLATFORM="$(guess_mcu_platform)"
  echo "D: Target platform was guessed as: ${MCU_PLATFORM:-?? unknown ??}"
  [ -n "$MCU_PLATFORM" ] || return 3
  export MCU_PLATFORM

  debug_status_report_relevant_dirs
  build_core
  local CORE_RV=$?
  echo "##### build core rv=$CORE_RV #####"

  [ "$CORE_RV" == 0 ] || debug_status_report_relevant_dirs
  return "$CORE_RV"
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


function build_core () {
  apply_user_hotfixes "$INGREDIENTS_REPO_DIR" \
    "$INPUT_RECIPE_HOTFIX_CMD" || return $?

  snip_run '' "$MCU_PLATFORM"_copy_custom_config || return $?

  case "$MCU_PLATFORM" in
    esp32 )
      "$MCU_PLATFORM"_prepare_build || return $?;;
  esac

  IMAGE_NAME='IMAGE_NAME' snip_run '' /opt/build || return $?
  snip_run '' diag_find_output_files
  move_output_files || return $?
}










[ "$1" == --lib ] && return 0; build_core_cli "$@"; exit $?
