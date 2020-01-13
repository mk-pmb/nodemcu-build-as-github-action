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
    -path '*/sdk/esp32-esp-idf' -prune ,
    '(' -false
      -o -name '*.bin'
      -o -name '*.map'
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
  local FWSRC="$INPUT_FIRMWARE_SRCDIR"
  snip_ls "$FWSRC"/bin/
  snip_run '' diag_find_output_files md5sum --binary --
  # snip_ls "$FWSRC"/sdk/*-idf/
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












[ "$1" == --lib ] && return 0; "$@"; exit $?
