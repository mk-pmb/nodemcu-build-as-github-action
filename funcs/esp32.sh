#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function esp32_copy_custom_config () {
  local DEST="$INPUT_FIRMWARE_SRCDIR/sdkconfig"
  if [ -f "$DEST" ]; then
    echo "D: $FUNCNAME: skip: target exists: $DEST"
    return 0
  fi

  cp --no-target-directory -- sdkconfig{.defaults,} || return $?
  local RC_DIR="$REPO_DIR/$MCU_PLATFORM.sdkcfg/"
  local SRC= SUB=
  for SRC in "$RC_DIR"[0-9]{,*/}*.rc; do
    [ -f "$SRC" ] || continue
    SUB="${SRC#$RC_DIR}"
    echo
    echo "##### >> $SUB >> #####"
    cat -- "$SRC" || return $?
    echo
    echo "##### << $SUB << #####"
    echo
  done >>"$DEST" || return $?
}











[ "$1" == --lib ] && return 0; esp32_cli "$@"; exit $?
