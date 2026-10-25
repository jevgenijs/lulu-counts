#!/bin/bash
# tools/batch.sh  -> the standard set of screenshots for review (phone)
cd "$(dirname "$0")/.."
D=${1:-phone}
tools/shot.sh $D lesson_add20 -debugRoute lesson:add20 -debugPage 1 >/dev/null
tools/shot.sh $D lesson_neg -debugRoute lesson:negatives -debugPage 2 >/dev/null
tools/shot.sh $D lesson_times -debugRoute lesson:times -debugPage 1 >/dev/null
tools/shot.sh $D prac_times -debugRoute practice:times -debugLevel 2 -debugSeed 3 >/dev/null
tools/shot.sh $D prac_add -debugRoute practice:add20 -debugLevel 1 -debugSeed 4 >/dev/null
tools/shot.sh $D prac_wrong -debugRoute practice:add20 -debugLevel 1 -debugSeed 4 -debugWrong 1 >/dev/null
tools/shot.sh $D prac_clock -debugRoute practice:clock -debugLevel 3 -debugSeed 12 >/dev/null
tools/shot.sh $D result -debugRoute practice:times -debugAnswers 8 -debugSeed 3 >/dev/null
