#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function move_output_files () {
  local OUT_PFX="$FWDEST_DIR/$INPUT_FIRMWARE_OUTBFN"
  mkdir --parents -- "$(dirname -- "$OUT_PFX")" || return $?
  local FILES=()
  readarray -t FILES < <(diag_find_output_files)

  snip_oppofunc on_before_"$FUNCNAME" || return $?

  local ORIG_FN= DEST_FN= UNKNOWN=
  for ORIG_FN in "${FILES[@]}"; do
    DEST_FN="$(<<<"$ORIG_FN" "$BAGAPATH/funcs/$FUNCNAME.rename.sed")"
    [ "$DEST_FN" == //ignore// ] && continue
    [ -n "$DEST_FN" ] || return 4$(
      echo "E: $FUNCNAME: empty destination filename for '$ORIG_FN'" >&2)
    DEST_FN="${OUT_PFX}${DEST_FN}"
    # echo "$ORIG_FN -> $DEST_FN"
    [ -e "$DEST_FN" ] && return 3$(echo "E: target exists: $DEST_FN" >&2)
    ${MV_CMD:-mv} --verbose --no-target-directory \
      -- "$ORIG_FN" "$DEST_FN" || return $?
  done

  [ -z "$UNKNOWN" ] || return 3$(
    echo "E: unknown potential output file(s): $UNKNOWN" >&2)
  [ -n "$ORIG_FN" ] || return 3$(echo "E: found no output file(s)." >&2)
  snip_ls "$(dirname -- "${OUT_PFX}dummy.filename")" || return $?

  snip_oppofunc on_after_"$FUNCNAME" || return $?
}










[ "$1" == --lib ] && return 0; move_output_files "$@"; exit $?
