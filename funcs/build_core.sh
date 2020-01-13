#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function make_or_warn () {
  snip_run '' make "$@" && return 0
  echo "W: Failed to make $* (rv=$?), expect follow-up failures!" >&2
}


function build_core () {
  snip_run '' "$MCU_PLATFORM"_copy_custom_config || return $?

  case "$MCU_PLATFORM" in
    esp32 )
      "$MCU_PLATFORM"_prepare_build || return $?;;
  esac

  IMAGE_NAME='IMAGE_NAME' snip_run '' /opt/build || return $?
  snip_run '' diag_find_output_files
  move_output_files || return $?
}










[ "$1" == --lib ] && return 0; build_core_cli "$@"; exit $?
