# FocusTag — UI State Matrix & Fallback Specifications

> **Platform Ground Truth**: iOS 27 look; Deployment Target: **iOS 18.0+**; iPhone Only.  
> **Source of Truth**: `docs/product/SPEC.md` & `RESEARCH_REPORT.md`.  
> **Core Architecture**: Zero-Server, 100% On-Device (`SwiftData`, `FamilyControls`, `CoreNFC`, `StoreKit 2`).

---

## 1. State Matrix Overview

| Screen | Loading / Skeleton | Empty State (CUV) | Active / Success | Error & Retry | Offline / No-Service |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Dashboard** | Pulse Shimmer Ring & Card Skeletons | No Apps Selected (Prompt to setup Blocklist) | Shield Active / Shield Inactive (Timer ticking) | NFC Scan Timeout / Sensor Glitch | 100% Functional (Local on-device) |
| **2. App Selector** | Native Authorization Shimmer | No apps chosen in `FamilyActivityPicker` | Selection summary cards active | `FamilyControls` Permission Denied Banner | 100% Functional (Local on-device) |
| **3. NFC Pairing** | `NFCNDEFReaderSession` System Modal | No NFC Tag Registered | Tag successfully paired with Green Badge | Tag Read Error / Duplicate Tag Warning | 100% Functional (Local on-device) |
| **4. Emergency Friction**| Accelerometer sensor calibration | N/A (Always starts at 0/100) | Shaking count 1..100 with haptic tick | Motion sensor unauthorized / Suspicious spoof | 100% Functional (Local on-device) |
| **5. Hard Paywall** | StoreKit 2 Products Shimmer Loading | Products unavailable from StoreKit | Subscription active / Trial initiated | Purchase failed / User cancelled / Network error | Cached entitlement / Offline prompt |

---

## 2. Screen-by-Screen Detailed State Specifications

### Screen 1: Active Shield Dashboard

#### A. Loading & Skeleton State
- **Trigger**: App launch while `SwiftData` context is fetching active session and `ManagedSettings` state.
- **Visuals**:
  - Center Timer Ring: Subtle pulsing opacity (`0.3` to `0.7`, duration 1.2s) in `#16181D`.
  - App Blocklist Row: 4 placeholder circular skeletons (48×48pt) with gradient shimmer (`.ftSurface` to `.ftSurfaceElevated`).
  - CTA Button: Skeleton capsule (50pt) with muted glass shimmer.

#### B. Empty State (CUV — Clear User Value)
- **Trigger**: Fresh install after Onboarding where user has not selected any apps to lock.
- **Visuals**:
  - Center Ring: Dashed emerald circle with `plus.shield` icon.
  - Headline: "No Apps Shielded Yet".
  - Subtitle: "Choose the social media apps or games that steal your focus.".
  - Primary CTA (50pt Capsule): "Select Distracting Apps" (`NavigationLink` to Screen 2).

#### C. Active Shield State
- **Visuals**:
  - Center Ring: Glowing Laser Emerald (`#10B981`) ring with live countdown timer.
  - Badge: "SHIELD ACTIVE" capsule with green pulse dot.
  - CTA: "Scan NFC Tag to Unlock" (prominent glass capsule).
  - Secondary: "Emergency Friction Unlock" ghost button.

#### D. Error & Retry State
- **Trigger**: NFC Tag tapped on Dashboard does not match the paired tag UID.
- **Visuals**:
  - Center Ring briefly flashes Crimson Coral (`#F43F5E`) with shake animation (3 cycles).
  - System Alert Toast: "Invalid Tag. Please tap your designated key (e.g., Fridge Tag).".
  - Haptic: Heavy error haptic (`.sensoryFeedback(.error)`).

---

### Screen 2: App Block Selector (`FamilyControls`)

#### A. Authorization Pending / Loading
- **Visuals**: Native Screen Time permission dialog. Backdrop is blurred using Liquid Glass material.
- **Fallbacks**: If FamilyControls initialization takes >1s, display an activity indicator centered inside a 44pt glass circle.

#### B. Permission Denied / Restricted
- **Trigger**: User tapped "Don't Allow" on Screen Time prompt or device has Parental Restrictions.
- **Visuals**:
  - Full-surface glass card with `exclamationmark.shield.fill` icon in Coral (`#F43F5E`).
  - Title: "Screen Time Access Required".
  - Description: "FocusTag relies on Apple Screen Time to lock distracting apps without sending data to servers.".
  - Primary CTA (50pt Capsule): "Open iOS Settings" (linking to `UIApplication.openSettingsURLString`).

#### C. Empty Selection State
- **Trigger**: User opens picker and clears all selected apps.
- **Visuals**:
  - Header displays "0 Apps Selected".
  - Save Button remains disabled (opacity `0.4`, non-interactive) with hint: "Select at least 1 app or category to arm the shield.".

---

### Screen 3: NFC Tag Pairing & Setup

#### A. Ready to Pair (Initial State)
- **Visuals**: Hero illustration of iPhone approaching NFC sticker. 3 clear instructions on Slate cards.
- **CTA**: "Start Scanning NFC Tag" (50pt emerald capsule).

#### B. Active Scanning State
- **Trigger**: User taps CTA.
- **Visuals**: Native Apple `NFCNDEFReaderSession` sheet slides up from screen bottom.
  - Text: "Hold iPhone near the top of your NFC tag...".
  - Animated NFC radio waves displayed by iOS system.

#### C. Tag Paired Success State
- **Trigger**: NFC tag UID read and hashed.
- **Visuals**:
  - System sound & `.sensoryFeedback(.success)`.
  - Glass Card expands showing "Key Registered: Desk NFC Tag".
  - Input Field (34pt): Editable tag nickname with 0.5pt `#232730` border.
  - Primary CTA: "Done & Arm Shield".

#### D. Error States
- **Error 1: Tag Unsupported**: "Unsupported NFC format. Please use standard NDEF tags (NTAG213, NTAG215, or transit cards).".
- **Error 2: Session Timeout**: "Scanning timed out. Bring your phone closer to the tag and try again.".

---

### Screen 4: Emergency Friction Shake

#### A. Challenge In-Progress (0 to 99 Shakes)
- **Trigger**: User initiated emergency unlock without physical NFC tag.
- **Visuals**:
  - Large Monospaced Counter: "68 Shakes Left".
  - Circular Progress Stroke: Crimson Coral fill proportionally tracking `currentShakes / 100.0`.
  - Haptic Feedback: Medium tactile impact on every valid shake (`> 2.2g` acceleration).
  - Cancel Button: "Cancel & Re-Lock" (34pt glass capsule at top).

#### B. Milestone Warning (50 Shakes Reached)
- **Visuals**: Dynamic text banner flashes: "Halfway there! Are you sure you really need this app right now?". Forces a 1-second pause to break the trance.

#### C. Challenge Complete (100 Shakes)
- **Trigger**: 100th valid shake registered.
- **Visuals**:
  - Counter changes to "UNLOCKED FOR 5 MINUTES".
  - Heavy double haptic confirmation.
  - Automatically dismisses `.fullScreenCover` and starts 5-minute countdown on Dashboard.

---

### Screen 5: Hard Paywall (`StoreKit 2`)

#### A. Loading State
- **Trigger**: Fetching products (`focustag_2999_1y`, `focustag_499_1w`, `focustag_4999_lifetime`) via `Product.products(for:)`.
- **Visuals**: Dual card shimmer skeletons matching the 88pt height of pricing cards.

#### B. Purchase In-Progress State
- **Trigger**: User tapped "Start 3-Day Free Trial & Subscribe".
- **Visuals**:
  - CTA button transforms into an active spinner inside the 50pt capsule.
  - Card interaction is disabled.
  - Native Apple Pay sheet presents over the view.

#### C. Purchase Failure / Cancellation
- **Trigger**: User cancels Apple Pay sheet or payment declined.
- **Visuals**:
  - Smooth spring reset of CTA button back to normal text.
  - If card declined: Liquid Glass banner appears at top: "Payment could not be completed. Please update your App Store payment method.".

#### D. Offline State
- **Trigger**: Device is in Airplane Mode or no internet connection during initial paywall load.
- **Visuals**:
  - If previous entitlement exists in `Transaction.currentEntitlements`: Paywall automatically bypasses.
  - If fresh user with no internet: Glass alert banner: "Internet required to connect to App Store. Connect to Wi-Fi to activate free trial.".
