#!/bin/sh

VERSION="19"
NEXTFREEWORLDID="1578"

MAPSOURCEPATH="/cygdrive/d/src/uesp/EsoApps/EsoMapParse"
ESOINPUTPATH="./esomnf-$VERSION"
GAMEINPUTPATH="./gamemnf-$VERSION"
OUTPUTPATH="./goodimages-$VERSION"
BASEPATH=`realpath ./`

python "$MAPSOURCEPATH/CreateDbStatementForNewMaps.py" "$VERSION" "$BASEPATH/" "$NEXTFREEWORLDID"