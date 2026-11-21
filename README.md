# FocusTag

> Physical Friction Screen Time & Habit Lock for iOS.

Stop doomscrolling with physical reality. Lock distracting apps and require a physical NFC tap (or a 100-shake motion challenge) to unlock.

## Architecture & Specifications
- **Product Spec & Screen Inventory:** [`docs/product/SPEC.md`](docs/product/SPEC.md)
- **Deep Research Report:** [`RESEARCH_REPORT.md`](RESEARCH_REPORT.md)
- **Scaffold Environment:** [`.env.scaffold`](.env.scaffold)
- **Handoff Documentation:** [`docs/HANDOFF.md`](docs/HANDOFF.md)
- **Fastlane Metadata:** `fastlane/metadata/`

## Setup & Scaffolding
```bash
source .env.scaffold
APPLE_TEAM_ID="$APPLE_TEAM_ID" ~/.agents/skills/ios-new-app/scripts/new_app.sh "$APP_NAME" "$BUNDLE_ID" ~/Developer/"$APP_NAME" --with "$FEATURES"
```
