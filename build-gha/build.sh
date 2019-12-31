#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local LS='ls --file-type --human-readable --group-directories-first'
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  # cd -- "$SELFPATH" || return $?

  exec &> >( # try to work around an annoying CORS issue on GHA 2019-12-31
    sed -re 's~^~::warning file=build.log,line=0,col=0::~')

  local FWSRC_DIR='/opt/nodemcu-firmware'
  git clone --recurse-submodules \
    --single-branch --branch "$INPUT_FIRMWARE_BRANCH" \
    "$INPUT_FIRMWARE_REPO" "$FWSRC_DIR" || return $?
  cd -- "$FWSRC_DIR" || return $?

  local ITEM=
  for ITEM in app/include/user_*.h; do
    snipdump_file "$ITEM"
  done
}


function snipdump_file () {
  echo
  echo "----- 8< --== $1 ==-- 8< ----- 8< ----- 8< ----- 8< ----- 8< -----"
  nl -ba -- "$1"
  echo "----- >8 --== $1 ==-- >8 ----- >8 ----- >8 ----- >8 ----- >8 -----"
  echo
}










build "$@"; exit $?
