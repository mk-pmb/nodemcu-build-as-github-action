#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function snip_run () {
  local CHAPT="$1"; shift
  [ -n "$CHAPT" ] || CHAPT="$*"

  local REDIR_STDOUT='/dev/stdout'
  if [ "${1:0:1}" == '>' ]; then
    REDIR_STDOUT="${1:1}"
    shift
  fi

  echo
  echo "----- 8< --== $CHAPT ==-- 8< ----- 8< ----- 8< ----- 8< ----- 8< -----"
  "$@" >"$REDIR_STDOUT"
  local RV=$?
  echo "----- >8 --== $CHAPT (rv=$RV) ==-- >8 ----- >8 ----- >8 ----- >8 -----"
  echo
  return $RV
}


function snip_dump_file () { snip_run "dump $1" nl -ba -- "$1"; }


function snip_ls () {
  local LS_OPT=(
    --file-type
    --human-readable
    --group-directories-first
    --format=long
    --all
    )
  snip_run "ls $*" ls "${LS_OPT[@]}" "$@"
}






[ "$1" == --lib ] && return 0; snip_run "$@"; exit $?
