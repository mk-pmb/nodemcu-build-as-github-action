#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function in_dir () {
  pushd -- "$1" >/dev/null || return $?
  shift
  "$@"
  local RV=$?
  popd >/dev/null || return $?
  return $?
}




[ "$1" == --lib ] && return 0; in_dir "$@"; exit $?
