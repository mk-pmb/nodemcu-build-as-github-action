#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function export_output_files () {
  local FILES=( "$PWD"/luac.cross* )
  local LUAC="${FILES[*]}"
  [ -x "$LUAC" ] || return 3$(echo "E: not executable: $LUAC" >&2)
  ln --symbolic --verbose --target-directory=/usr/local/bin \
    -- "$LUAC" || return $?

  local OUT_DIR="$RESULTS_DESTDIR"
  mkdir --parents -- "$OUT_DIR" || return $?
  in_dir --if-exists "${PLAT_INCL_PREFIX}lfs" \
    snip_run '' build_lfs_image || return $?

  FILES=()
  readarray -t FILES < <(diag_find_output_files)
  snip_oppofunc on_before_"$FUNCNAME" || return $?
  snip_run '' copy_renamed_output_files || return $?
  snip_ls "$OUT_DIR" || return $?
  snip_oppofunc on_after_"$FUNCNAME" || return $?
}


function copy_renamed_output_files () {
  local ORIG_FN= FAILS=0
  for ORIG_FN in "${FILES[@]}"; do
    copy_renamed_output_files__each "$ORIG_FN" || (( FAILS += 1 ))
  done
  [ -n "$ORIG_FN" ] || return 3$(echo "E: found no output file(s)." >&2)
  [ "$FAILS" == 0 ] || return 3$(echo "E: had $FAILS fails." >&2)

  [ "$OUT_DIR" == 'mock://' ] && return 0
  echo
  echo 'Git status of the results directory:'
  ( cd -- "$OUT_DIR" && git status --porcelain --untracked=all .
  ) | grep . || return 3$(echo "E: No uncommitted changes." >&2)
}


function copy_renamed_output_files__each () {
  local ORIG_FN="$1" BAGA_FN= DEST_FN=
  printf "orig: '%s'\t%s" "$ORIG_FN" '-> baga: '
  BAGA_FN="$(<<<"$ORIG_FN" "$BAGAPATH/funcs/rename_output_files.sed")"
  printf "'%s'\t%s" "$BAGA_FN" '-> recipe: '
  DEST_FN="$(<<<"$BAGA_FN" sed -rf <(echo "$INPUT_RESULTS_RENAME_SED"))"
  printf "'%s'\t=> " "$DEST_FN"
  case "$DEST_FN" in
    '' )
      echo "E: $FUNCNAME: empty destination filename for '$ORIG_FN'" >&2
      return 3;;
    '#'* )
        echo 'skip.'
      [ -z "$EXPORT_SKIP_CMD" ] || $EXPORT_SKIP_CMD "$ORIG_FN" || return $?
      return 0;;
  esac
  DEST_FN="$OUT_DIR/$DEST_FN"
  [ -e "$DEST_FN" ] && return 3$(echo "E: target exists: $DEST_FN" >&2)
  ${EXPORT_CMD:-cp --verbose --no-target-directory --} \
    "$ORIG_FN" "$DEST_FN" || return $?
}


function build_lfs_image () {
  local FILES=()
  local PREP='_prepare.sh'
  if [ -f "$PREP" ]; then
    chmod a+x -- "$PREP"
    echo -n "Run $PREP: "
    ./"$PREP" --prepare || return $?$(echo "E: $PREPfailed, rv=$?" >&2)
    echo "done."
  else
    echo "D: not a file: $PREP"
  fi

  echo "Packing LFS images:"
  local IMG_BN= DEST= CNT=0
  for IMG_BN in [A-Za-z0-9]*/; do
    [ -d "$IMG_BN" ] || continue
    IMG_BN="${IMG_BN%/}"
    DEST="$OUT_DIR/$IMG_BN.lfs"
    echo -n "  * $IMG_BN.lfs <- $IMG_BN/**.{lc,lua}: "
    readarray -t FILES < <(find "$IMG_BN/" -mindepth 1 '(' -false \
      -o -name '*.lc' \
      -o -name '*.lua' \
      ')' | cut -d / -f 2- | LANG=C sort --version-sort)
    if [ -z "${FILES[*]}" ]; then
      echo 'found no files.'
      continue
    fi
    in_dir "$IMG_BN" "$LUAC" -f -o "$DEST" -- "${FILES[@]}" || return $?$(
      echo "E: luac failed, rv=$?" >&2)
    du --human-readable --apparent-size -- "$DEST" | grep -oPe '^\S+'
    (( CNT += 1 ))
  done
  echo "Done packing $CNT LFS images."
}














[ "$1" == --lib ] && return 0; export_output_files "$@"; exit $?
