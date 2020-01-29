#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function esp8266_copy_custom_config () {
  local SRC_INCL="$INGREDIENTS_REPO_DIR/$MCU_PLATFORM.app.include"
  snip_ls "$SRC_INCL"/ || return $?
  local DEST_INCL="$INPUT_FIRMWARE_SRCDIR/app/include"

  local SRC= BFN= DEST=
  for SRC in "$SRC_INCL"/*.h; do
    [ -f "$SRC" ] || continue
    BFN="$(basename -- "$SRC")"
    DEST="$DEST_INCL/user_$BFN"
    cp --verbose --no-target-directory -- "$SRC" "$DEST" || return $?
  done

  local SED_CMD=()
  for SRC in "$SRC_INCL"/*.sed; do
    [ -f "$SRC" ] || continue
    BFN="$(basename -- "$SRC" .sed).h"
    SED_CMD=()
    [ -x "$SRC" ] || SED_CMD+=( sed -rf )
    SED_CMD+=( "$SRC" )
    DEST="$DEST_INCL/user_$BFN"
    snip_run "${SED_CMD[*]}" "${SED_CMD[@]}" -i -- "$DEST" || return $?
    cp --verbose --target-directory="$FWDEST_DIR" -- "$DEST" || return $?
  done

  snip_run 'user config MD5s' md5sum --binary \
    -- "$INPUT_FIRMWARE_SRCDIR"/app/include/user_* || return $?
}













[ "$1" == --lib ] && return 0; esp8266_cli "$@"; exit $?
