#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function prepare_and_build_all_lfs_images () {
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
    echo -n "  * "
    IMG_BN="${IMG_BN%/}"
    build_one_prepared_lfs_image "$IMG_BN" "$OUT_DIR/" || return $?
    (( CNT += 1 ))
  done
  echo "Done packing $CNT LFS images."
}


function build_one_prepared_lfs_image () {
  local IMG_BN="$1"; shift
  local DEST="$1"; shift
  case "$DEST" in
    '' | */ ) DEST+="$IMG_BN.lfs";;
  esac
  [ "${DEST:0:1}" == / ] || DEST="$PWD/$DEST"
  local FILES=()
  echo -n "$IMG_BN.lfs <- $IMG_BN/**.{lc,lua}: "
  readarray -t FILES < <(find "$IMG_BN/" -mindepth 1 '(' -false \
    -o -name '*.lc' \
    -o -name '*.lua' \
    ')' | cut -d / -f 2- | LANG=C sort --version-sort)
  if [ -z "${FILES[*]}" ]; then
    echo 'found no files.'
    continue
  fi
  in_dir "$IMG_BN" "${LUAC:-luac-for-nodemcu}" -f -o "$DEST" \
    -- "${FILES[@]}" || return $?$(echo "E: luac failed, rv=$?" >&2)
  du --human-readable --apparent-size -- "$DEST" | grep -oPe '^\S+'
}





[ "$1" == --lib ] && return 0; build_lfs_image  "$@"; exit $?
