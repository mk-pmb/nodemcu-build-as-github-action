#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function banner () {
  [ -n "$BAGAPATH" ] || export BAGAPATH="$(readlink -m "$BASH_SOURCE"/../..)"
  local BN="$1"; shift
  case "$BN" in
    rv ) if [ "$1" == 0 ]; then BN=ok; else BN=fail; fi;;
  esac
  echo
  sed -ure '/^#/d;s~^~\t~' -- "$BAGAPATH/util/banners/$BN.txt"
  echo
}


[ "$1" == --lib ] && return 0; banner "$@"; exit $?
