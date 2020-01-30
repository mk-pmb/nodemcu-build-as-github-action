#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  export BAGAPATH="$(readlink -m "$BASH_SOURCE"/..)"
  export INGREDIENTS_REPO_DIR='/github/workspace'
  export ARTIFACTS_BASEDIR="$INGREDIENTS_REPO_DIR"
  export FWDEST_DIR="$ARTIFACTS_BASEDIR/output"
  export LOGS_DIR="$ARTIFACTS_BASEDIR/logs"

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
