#!/bin/bash

$ORACLE_BASE/runOracle.sh

# echo "The following output is now a tail of the alert.log:"
tail -f $ORACLE_BASE/diag/rdbms/*/*/trace/alert*.log &
childPID=$!
wait $childPID