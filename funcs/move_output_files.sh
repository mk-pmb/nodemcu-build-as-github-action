#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function move_output_files () {
  local OUT_DIR="$RESULTS_DESTDIR"
  mkdir --parents -- "$OUT_DIR" || return $?
  local FILES=()
  readarray -t FILES < <(diag_find_output_files)
  snip_oppofunc on_before_"$FUNCNAME" || return $?
  snip_run '' rename_output_files || return $?
  snip_ls "$OUT_DIR" || return $?
  snip_oppofunc on_after_"$FUNCNAME" || return $?
}


function rename_output_files () {
  local ORIG_FN= FAILS=0
  for ORIG_FN in "${FILES[@]}"; do
    rename_output_files__each "$ORIG_FN" || (( FAILS += 1 ))
  done
  [ -n "$ORIG_FN" ] || return 3$(echo "E: found no output file(s)." >&2)
  [ "$FAILS" == 0 ] || return 3$(echo "E: had $FAILS fails." >&2)

  echo
  echo 'Git status of the results directory:'
  ( cd -- "$OUT_DIR" && git status --porcelain --untracked=all .
  ) | grep . || return 3$(echo "E: No uncommitted changes." >&2)
}


function rename_output_files__each () {
  local ORIG_FN="$1" BAGA_FN= DEST_FN=
  printf "orig: '%s'\t%s" "$ORIG_FN" '-> baga: '
  BAGA_FN="$(<<<"$ORIG_FN" "$BAGAPATH/funcs/move_output_files.rename.sed")"
  printf "'%s'\t%s" "$BAGA_FN" '-> recipe: '
  DEST_FN="$(<<<"$BAGA_FN" sed -rf <(echo "$INPUT_RESULTS_RENAME_SED"))"
  printf "'%s'\t=> " "$DEST_FN"
  case "$DEST_FN" in
    '' )
      echo "E: $FUNCNAME: empty destination filename for '$ORIG_FN'" >&2
      return 3;;
    '#'* )
        echo 'skip.'
      [ -z "$MV_SKIP_CMD" ] || $MV_SKIP_CMD "$ORIG_FN" || return $?
      return 0;;
  esac
  DEST_FN="$OUT_DIR/$DEST_FN"
  [ -e "$DEST_FN" ] && return 3$(echo "E: target exists: $DEST_FN" >&2)
  ${MV_CMD:-mv --verbose --no-target-directory --} \
    "$ORIG_FN" "$DEST_FN" || return $?
}










[ "$1" == --lib ] && return 0; move_output_files "$@"; exit $?
