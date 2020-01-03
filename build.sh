#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local LS='ls --file-type --human-readable --group-directories-first'
  LS+=' --format=long --all'

  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  local REPO_DIR='/github/workspace'
  local ARTIFACTS_BASEDIR="$REPO_DIR"
  local FWDEST_DIR="$ARTIFACTS_BASEDIR/output"
  mkdir --parents "$FWDEST_DIR" || return $?

  if [ -f "$INPUT_FIRMWARE_SRCDIR"/Makefile ]; then
    echo "D: Makefile already exists in $INPUT_FIRMWARE_SRCDIR => skip cloning."
  else
    git clone --recurse-submodules \
      --single-branch --branch "$INPUT_FIRMWARE_BRANCH" \
      "$INPUT_FIRMWARE_REPO" "$INPUT_FIRMWARE_SRCDIR" || return $?
  fi
  cd -- "$INPUT_FIRMWARE_SRCDIR" || return $?

  snip_ls "$INPUT_FIRMWARE_SRCDIR"/bin/
  snip_ls /opt/lua/

  build_core
  local CORE_RV=$?

  snip_ls "$INPUT_FIRMWARE_SRCDIR"/bin/
  snip_ls /opt/lua/
  snip_ls "$FWDEST_DIR"

  return "$CORE_RV"
}


function build_core () {
  copy_custom_user_headers || return $?
  IMAGE_NAME='IMAGE_NAME' /opt/build || return $?
  move_output_files || return $?
}


function copy_custom_user_headers () {
  local SRC= BFN= DEST=
  for SRC in /github/workspace/app.include/*.h; do
    [ -f "$SRC" ] || continue
    BFN="$(basename -- "$SRC")"
    DEST="$INPUT_FIRMWARE_SRCDIR/app/include/user_$BFN"
    cp --verbose --no-target-directory -- "$SRC" "$DEST" || return $?
  done
  snip_run 'user config MD5s' md5sum --binary \
    -- "$INPUT_FIRMWARE_SRCDIR"/app/include/user_*
}


function snip_run () {
  local CHAPT="$1"; shift
  echo
  echo "----- 8< --== $CHAPT ==-- 8< ----- 8< ----- 8< ----- 8< ----- 8< -----"
  "$@"
  local RV=$?
  echo "----- >8 --== $CHAPT (rv=$RV) ==-- >8 ----- >8 ----- >8 ----- >8 -----"
  echo
  return $RV
}


function snip_dump_file () { snip_run "dump $1" nl -ba -- "$1"; }
function snip_ls () { snip_run "ls $*" $LS "$@"; }


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
