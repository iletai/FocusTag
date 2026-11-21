#!/usr/bin/env bash
# Runs the UI snapshot test on a 6.9" simulator and exports the raw PNGs to docs/brand/raw/.
# Usage: scripts/capture_screenshots.sh [simulator name, default "iPhone 17 Pro Max"]
set -euo pipefail
cd "$(dirname "$0")/.."

NAME="${1:-iPhone 17 Pro Max}"
UDID=$(xcrun simctl list -j devices available | python3 -c "
import json,sys
for runtime in json.load(sys.stdin)['devices'].values():
    for d in runtime:
        if d['name'] == sys.argv[1]: print(d['udid']); sys.exit()
sys.exit('simulator not found: ' + sys.argv[1])" "$NAME")

xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularMode active --cellularBars 4 --wifiBars 3

rm -rf build/Shots.xcresult build/shots
xcodebuild test -scheme FocusTag-Dev -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath build/DerivedData -resultBundlePath build/Shots.xcresult -quiet \
  -only-testing:FocusTagUITests/SnapshotUITests CODE_SIGNING_ALLOWED=NO

xcrun xcresulttool export attachments --path build/Shots.xcresult --output-path build/shots
mkdir -p docs/brand/raw
python3 - <<'PY'
import json, shutil
for test in json.load(open("build/shots/manifest.json")):
    for a in test["attachments"]:
        name = a["suggestedHumanReadableName"].split("_")[0]
        shutil.copy(f"build/shots/{a['exportedFileName']}", f"docs/brand/raw/{name}.png")
        print("raw:", name)
PY
xcrun simctl status_bar "$UDID" clear
