#!/bin/sh

BINARY_DIRECTORY=/usr/local/bin/
PROGRAM_NAME=where_is_the_princess

cp -f where_is_the_princess.x86_64 $BINARY_DIRECTORY/${PROGRAM_NAME}
cp -f where_is_the_princess.pck $BINARY_DIRECTORY/${PROGRAM_NAME}.pck
cp -f where_is_the_princess.png /usr/share/pixmaps/${PROGRAM_NAME}.png
cp -f where_is_the_princess.desktop /usr/share/applications/${PROGRAM_NAME}.desktop
chmod u+x /usr/share/applications/${PROGRAM_NAME}.desktop
