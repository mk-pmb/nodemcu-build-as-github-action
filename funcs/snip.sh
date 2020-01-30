#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function snip_run () {
  local CHAPT="$1"; shift
  [ -n "$CHAPT" ] || CHAPT="$*"

  echo
  echo "----- 8< --== $CHAPT ==-- 8< ----- 8< ----- 8< ----- 8< ----- 8< -----"
  "$@"
  local RV=$?
  echo "----- >8 --== $CHAPT (rv=$RV) ==-- >8 ----- >8 ----- >8 ----- >8 -----"
  echo
  return $RV
}


function snip_dump_file () { snip_run "dump $1" nl -ba -- "$1"; }
function snip_oppofunc () { [ "$(type -t "$1")" != func ] || snip_run "$@"; }


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
