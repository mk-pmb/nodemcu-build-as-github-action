#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function prepare_basic_config () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  make_git_rebase_just_work_by_default || return $?
}


function make_git_rebase_just_work_by_default () {
  git config --system user.name 'User Name'
  git config --system user.email 'user@example.net'
}










prepare_basic_config "$@"; exit $?
