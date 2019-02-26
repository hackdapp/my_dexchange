#!/bin/bash
figlet "CompileContract"
echo "contract's name: \t $2"

docker exec "$3" /bin/sh -c "rm -rf \$( pwd -P )/compiled_contracts/$2 && mkdir -p \$( pwd -P )/compiled_contracts/$2 && eosio-cpp -abigen \"\$( pwd -P )/contracts/$2/$2.cpp\" -o \"\$( pwd -P )/compiled_contracts/$2/$2.wasm\" --contract \"$2\""
