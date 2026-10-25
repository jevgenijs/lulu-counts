#!/bin/bash
# build for the simulator and install on both screenshot sims
cd "$(dirname "$0")/.."
xcodebuild build -scheme LuLuCounts -destination "id=B88CE783-2405-4CE6-9FFB-2610FF9C5296" -derivedDataPath build -quiet 2>&1 | grep -E "error|BUILD"
for d in B88CE783-2405-4CE6-9FFB-2610FF9C5296 F11E0F28-9A81-4E50-B9AB-E12FA5DBDA7D; do xcrun simctl install $d build/Build/Products/Debug-iphonesimulator/LuLuCounts.app; done
