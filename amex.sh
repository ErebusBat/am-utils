#!/usr/bin/env zsh
ZFILE=$1
if [[ ! -f $ZFILE ]]; then
  echo "***ERROR: File $ZFILE not found"
  exit 1
fi

DNAME=${ZFILE:t:r}
[[ -d $DNAME ]] || mkdir -p $DNAME

7za x -o$DNAME $ZFILE
