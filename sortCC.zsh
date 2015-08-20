#!/usr/bin/env zsh
YEARS=(2008 2009 2010 2011 2012 2013 2014 2015)
# YEARS=(2014)
MONTHS=(01 02 03 04 05 06 07 08 09 10 11 12)

for y in $YEARS; do
  for m in $MONTHS; do
    mask="$y-$m"
    [[ -d $mask ]] || mkdir -p $mask
    mv -v ${mask}-*.csv $mask/ 2> /dev/null
  done
done
