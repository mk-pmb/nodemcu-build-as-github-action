#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local LS='ls --file-type --human-readable --group-directories-first'
  LS+=' --format=long --all'

  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  if [ -f "$INPUT_FIRMWARE_SRCDIR"/Makefile ]; then
    echo "D: Makefile already exists in $INPUT_FIRMWARE_SRCDIR => skip cloning."
  else
    git clone --recurse-submodules \
      --single-branch --branch "$INPUT_FIRMWARE_BRANCH" \
      "$INPUT_FIRMWARE_REPO" "$INPUT_FIRMWARE_SRCDIR" || return $?
  fi
  cd -- "$INPUT_FIRMWARE_SRCDIR" || return $?




  sleep 1s; echo "E: stub!" >&2; return 4
}


function snipdump_file () {
  echo
  echo "----- 8< --== $1 ==-- 8< ----- 8< ----- 8< ----- 8< ----- 8< -----"
  nl -ba -- "$1"
  echo "----- >8 --== $1 ==-- >8 ----- >8 ----- >8 ----- >8 ----- >8 -----"
  echo
}










build "$@"; exit $?
