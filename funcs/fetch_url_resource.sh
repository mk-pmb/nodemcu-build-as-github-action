#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function fetch_url_resource () {
  local URL="$1"
  local PROTO='^([a-z0-9+-]+):'
  if [[ "$URL" =~ $PROTO ]]; then
    PROTO="${BASH_REMATCH[1]}"
  else
    PROTO='file'
    URL="$PROTO:$URL"
  fi
  if [ "$PROTO" == url ]; then
    URL="${URL#*:}"
    PROTO="${URL%%:*}"
    [ "$PROTO" == "$URL" ] && return 3$(
      echo "E: $FUNCNAME: no protocol in URL" >&2)
  fi
  local SAVE="${URL#*:}"
  SAVE="${SAVE#*:}"
  SAVE="${SAVE#//}"

  local FEXT='\.([A-Za-z0-9]+)(\?|\#|$)'
  if [[ "$URL" =~ $FEXT ]]; then FEXT="${BASH_REMATCH[1]}"; else FEXT=; fi

  case "$PROTO" in
    fwsrc ) echo "$FWSRCDIR/$SAVE"; return 0;;
    luamod )
      [[ "$SAVE" == */* ]] || SAVE+="/$SAVE"
      [[ "$SAVE" == *.* ]] || SAVE+='.lua'
      echo "$FWSRCDIR/lua_modules/$SAVE"; return 0;;
    file )
      case "$SAVE" in
        /* | ./* | ../* ) ;;
        * ) [ -n "$FILE_ROOT" ] && SAVE="${FILE_ROOT%/}/$SAVE";;
      esac
      echo "$SAVE"
      return 0;;
    fw-commit )
      URL="$INPUT_FIRMWARE_REPO"
      URL="${URL%.git}"
      URL="${URL%.git/}"
      URL="${URL%/}"
      URL+="/commit/$SAVE.patch" # GitHub style
      ;;
    * )
      SAVE="$(<<<"$URL" sha1sum --binary | grep -oPe '^\w+')"
      [ -n "$SAVE" ] || return 3$(echo "E: $FUNCNAME: failed to hash URL" >&2)
      SAVE+="$FEXT";;
  esac

  local CACHE_DIR="${INGREDIENTS_REPO_DIR%/}/.cache/$PROTO"
  mkdir --parents -- "$CACHE_DIR"
  SAVE="$CACHE_DIR/$SAVE"

  wget --output-document="$SAVE" -- "$URL" >&2 || return $?
  echo "$SAVE"
}





[ "$1" == --lib ] && return 0; fetch_url_resource "$@"; exit $?
