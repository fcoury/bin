#!/bin/bash

SCRIPT=$(basename $0)
SCRIPT_PATH=$(pwd)
LINK_TARGET="$HOME/.local/bin"

mkdir -p "$LINK_TARGET"

# Takes a path argument and returns it as an absolute path.
# No-op if the path is already absolute.
function to-abs-path {
  local target="$1"

  if [ "$target" == "." ]; then
    echo "$(pwd)"
  elif [ "$target" == ".." ]; then
    echo "$(dirname "$(pwd)")"
  else
    echo "$(
      cd "$(dirname "$1")"
      pwd
    )/$(basename "$1")"
  fi
}

link-path() {
  cd "$1"
  for f in "$1"/*; do
    if [ "$f" != "./$SCRIPT" ]; then
      SOURCE=$(to-abs-path $f)
      TARGET="${LINK_TARGET}/$1/$f"
      TARGET="$(echo "$TARGET" | gsed -r 's|\.\/||g')"
      if [ -f "${f}/.link" ]; then
        LINK_NAME=$(cat "${f}/.link")
        TARGET="${LINK_TARGET}/${LINK_NAME}"
      fi
      if [ -e "$TARGET" ]; then
        echo Skipping: $SOURCE
      else
        echo "Linking: $SOURCE -> $TARGET"
        ln -s "$SOURCE" "$TARGET"
      fi
    fi
  done
}

link-path "."
