#!/usr/bin/env zsh
CCDIR=${0:h}/../CreditCardTransactions
LOGDIR=${0:h}/../logs
if [[ ! -d $CCDIR ]]; then
  echo "*** ERROR: Could not find CC directory: $CCDIR"
  exit 1
fi
if [[ -z $1 ]]; then
  echo "usage: $0 [grep options]"
  exit 1
fi
[[ -d $LOGDIR ]] || mkdir $LOGDIR
if [[ -z $LOG ]]; then
  LOG=$LOGDIR/$1
else
  LOG=$LOGDIR/$LOG
fi
echo "Logging results to $LOG"


grep -Hn $* $CCDIR/**/*.csv | tee $LOG
