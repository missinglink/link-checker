#!/bin/sh

echo "-------------------------------------"
echo "[Watching & Compiling Coffee Scripts]"
echo "-------------------------------------"

[ -d build ] || mkdir build
node node_modules/jitter/bin/jitter src build