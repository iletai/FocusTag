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

---

## License

Copyright (c) 2026 Le Quang Trong Tai. All rights reserved.

This repository is proprietary and source-available for viewing only.
No permission is granted to use, copy, modify, distribute, or create
derivative works from this code without prior written permission.
See [LICENSE](LICENSE) for the full terms.
