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
  local BULLET='  * ' IMG_BN= DEST= CNT=0
  for IMG_BN in [A-Za-z0-9]*/; do
    [ -d "$IMG_BN" ] || continue
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

  in_dir "$IMG_BN" build_lfs_image__import_all_external_files || return $?

  local FILES=()
  echo -n "${BULLET}$IMG_BN.lfs <- $IMG_BN/**.{lc,lua}: "
  readarray -t FILES < <(find "$IMG_BN/" -mindepth 1 '(' -false \
    -o -name '*.lc' \
    -o -name '*.lua' \
    ')' | cut -d / -f 2- | LANG=C sort --version-sort)
  if [ -z "${FILES[*]}" ]; then
    echo 'found no files.'
    continue
  fi
  readarray -t FILES < <(in_dir "$IMG_BN" build_lfs_image__check_file_opts \
    "${FILES[@]}") || return $?
  if [ -z "${FILES[*]}" ]; then
    echo 'Found some LUA files but all of them are exempted.'
    continue
  fi
  in_dir "$IMG_BN" "${LUAC:-luac-for-nodemcu}" -f -o "$DEST" \
    -- "${FILES[@]}" || return $?$(echo "E: luac failed, rv=$?" >&2)
  echo -n '    LFS size: '
  du --human-readable --apparent-size -- "$DEST" | grep -oPe '^\S+'
}


function build_lfs_image__check_file_opts () {
  local SRC=
  local -A OPT=()
  for SRC in "$@"; do
    case "$SRC" in
      *.lua ) ;;
      * ) echo "$SRC"; continue;;
    esac
    OPT=()
    eval "OPT=( $(parse_modeline "$SRC") )"
    case "${OPT[lfs]}" in
      '' ) ;;
      no )
        # echo "D: $SRC: skip by modeline" >&2
        continue;;
      * )
        echo "E: $SRC: unsupported setting for modeline option lfs." >&2
        return 3;;
    esac
    echo "$SRC"
  done
}


function build_lfs_image__import_all_external_files () {
  local FILE='externals.txt'
  local SPECS=()
  [ -f "$FILE" ] || return 0
  readarray -t SPECS < <(sed -rf <(echo '
    s~\r~~g
    s~\s+~ ~g
    /^ *(#|$)/d
    ') -- "$FILE") || return $?
  local N_SPECS="${#SPECS[@]}"
  echo "${BULLET}Import $N_SPECS external files for $IMG_BN.lfs:"
  local SPEC= LINK=
  for SPEC in "${SPECS[@]}"; do
    echo -n "    * Import '$SPEC': "
    LINK="${SPEC%% = *}"
    LINK="${LINK##*[:/]}"
    [[ "$LINK" == *.* ]] || LINK+='.lua'
    SPEC="${SPEC#* = }"
    FILE="$(fetch_url_resource "$SPEC")" || return $?
    [ -n "$FILE" ] || return 3$(echo "E: unsupported URL format" >&2)
    [ ! -L "$LINK" ] || rm --one-file-system -- "$LINK" || true
    ln --verbose --symbolic --no-target-directory \
      -- "$FILE" "$LINK" || return $?
  done
}





















[ "$1" == --lib ] && return 0; build_lfs_image  "$@"; exit $?
