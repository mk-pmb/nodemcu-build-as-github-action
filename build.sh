#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function build_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local LS='ls --file-type --human-readable --group-directories-first'
  LS+=' --format=long --all'
  local QUOT='"' APOS="'"

  exec </dev/null || return $?$(echo "E: Failed to abandon stdin!" >&2)

  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?

  echo "D: Building on" \
    "$(uname --operating-system ) OS"\
    "($(lsb_release_or_unknown description) $QUOT$(
      lsb_release_or_unknown codename)$QUOT)" \
    "running on a $(uname --machine) CPU."

  local REPO_DIR='/github/workspace'
  snip_run '' copy_custom_dotfiles || return $?

  local ARTIFACTS_BASEDIR="$REPO_DIR"
  local FWDEST_DIR="$ARTIFACTS_BASEDIR/output"
  mkdir --parents "$FWDEST_DIR" || return $?

  if [ -f "$INPUT_FIRMWARE_SRCDIR"/Makefile ]; then
    echo "D: Makefile already exists in $INPUT_FIRMWARE_SRCDIR => skip cloning."
  else
    git clone --single-branch --branch "$INPUT_FIRMWARE_BRANCH" \
      "$INPUT_FIRMWARE_REPO" "$INPUT_FIRMWARE_SRCDIR" || return $?
  fi
  cd -- "$INPUT_FIRMWARE_SRCDIR" || return $?
  [ -z "$INPUT_FIRMWARE_GIT_RESET" ] \
    || snip_run '' git reset --hard "$INPUT_FIRMWARE_GIT_RESET" || return $?
  snip_run '' git submodule init || return $?
  snip_run '' git submodule update --recursive || return $?

  echo -n "D: Firmware repo is at branch $(
    git branch | sed -nre 's~^\* ~~p' || echo '(no branch?)'
    ), commit ";
  git log --format=oneline --abbrev-commit --max-count=15 | sed -re '
    1b
    s~^~   ~
    2s~^~Recent history:\n~
    s~^|\n~&D: ~g
    '
  local MCU_PLATFORM="$(guess_mcu_platform)"
  echo "D: Target platform was guessed as: ${MCU_PLATFORM:-?? unknown ??}"
  [ -n "$MCU_PLATFORM" ] || return 3

  debug_status_report_relevant_dirs
  build_core
  local CORE_RV=$?
  echo "##### build core rv=$CORE_RV #####"

  [ "$CORE_RV" == 0 ] || debug_status_report_relevant_dirs
  return "$CORE_RV"
}


function lsb_release_or_unknown () {
  lsb_release --short --$1 2>/dev/null || echo "$1=unknown"
}


function copy_custom_dotfiles () {
  local SRC= DEST=
  for SRC in {"$SELFPATH","$REPO_DIR"}/{,"$MCU_PLATFORM".}dot_files/*; do
    [ -e "$SRC" ] || continue
    DEST="$HOME/.$(basename -- "$SRC")"
    cp --verbose --recursive --no-target-directory \
      -- "$SRC" "$DEST" || return $?
  done
}


function guess_mcu_platform () {
  local PLAT="$(printf '%s\n' \
    [a-z]*/platform/{include/,}cpu_*.h \
    | sed -nre '
      s~\.h$~~
      /\*$/d
      s~^.*/cpu_~~p
    ')"
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


function debug_status_report_relevant_dirs () {
  local FWSRC="$INPUT_FIRMWARE_SRCDIR"
  snip_ls "$FWSRC"/bin/
  snip_run '' find "$FWSRC"/b*/ -name '*.bin'
  # snip_ls "$FWSRC"/sdk/*-idf/
  snip_ls /opt/lua/
}


function make_or_warn () {
  snip_run '' make "$@" && return 0
  echo "W: Failed to make $* (rv=$?), expect follow-up failures!" >&2
}


function build_core () {
  snip_run '' "$MCU_PLATFORM"_copy_custom_config || return $?

  case "$MCU_PLATFORM" in
    esp32 )
      grep -qPe '^install_toolchain:\s' Makefile \
        || echo 'install_toolchain: $(ESP32_GCC)' >>Makefile \
        || return $?
      snip_run '' python -m pip install --user --requirement \
        sdk/esp32-esp-idf/requirements.txt
      make_or_warn install_toolchain
      make_or_warn defconfig
      ;;
  esac

  IMAGE_NAME='IMAGE_NAME' snip_run '' /opt/build || return $?
  move_output_files || return $?
}


function esp8266_copy_custom_config () {
  local SRC= BFN= DEST=
  for SRC in "$REPO_DIR/$MCU_PLATFORM.app.include"/*.h; do
    [ -f "$SRC" ] || continue
    BFN="$(basename -- "$SRC")"
    DEST="$INPUT_FIRMWARE_SRCDIR/app/include/user_$BFN"
    cp --verbose --no-target-directory -- "$SRC" "$DEST" || return $?
  done
  snip_run 'user config MD5s' md5sum --binary \
    -- "$INPUT_FIRMWARE_SRCDIR"/app/include/user_* || return $?
}


function esp32_copy_custom_config () {
  local DEST="$INPUT_FIRMWARE_SRCDIR/sdkconfig"
  if [ -f "$DEST" ]; then
    echo "D: $FUNCNAME: skip: target exists: $DEST"
    return 0
  fi

  cp --no-target-directory -- sdkconfig{.defaults,} || return $?
  local RC_DIR="$REPO_DIR/$MCU_PLATFORM.sdkcfg/"
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
}


function snip_run () {
  local CHAPT="$1"; shift
  [ -n "$CHAPT" ] || CHAPT="$*"
  echo
  echo "----- 8< --== $CHAPT ==-- 8< ----- 8< ----- 8< ----- 8< ----- 8< -----"
  "$@"
  local RV=$?
  echo "----- >8 --== $CHAPT (rv=$RV) ==-- >8 ----- >8 ----- >8 ----- >8 -----"
  echo
  return $RV
}


function snip_dump_file () { snip_run "dump $1" nl -ba -- "$1"; }
function snip_ls () { snip_run "ls $*" $LS "$@"; }


function move_output_files () {
  local MAP_ORIG=( "$INPUT_FIRMWARE_SRCDIR"/bin/nodemcu[_-]*.map )
  local MAP_CNT="${#MAP_ORIG[@]}"
  [ "$MAP_CNT" == 1 ] || return 5$(
    echo "E: build created an unexpected number of output files:" \
      "expected 1 but found $MAP_CNT" >&2)
  local BFN="${MAP_ORIG[0]%.map}"
  local FEXT=
  for FEXT in bin map; do
    mv --verbose --no-target-directory \
      -- "$BFN.$FEXT" "$FWDEST_DIR/$INPUT_FIRMWARE_OUTBFN.$FEXT" || return $?
  done
}












build_main "$@"; exit $?
