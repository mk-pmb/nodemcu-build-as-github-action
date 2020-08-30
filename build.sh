#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  export BAGAPATH="$(readlink -m "$BASH_SOURCE"/..)"
  export INGREDIENTS_REPO_DIR='/github/workspace'
  export ARTIFACTS_BASEDIR="$INGREDIENTS_REPO_DIR"
  # ^-- Path of the uppermost directory that Github's upload action can access.
  export LOGS_DIR="$ARTIFACTS_BASEDIR/logs"

  export FW_BUILD_DIR="$INGREDIENTS_REPO_DIR/output"
  # ^-- Where to unpack the firmware source and then also build it there.

  local RESULTS_DESTDIR="$ARTIFACTS_BASEDIR/${INPUT_RESULTS_DIR#/}"
  RESULTS_DESTDIR="${RESULTS_DESTDIR%/}"
  # ^-- Where to move the files that were produces by the build.
  #     Config should usually designare a subdirectory within this path.


  local LIB=
  for LIB in \
    "$BAGAPATH"/funcs/*.sh \
    "$INGREDIENTS_REPO_DIR"/baga/*.lib.sh \
  ; do
    [ ! -f "$LIB" ] || source "$LIB" --lib || return $?
  done

  local CLI_ACTION="$INPUT_CLI_ACTION"
  if [ -z "$CLI_ACTION" ]; then CLI_ACTION="${1:-buildmgr_ci}"; shift; fi
  snip_oppofunc on_before_cli_action || return $?
  "$CLI_ACTION" "$@" || return $?
  snip_oppofunc on_after_cli_action || return $?
}












build_main "$@"; exit $?
