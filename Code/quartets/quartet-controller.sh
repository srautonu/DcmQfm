#!/bin/sh

sh quartet_count.sh $1 | perl summarize_quartets_stdin.pl > $2
