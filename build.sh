#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  export BAGAPATH="$(readlink -m "$BASH_SOURCE"/..)"
  local LIB=
  for LIB in "$BAGAPATH"/funcs/*.sh; do source "$LIB" --lib || return $?; done

  export INGREDIENTS_REPO_DIR='/github/workspace'
  export ARTIFACTS_BASEDIR="$INGREDIENTS_REPO_DIR"
  export FWDEST_DIR="$ARTIFACTS_BASEDIR/output"

  local CLI_ACTION="$INPUT_CLI_ACTION"
  if [ -z "$CLI_ACTION" ]; then CLI_ACTION="${1:-build_ci}"; shift; fi
  "$CLI_ACTION" "$@"
  return $?
}












build_main "$@"; exit $?
