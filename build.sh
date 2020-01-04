#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  exec </dev/null || return $?$(echo "E: Failed to abandon stdin!" >&2)
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?
  local LIB=
  for LIB in funcs/*.sh; do source "$LIB" --lib || return $?; done

  diag_platform || return $?

  local RECIPE_REPO_DIR='/github/workspace'
  snip_run '' copy_custom_dotfiles || return $?

  local ARTIFACTS_BASEDIR="$RECIPE_REPO_DIR"
  local FWDEST_DIR="$ARTIFACTS_BASEDIR/output"
  mkdir --parents "$FWDEST_DIR" || return $?
  fwsrc_clone || return $?

  local MCU_PLATFORM="$(guess_mcu_platform)"
  echo "D: Target platform was guessed as: ${MCU_PLATFORM:-?? unknown ??}"
  [ -n "$MCU_PLATFORM" ] || return 3

  debug_status_report_relevant_dirs
  build_core
  local CORE_RV=$?
  echo "##### build core rv=$CORE_RV #####"

  [ "$CORE_RV" == 0 ] || debug_status_report_relevant_dirs
  return "$CORE_RV"
}




function move_output_files () {
  local MAP_ORIG=( "$INPUT_FIRMWARE_SRCDIR"/bin/nodemcu[_-]*.map )
  local MAP_CNT="${#MAP_ORIG[@]}"
  [ "$MAP_CNT" == 1 ] || return 5$(
    echo "E: build created an unexpected number of output files:" \
      "expected 1 but found $MAP_CNT" >&2)
  local BFN="${MAP_ORIG[0]%.map}"
  local FEXT=
  for FEXT in bin map; do
    mv --verbose --no-target-directory \
      -- "$BFN.$FEXT" "$FWDEST_DIR/$INPUT_FIRMWARE_OUTBFN.$FEXT" || return $?
  done
}












build_main "$@"; exit $?
