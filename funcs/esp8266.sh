#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function esp8266_copy_custom_config () {
  local SRC_INCL="${PLAT_INCL_PREFIX}app.include"
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
    cp --verbose --target-directory="$FW_BUILD_DIR" -- "$DEST" || return $?
  done

  esp8266_find_daredefs >/dev/null && BUILD_STRATEGY='esp8266_build_daredefs'

  diag_gcc_defines_to_ini "$DEST_INCL/user_%.h" config modules \
    >"$DEST_INCL"/user_defines.ini || return $?

  snip_run '' esp8266_user_config_checksums md5 || return $?
}




function esp8266_user_config_checksums () {
  local ALGO="$1"
  local FILE=
  for FILE in "$DEST_INCL/user"_*; do
    [ -f "$FILE" ] || continue
    printf '%20s  ' "$FILE"
    "$ALGO"sum --binary -- "$FILE" | grep -oPe '^\w+' || return $?
  done
}


function esp8266_find_daredefs () {
  grep -HonPe '^\s*//dare!\s*#define' "$DEST_INCL"/*.h \
    | head --lines=1 | cut -d : -sf 1-2 | grep .
}


function esp8266_build_daredefs () {
  echo 'Stub!' >&2
  return 3
}













[ "$1" == --lib ] && return 0; esp8266_cli "$@"; exit $?
