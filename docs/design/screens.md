# FocusTag — Screen Inventory & Native Gap Specification

> **Platform Ground Truth**: iOS 27 look; Deployment Target: **iOS 18.0+**; Target Device: **iPhone Only (Portrait)**.  
> **Source of Truth**: `docs/product/SPEC.md`.  
> **Stitch Project**: `projects/2514900579530269948` (Stitch provides visual wireframes; this document establishes the binding layout contract for SwiftUI).

---

## Screen Hierarchy & Navigation Graph

```
[ Root NavigationStack ]
        │
        ├──▶ Screen 1: Active Shield Dashboard (Root)
        │         │
        │         ├──▶ [NavigationLink] ──▶ Screen 2: App Block Selector
        │         │
        │         ├──▶ [Sheet] ───────────▶ Screen 3: NFC Tag Pairing & Setup
        │         │
        │         ├──▶ [FullScreenCover] ─▶ Screen 4: Emergency Friction Unlock (Shake 100)
        │         │
        │         └──▶ [Sheet / Paywall] ─▶ Screen 5: Subscription Hard Paywall
```

---

## Screen 1: Active Shield Dashboard

- **Stitch Screen ID**: `d14bcfb474474a2880d0923720ab91df`
- **Canonical Canvas**: [Stitch Canvas Screen 1](https://stitch.design/projects/2514900579530269948/screens/d14bcfb474474a2880d0923720ab91df)
- **Route**: `DashboardView` (`/dashboard` — Root of `NavigationStack`)
- **Presentation Type**: Root Window

### Layout Architecture & Geometry

```
+-------------------------------------------------------------+  ▲
| Status Bar & Dynamic Island                                 |  │ 62pt Top Safe Area
+-------------------------------------------------------------+  ▼
| [Settings/NFC Pill (34pt)]            [App Selector (34pt)] |  44pt Nav Bar Region
+-------------------------------------------------------------+
|                                                             |
|                   [ SHIELD ACTIVE ]                         |  Hero Capsule Badge (28pt)
|                                                             |
|                        ╭─────╮                              |
|                       │ 01:45 │                             |  Circular Timer Ring (220pt)
|                        ╰─────╯                              |  SF Pro Rounded 56pt
|                 "2 Apps Currently Locked"                   |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [TikTok] [Instagram] [X] [Safari]                     |  |  Locked App Icons Row
|  +-------------------------------------------------------+  |  Card (padding: 16pt, r: 24pt)
|                                                             |
|  [     Scan NFC Tag to Unlock      ]                        |  50pt Primary Capsule CTA
|  [        Emergency Friction Unlock       ]                 |  34pt Ghost Text Button
+-------------------------------------------------------------+  ▲
| Home Indicator Bar Inset                                    |  │ 34pt Bottom Safe Area
+-------------------------------------------------------------+  ▼
```

### Gap Table: Stitch Preview vs. iOS Native HIG

| Element | Stitch Generated Layout | Native SwiftUI / iOS 27 Contract | Rationale & Remediation |
| :--- | :--- | :--- | :--- |
| **Canvas Background** | Hex `#111318` dark grey | Pure OLED Pitch Black (`#000000`) | Battery conservation on OLED + maximum contrast for emerald glow. |
| **Nav Header Bar** | HTML header with non-standard margins | Inset Nav Bar under 62pt Top Safe Area | Respects Dynamic Island hardware cutout; toolbar items use 34pt glass capsules. |
| **Timer Typography** | Geist font 40px | SF Pro Rounded 56pt Heavy Monospaced | `Font.system(size: 56, weight: .heavy, design: .rounded).monospacedDigit()` prevents layout shifting as seconds tick. |
| **NFC Scan CTA** | Rectangular button with 12px border radius | 50pt Capsule Button (`Capsule()`), zero stroke | Mandatory iOS 27 HIG capsule standard; prominent liquid glass style. |
| **Emergency Link** | Underlined hyperlink style | 34pt Subdued Text Button with 44pt touch hit target | Accessibility compliance: Apple minimum touch target is 44×44pt. |

---

## Screen 2: App Block Selector (`FamilyControls` Native Picker)

- **Stitch Screen ID**: `aac999c132fa43ef856f181a1af0e084`
- **Canonical Canvas**: [Stitch Canvas Screen 2](https://stitch.design/projects/2514900579530269948/screens/aac999c132fa43ef856f181a1af0e084)
- **Route**: `AppBlockSelectorView` (`/settings/blocklist`)
- **Presentation Type**: `NavigationLink` push transition

### Layout Architecture & Geometry

```
+-------------------------------------------------------------+  ▲
| Status Bar & Dynamic Island                                 |  │ 62pt Top Safe Area
+-------------------------------------------------------------+  ▼
| [ < (44pt Glass Circle) ]                   [ Done (34pt) ] |  44pt Nav Bar Region
+-------------------------------------------------------------+
| "Block Distracting Apps"                                    |  Headline Lg (28pt)
| "Selected apps will be locked until physical NFC tap"       |  Body Md (15pt Slate)
|                                                             |
| [All] [Social] [Games] [Entertainment]                      |  Category Chip Row (34pt Capsules)
|                                                             |
| +---------------------------------------------------------+ |
| | Native FamilyActivityPicker Container                   | |  Apple Screen Time API
| | (Social Media: 4 selected)                              | |  Embedded List with Glass Rows
| | (Games: 2 selected)                                     | |
| +---------------------------------------------------------+ |
|                                                             |
| +---------------------------------------------------------+ |
| | Strict Mode (Prevent App Deletion)           [ Toggle ] | |  System Toggle Glass Card (r: 24pt)
| +---------------------------------------------------------+ |
|                                                             |
| [               Save Blocklist Configuration              ] |  50pt Pinned Capsule CTA
+-------------------------------------------------------------+  ▲ 34pt Bottom Safe Area
```

### Gap Table: Stitch Preview vs. iOS Native HIG

| Element | Stitch Generated Layout | Native SwiftUI / iOS 27 Contract | Rationale & Remediation |
| :--- | :--- | :--- | :--- |
| **Back Button** | Text "Back" or custom arrow inside card | 44pt Circular Glass Capsule (`.glassEffect(in: .circle)`) | Strictly chevron alone (`chevron.left`); **NO text label**. Standard HIG back button. |
| **App List** | Mocked custom HTML list items | `FamilyActivityPicker(selection: $model.activitySelection)` | Third-party apps **cannot** read raw app bundles. Apple requires native `FamilyActivityPicker` for privacy. |
| **Category Chips** | Square pills with 1px border stroke | 34pt Capsule buttons with zero stroke | Conforms to iOS 27 capsule token. Active chip uses `ftPrimary` tint. |
| **Strict Mode Toggle**| Custom web checkbox | SwiftUI `Toggle` inside Slate Card with haptic feedback | Native switch component respecting system settings & VoiceOver accessibility. |

---

## Screen 3: NFC Tag Pairing & Setup

- **Stitch Screen ID**: `e7cf7e62b01c4277886e4e9ed43082b0`
- **Canonical Canvas**: [Stitch Canvas Screen 3](https://stitch.design/projects/2514900579530269948/screens/e7cf7e62b01c4277886e4e9ed43082b0)
- **Route**: `NFCPairingView` (`/settings/nfc-pairing`)
- **Presentation Type**: Modal `.sheet` presentation with grabber handle

### Layout Architecture & Geometry

```
+-------------------------------------------------------------+
|                           ──────                            |  Sheet Grabber (36×5pt)
| [ Close (44pt Glass Circle) ]                               |  Top Dismiss Bar
|                                                             |
|                     ╭───────────────╮                       |
|                     │   (( 📡 ))    │                       |  NFC Radar Pulse Graphic (180pt)
|                     ╰───────────────╯                       |  Laser Emerald Concentric Rings
|                                                             |
| "Pair Your Physical Key"                                    |  Headline Lg (28pt)
| "Any NFC card or sticker works (bus pass, elevator tag)"    |  Body Md (15pt)
|                                                             |
| +---------------------------------------------------------+ |
| | 1. Place tag away from bed/desk (e.g. Fridge)           | |  3-Step Tactile Guide Card
| | 2. Tap phone to register physical key                   | |  Card Surface: #16181D
| | 3. Walk to tag whenever you need to unlock              | |  Divider: 0.5pt #232730
| +---------------------------------------------------------+ |
|                                                             |
| [                 Start Scanning NFC Tag                  ] |  50pt Primary Capsule CTA
+-------------------------------------------------------------+  ▲ 34pt Bottom Safe Area
```

### Gap Table: Stitch Preview vs. iOS Native HIG

| Element | Stitch Generated Layout | Native SwiftUI / iOS 27 Contract | Rationale & Remediation |
| :--- | :--- | :--- | :--- |
| **Scanning HUD** | In-page simulated loading spinner | Native `NFCNDEFReaderSession` System Sheet | iOS displays an uncustomizable Apple-managed bottom sheet with antenna wave animation during NFC read. |
| **Illustration** | Static raster illustration | Vector SF Symbol (`wave.3.forward.circle.fill`) + SwiftUI Canvas pulse | Scalable across all iPhone screen sizes without pixel distortion. |
| **Tag Name Field** | Web `<input>` with box outline | 34pt Native `TextField` with 0.5pt `#232730` border | Native keyboard auto-focus with clear button (`.clearButtonMode = .whileEditing`). |
| **CTA Button** | Full width 44px box button | 50pt Capsule Button, zero stroke | High-prominence glass styling with wave icon. |

---

## Screen 4: Emergency Friction Shake (100 Shakes Challenge)

- **Stitch Screen ID**: `3b062b93a0a648808a60aef8748e3d49`
- **Canonical Canvas**: [Stitch Canvas Screen 4](https://stitch.design/projects/2514900579530269948/screens/3b062b93a0a648808a60aef8748e3d49)
- **Route**: `EmergencyFrictionView` (`/emergency-unlock`)
- **Presentation Type**: `.fullScreenCover` (Immersive lock, impossible to swipe dismiss)

### Layout Architecture & Geometry

```
+-------------------------------------------------------------+  ▲
| Status Bar & Dynamic Island                                 |  │ 62pt Top Safe Area
+-------------------------------------------------------------+  ▼
| [ Cancel & Re-Lock (34pt Capsule) ]                         |  Top Navigation Bar
|                                                             |
|                   [ EMERGENCY UNLOCK: 5 MIN ]               |  Hazard Pill Badge (Crimson Coral)
|                                                             |
|                     ╭───────────────╮                       |
|                     │      68       │                       |  Shake Counter Hero Ring (200pt)
|                     │  SHAKES LEFT  │                       |  SF Pro Rounded 64pt Monospace
|                     ╰───────────────╯                       |  Progress Stroke 8pt Coral
|                                                             |
| "Vigorously shake your phone to prove urgency"              |  Headline Sm (20pt)
| "This physical barrier interrupts subconscious scrolling."  |  Body Md (15pt Slate)
|                                                             |
| +---------------------------------------------------------+ |
| | Linear Progress Bar: 32% Completed                      | |  Progress Indicator
| +---------------------------------------------------------+ |
|                                                             |
| [            Keep Phone Locked (I Don't Need It)          ] |  50pt Secondary Capsule CTA
+-------------------------------------------------------------+  ▲ 34pt Bottom Safe Area
```

### Gap Table: Stitch Preview vs. iOS Native HIG

| Element | Stitch Generated Layout | Native SwiftUI / iOS 27 Contract | Rationale & Remediation |
| :--- | :--- | :--- | :--- |
| **Dismiss Behavior** | Standard modal with swipe-down gesture | `.interactiveDismissDisabled(true)` | Users must not easily dismiss an emergency lock. Escape requires pressing "Cancel & Re-Lock". |
| **Motion Tracking** | Fake clickable button counting shakes | `CoreMotion` (`CMMotionManager`) Acceleration Vector | Requires real physical movement (`|accel| > 2.2g` threshold) to defeat unconscious dopamine loop. |
| **Counter Feedback** | Static text updates | Dynamic spring animation + Medium Haptic pulse per shake | Heavy tactile confirmation on every shake; heavy success buzz at 100. |
| **Accent Hue** | Neutral amber | Crimson Coral (`#F43F5E`) | Danger/hazard semantic signaling: warns user that emergency unlocks are discouraged. |

---

## Screen 5: Hard Paywall (Subscription & Lifetime)

- **Stitch Screen ID**: `160cc537bb1b4271b1fdf42675acdb45`
- **Canonical Canvas**: [Stitch Canvas Screen 5](https://stitch.design/projects/2514900579530269948/screens/160cc537bb1b4271b1fdf42675acdb45)
- **Route**: `PaywallView` (`/paywall`)
- **Presentation Type**: Modal `.sheet` (Post-Onboarding) or `fullScreenCover`

### Layout Architecture & Geometry

```
+-------------------------------------------------------------+  ▲
| Status Bar & Dynamic Island                                 |  │ 62pt Top Safe Area
+-------------------------------------------------------------+  ▼
| [ (x) Close (44pt Glass Circle) ]     [ Restore Purchases ] |  44pt Nav Bar Region
+-------------------------------------------------------------+
| "Take back your focus"                                      |  Display Lg (34pt Bold)
| "The only screen time blocker you cannot bypass in bed."    |  Body Md (15pt Slate)
|                                                             |
| +---------------------------------------------------------+ |
| | ✓ Unbreakable NFC physical lock                         | |  Value Proposition Checklist
| | ✓ Unlimited NFC card registrations                      | |  4 rows with Emerald Checkmarks
| | ✓ Zero data collection, 100% on-device privacy          | |
| +---------------------------------------------------------+ |
|                                                             |
| +---------------------------------------------------------+ |
| | [ BEST VALUE - 88% OFF ]                                | |  Card A: Annual $29.99/yr
| | Annual Subscription: $29.99/yr ($2.49/mo)               | |  3-Day Free Trial Included
| | [ Selected Indicator Radio ]                            | |  Active Border: 1.5pt Emerald
| +---------------------------------------------------------+ |
|                                                             |
| +---------------------------------------------------------+ |
| | Weekly Plan: $4.99 / week                               | |  Card B: Weekly $4.99/wk
| +---------------------------------------------------------+ |
|                                                             |
| [       Start 3-Day Free Trial & Subscribe        ]         |  50pt Primary Capsule CTA
|                                                             |
| "Lifetime Access available for $49.99"                      |  Small Monospace Text Link
| "Cancel anytime in App Store Settings. Terms & Privacy"     |  10pt Legal Footer
+-------------------------------------------------------------+  ▲ 34pt Bottom Safe Area
```

### Gap Table: Stitch Preview vs. iOS Native HIG

| Element | Stitch Generated Layout | Native SwiftUI / iOS 27 Contract | Rationale & Remediation |
| :--- | :--- | :--- | :--- |
| **Pricing Data** | Hardcoded text strings | Native `StoreKit 2` (`Product.displayPrice`) | Apple Review Guideline 3.1.2 mandates localized pricing fetched directly from App Store Connect. |
| **Close Button** | Small web "x" icon | 44pt Circular Glass Capsule (`.glassEffect(in: .circle)`) | HIG compliant touch target; delayed appearance (2.0s) for Onboarding compliance. |
| **Trial Toggle** | Static badge | Dynamic trial terms disclaimer based on App Store receipt | Complies with Apple StoreKit guidelines regarding trial terms clarity. |
| **Restore Purchases**| Buried in footer | Top-right toolbar capsule button (34pt) | High-visibility placement prevents App Store review rejection. |
