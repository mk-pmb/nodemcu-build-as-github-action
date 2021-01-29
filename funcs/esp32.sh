#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function esp32_copy_custom_config () {
  local DEST="$FWSRCDIR/sdkconfig"
  if [ -f "$DEST" ]; then
    echo "D: $FUNCNAME: skip: target exists: $DEST"
    return 0
  fi

  cp --no-target-directory -- sdkconfig{.defaults,} || return $?
  local RC_DIR="${PLAT_INCL_PREFIX}sdkcfg/"
  snip_ls "$RC_DIR" || return $?
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

  # SRC="$FWSRCDIR/build/include/sdkconfig.h"
  # diag_gcc_defines_to_ini "$SRC" '' >"${SRC%.h}.ini" || return $?
}


function esp32_prepare_build () {
  echo "pip home ls:"
  snip_ls -d "$HOME"{,.cache{,pip}}
  snip_run '' python -m pip install --upgrade \
    setuptools \
    || return $?
  grep -qPe '^install_toolchain:\s' Makefile \
    || echo 'install_toolchain: $(ESP32_GCC)' >>Makefile \
    || return $?
  snip_run '' python -m pip install --user --requirement \
    sdk/esp32-esp-idf/requirements.txt
  make_or_warn install_toolchain
  make_or_warn defconfig
}











[ "$1" == --lib ] && return 0; esp32_cli "$@"; exit $?
