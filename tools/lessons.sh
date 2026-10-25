#!/bin/bash
# screenshot every lesson page of the given topic ids: tools/lessons.sh phone count add20 ...
cd "$(dirname "$0")/.."
D=$1; shift
for id in "$@"; do
  n=$(grep -c "" /dev/null)
  for pg in 0 1 2 3; do SHOT_WAIT=0.9 tools/shot.sh $D L_${id}_$pg -debugRoute lesson:$id -debugPage $pg >/dev/null; done
done
