#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function guess_mcu_platform () {
  local PLAT="$(printf '%s\n' \
    [a-z]*/platform/{include/,}cpu_*.h \
    | sed -nre '
      s~\.h$~~
      /\*$/d
      s~^.*/cpu_~\n~
      /^\n/{
        s~^\n~~
        s~_irq$~~
        p
      }
    ' | sort --unique)"
  case "$PLAT" in
    '' )
      echo "E: $FUNCNAME: found no candidates at all." >&2
      return 7;;
    *$'\n'* )
      echo "E: $FUNCNAME: found too many candidates: ${PLAT//$'\n'/, }" >&2
      return 8;;
  esac
  echo "$PLAT"
}










[ "$1" == --lib ] && return 0; guess_mcu_platform "$@"; exit $?
