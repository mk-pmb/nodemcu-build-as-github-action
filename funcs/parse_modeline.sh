#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function parse_modeline () {
  grep -m 1 -Pe '^[# \-]+\-\*\-' -- "$@" \
    | sed -re 's!\-\*\-|,!\n!g' | sed -nrf <(echo '
    s~^\s+~~
    s~\s+$~~
    /^[A-Za-z0-9/ :._-]+/{
      /:/!s~$~:~
      s~:\s*~]=\x27~
      s~$~\x27~
      s~^~[~
      p
    }
    ') | sed -re '1s~^~\n~'
}










[ "$1" == --lib ] && return 0; parse_modeline "$@"; exit $?
