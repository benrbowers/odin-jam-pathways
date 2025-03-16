#!/bin/bash -eu

OUT_DIR="build/desktop"
mkdir -p $OUT_DIR
odin build src/desktop -out:$OUT_DIR/hyperlines.bin -collection:src=./src
cp -R ./sprites/ ./$OUT_DIR/sprites/
echo "Desktop build created in ${OUT_DIR}"