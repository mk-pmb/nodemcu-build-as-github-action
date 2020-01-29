#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function copy_custom_dotfiles () {
  local SRC= DEST=
  local SRCS=(
    {"$BAGAPATH","$INGREDIENTS_REPO_DIR"}/{,"$MCU_PLATFORM".}dot_files/*
    )
  for SRC in "${SRCS[@]}"; do
    [ -e "$SRC" ] || continue
    DEST="$HOME/.$(basename -- "$SRC")"
    cp --verbose --recursive --no-target-directory \
      -- "$SRC" "$DEST" || return $?
  done
}





[ "$1" == --lib ] && return 0; copy_custom_dotfiles "$@"; exit $?
