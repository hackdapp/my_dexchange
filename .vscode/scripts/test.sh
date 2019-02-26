#!/bin/bash
echo "testfile's name: \t $1"

node /Users/nolan/Documents/workmeta/exchange4eos/node_modules/.bin/jest -t '' $1 --detectOpenHandles