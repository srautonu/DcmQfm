#!/bin/sh

# it requires 64 bit machine
# usage inputfile outputfile
tmp=`mktemp`

cat $1| xargs -I@ sh -c 'echo -n "@" >'$tmp'; bin/triplets.soda2103 printQuartets '$tmp';'|sed 's/.*: //'| sed 's/^/\(\(/'| sed 's/$/\)\)\;/'| sed 's/ | /\),\(/'| sed 's/ /\,/g'

