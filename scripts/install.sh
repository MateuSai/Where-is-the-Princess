#!/bin/sh

BINARY_DIRECTORY=$HOME/.local/bin/

cp -fr erebus_demo.x86_64 $BINARY_DIRECTORY/erebus_demo.x86_64
cp -fr erebus_demo.pck $BINARY_DIRECTORY/erebus_demo.pck
cp -fr erebus.png $HOME/.icons/erebus.png
cp -fr erebus-demo.desktop $HOME/.local/share/applications/erebus-demo.desktop
chmod u+x $HOME/.local/share/applications/erebus-demo.desktop
