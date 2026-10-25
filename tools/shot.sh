#!/bin/bash
# Screenshot a screen in a simulator: tools/shot.sh <ipad|phone> <name> [launch args...]
# e.g. tools/shot.sh phone lesson -debugRoute lesson:times -debugPage 1
IPAD=F11E0F28-9A81-4E50-B9AB-E12FA5DBDA7D; PHONE=B88CE783-2405-4CE6-9FFB-2610FF9C5296
dev=$([ "$1" = ipad ] && echo $IPAD || echo $PHONE); name=$2; dv=$1; shift 2
out=${SHOT_DIR:-/tmp/claude-501/shots}; mkdir -p $out
xcrun simctl terminate $dev com.vznklabs.lulucounts 2>/dev/null
xcrun simctl launch $dev com.vznklabs.lulucounts "$@" >/dev/null
sleep ${SHOT_WAIT:-1.8}
xcrun simctl io $dev screenshot $out/${dv}_$name.png 2>/dev/null
echo $out/${dv}_$name.png
