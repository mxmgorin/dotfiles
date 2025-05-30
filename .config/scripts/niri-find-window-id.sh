#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <window_title>"
  exit 1
fi

TITLE="$1"

windows=$(niri msg windows)

"$windows" | awk -v target="$TITLE" '
  $1 == "Window" && $2 == "ID" {
    id = $3
    gsub(":", "", id)
  }
  $1 == "Title:" {
    match($0, /"[^"]+"/)
    if (RSTART > 0) {
      title = substr($0, RSTART+1, RLENGTH-2)
      if (title == target) {
        print id
        exit
      }
    }
  }
'
