#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local LS='ls --file-type --human-readable --group-directories-first'
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  $LS "$RUNNER_WORKSPACE"
}










build "$@"; exit $?
