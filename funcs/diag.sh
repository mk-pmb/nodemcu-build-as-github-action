#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function diag_platform () {
  printf 'D: Building on %s (%s "%s") running on a %s CPU.\n' "$(
    uname --operating-system)" "$(
    lsb_release_or_unknown description)" "$(
    lsb_release_or_unknown codename)" "$(
    uname --machine)"
}


function lsb_release_or_unknown () {
  lsb_release --short --$1 2>/dev/null || echo "$1=unknown"
}


function find_sorted () {
  find "$@" | sort --version-sort
}


function diag_find_output_files () {
  find_sorted -name '*.bin' -o -name '*.map'
}


function debug_status_report_relevant_dirs () {
  local FWSRC="$INPUT_FIRMWARE_SRCDIR"
  snip_ls "$FWSRC"/bin/
  snip_run '' diag_find_output_files
  # snip_ls "$FWSRC"/sdk/*-idf/
  snip_ls /opt/lua/
  snip_run '' git status --porcelain
}












[ "$1" == --lib ] && return 0; "$@"; exit $?
