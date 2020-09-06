#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function diag_platform () {
  printf 'D: Building on %s (%s "%s") running on a %s CPU as user %s.\n' "$(
    uname --operating-system)" "$(
    lsb_release_or_unknown description)" "$(
    lsb_release_or_unknown codename)" "$(
    uname --machine)" "$(
    whoami)"
}


function lsb_release_or_unknown () {
  lsb_release --short --$1 2>/dev/null || echo "$1=unknown"
}


function find_sorted () {
  find "$@" | sort --version-sort
}


function diag_find_output_files () {
  [ "$*" == scan ] || local FILES=()
  FILES=(
    .
    -path './msvc' -prune ,
    -path './sdk' -prune ,
    -path './sdk-overrides' -prune ,
    '(' -false
      -o -name '*.bin'
      -o -name '*.map'
      -o -path '*/include/user_*.h'
      -o -path '*/include/user_*.ini'
      -o -name 'luac*.*cross*'
      -o -iname 'sdkconfig*'
    ')'
    )
  readarray -t FILES < <(find_sorted "${FILES[@]}")
  FILES=( "${FILES[@]#./}" )
  if [ -z "$*" ]; then
    printf '%s\n' "${FILES[@]}"
    return 0
  fi

  "$@" "${FILES[@]}"
  return $?
}


function debug_status_report_relevant_dirs () {
  snip_ls "$HOME"
  snip_ls "$HOME"/.cache/pip
  snip_ls "$FWSRCDIR"/bin/
  snip_run '' diag_find_output_files md5sum --binary --
  # snip_ls "$FWSRCDIR"/sdk/*-idf/
  snip_ls /opt/lua/
  snip_run '' diag_git_repo
  # snip_run '' diag_git_repo "$BAGAPATH"
  # ^-- useless, Github doesn't even provide the repo dir to the
  #     docker build command.
  snip_ls "$BAGAPATH"
  snip_ls "$BAGAPATH"/funcs
}


function diag_git_repo () {
  git branch --list --verbose
  git status --porcelain
}


function diag_gcc_defines_to_ini () {
  local FMT="$1"; shift
  local SRC=
  for SRC in "$@"; do
    echo "[$SRC]"
    gcc -E -dM "${FMT//%/$SRC}" \
      | sort --version-sort | sed -nre 's~^#define\s+(\S+)\s+~\1 = ~p'
    echo
  done
}












[ "$1" == --lib ] && return 0; "$@"; exit $?
