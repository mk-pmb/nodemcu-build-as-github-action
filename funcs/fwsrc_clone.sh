#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function fwsrc_clone () {
  if [ -f "$FWSRCDIR"/Makefile ]; then
    echo "D: Makefile already exists in $FWSRCDIR => skip cloning."
  else
    git clone --single-branch --branch "$INPUT_FIRMWARE_BRANCH" \
      "$INPUT_FIRMWARE_REPO" "$FWSRCDIR" || return $?
  fi
  cd -- "$FWSRCDIR" || return $?
  [ -z "$INPUT_FIRMWARE_GIT_RESET" ] \
    || snip_run '' git reset --hard "$INPUT_FIRMWARE_GIT_RESET" || return $?
  snip_run '' git submodule init || return $?
  snip_run '' git submodule update --recursive || return $?

  echo -n "D: Firmware repo is at branch $(
    git branch | sed -nre 's~^\* ~~p' || echo '(no branch?)'
    ), commit ";
  git log --format=oneline --abbrev-commit --max-count=15 | sed -re '
    1b
    s~^~   ~
    2s~^~Recent history:\n~
    s~^|\n~&D: ~g
    '

  snip_run "Apply recipe's custom patches to firmware" \
    with_spaceword_args "$INPUT_FIRMWARE_APPLY_PATCHES" \
    apply_git_patches || return $?

  snip_run "Apply recipe's custom hotfixes to firmware" \
    eval "$INPUT_FIRMWARE_HOTFIX_CMD" || return $?

  fwsrc_clone__liccmp || return $?
}


function fwsrc_clone__liccmp () {
  local CMP="$INPUT_FIRMWARE_VERIFY_LICENSE"
  case "$CMP" in
    '' ) return 0;;
    *' = '* ) ;;
    * ) CMP="LICENSE = $CMP";;
  esac
  local SRC='/dev/null'
  case "$CMP" in
    *' = '* ) SRC="${CMP% = *}"; CMP="${CMP##* = }";;
  esac
  [ "${SRC:0:1}" == / ] || SRC="$FWSRCDIR/$SRC"
  [ "${CMP:0:1}" == / ] || CMP="$INGREDIENTS_REPO_DIR/$CMP"
  diff -sU 9009009 -- "$SRC" "$CMP" || return $?
}










[ "$1" == --lib ] && return 0; fwsrc_clone "$@"; exit $?
