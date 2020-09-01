#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function verify_all () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH" || return $?
  local BAGAPATH="${SELFPATH%/*/*}"
  local EOP='export_output_files'
  local ITEM=
  for ITEM in "$EOP" diag snip; do
    source ../../funcs/"$ITEM".sh --lib || return $?
  done
  for ITEM in *.spec.txt; do
    verify_one_spec "$ITEM" || return $?
  done
}


function verify_one_spec () {
  local SPEC="$1"
  echo "=== Verify $EOP spec $(basename -- "$SPEC" .spec.txt) ==="
  local FILES=() DESTS_WANT=()
  readarray -t FILES < <(sed -nrf <(echo '
    /^\s*($|#)/d
    s~:\s*$~: #~
    s~\s+:\s+(\S)~ : \1~p
    ') -- "$SPEC")
  DESTS_WANT=( "${FILES[@]##* : }" )
  FILES=( "${FILES[@]% : *}" )
  local EX_CNT=0
  local OUT_DIR='mock://'
  eval EXPORT_{,SKIP_}CMD='verify_one_mv' rename_output_files || return $?
  [ "$EX_CNT" -ge 1 ] || return 3$(echo "E: No actual destinations." >&2)
  [ "$EX_CNT" == "${#DESTS_WANT[@]}" ] || return 3$(
    echo "E: Mismatch in number of actual vs. expected destinations." >&2)
  echo 'Spec was met.'
  echo
}


function verify_one_mv () {
  local ORIG="$1"; shift
  local DEST="$1"; shift
  local IDX="$EX_CNT"
  (( EX_CNT += 1 ))
  [ "$#" == 0 ] || return 8$(echo "E: unexpected extra args: $*" >&2)
  local WANT="${FILES[$IDX]}"
  [ "$ORIG" == "$WANT" ] || return 2$(echo "E: orig != '$WANT'" >&2)
  WANT="${DESTS_WANT[$IDX]}"
  if [ "$WANT" == '#' ]; then
    [ -z "$DEST" ] && return 0
    echo 'E: dest !~ #*' >&2
    return 2
  fi
  WANT="$OUT_DIR/$WANT"
  if [ "$DEST" == "$WANT" ]; then
    echo 'correct.'
    return 0
  fi
  echo "E: dest '$DEST' != '$WANT'" >&2
  return 2
}










verify_all "$@"; exit $?
