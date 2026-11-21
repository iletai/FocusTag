# FocusTag — iOS Design System & SwiftUI Specification

> **Platform Ground Truth**: iOS 27 look & feel; Deployment Target: **iOS 18.0+**; Target Device: **iPhone Only (Portrait)**.  
> **Source of Truth**: `docs/product/SPEC.md` & `RESEARCH_REPORT.md`.  
> **Rendering Reference**: Google Stitch Project `2514900579530269948` (Stitch is a preview canvas; this spec governs production code).

---

## 1. Aesthetic & Design Philosophy

FocusTag embodies **Tactile High-Tech Minimalism** paired with **Stealth-Luxury Instrumentation**:
1. **OLED Dark-First Precision**: An uncompromising deep pitch black (`#000000`) canvas engineered for battery conservation and optical immersion during deep focus sessions.
2. **Tactile Physical Friction**: Visual cues reflect physical density and tactile resistance. When the screen is locked, the interface communicates structural immutability through high-contrast borders and razor-sharp accents.
3. **Liquid Glass Optics**: System bars, toolbars, sheets, interactive badges, and buttons adopt dynamic optical refraction via SwiftUI `glassEffect` with fluid backdrop blur, responsive surface highlights, and real-time touch feedback.
4. **Zero-Cognitive Clutter**: Every pixel serves focus. Secondary information is subdued into slate-tinted typography, reserving high-luminance laser emerald strictly for active protection.

---

## 2. Color Palette Roles & Semantic Hierarchy

All colors conform strictly to WCAG 2.2 Level AAA contrast (> 7:1 for normal text against pitch black surfaces).

```
+-------------------------------------------------------------------------+
| CANVAS: True Black #000000 (OLED Pitch Black)                          |
|  +-------------------------------------------------------------------+  |
|  | SURFACE CONTAINER: Slate Deep #16181D (Cards / Groups)            |  |
|  |   BORDER: Structural Precision #232730 (0.5pt subtle outline)     |  |
|  |   PRIMARY ACCENT: Laser Emerald #10B981 / #4EDEA3 (Active Shield) |  |
|  |   HAZARD ACCENT: Crimson Coral #F43F5E / #FFB4AB (Friction/Locked) |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### Semantic Token Table

| Token Name | Light Mode Value | Dark Mode Value (Default) | Role & Usage | Contrast vs Background |
| :--- | :--- | :--- | :--- | :--- |
| `ftBackground` | `#F8F9FA` | `#000000` | Root view background canvas (OLED True Black) | — |
| `ftSurface` | `#FFFFFF` | `#16181D` | Primary card containers, list sections, glass plates | 12.8:1 |
| `ftSurfaceElevated` | `#F1F3F5` | `#1C2027` | Floating modals, toolbars, bottom action sheet panels | 14.1:1 |
| `ftBorderSubtle` | `rgba(0,0,0,0.08)` | `#232730` | 0.5pt structural card outlines and divider rules | N/A (Shape) |
| `ftPrimary` (Emerald) | `#059669` | `#10B981` | Active Shield badge, confirmed NFC paired, Primary CTAs | 7.9:1 |
| `ftPrimaryGlow` | `rgba(5,150,105,0.25)` | `rgba(16,185,129,0.30)` | Radial glow effect behind Shield ring & NFC illustration | Decorative |
| `ftHazard` (Coral) | `#E11D48` | `#F43F5E` | Emergency Shake challenge, locked warning, destructive actions | 7.2:1 |
| `ftTextPrimary` | `#0F172A` | `#E2E2E9` | Main titles, timer digits, status headlines | 15.6:1 |
| `ftTextSecondary` | `#475569` | `#94A3B8` | Subtitles, descriptive instructions, card labels | 8.2:1 |
| `ftTextTertiary` | `#94A3B8` | `#64748B` | Footers, disabled timestamps, legal disclosures | 4.8:1 |

---

## 3. Typography & Dynamic Type Tokens

The typographic system leverages **San Francisco Pro** (`-apple-system`) native font families.
- **SF Pro Rounded**: Exclusively reserved for numerical timers, shake counts, percentage progress, and status badges to inject a technical, tactile instrument character.
- **SF Pro Text / Display**: Applied to all navigational headlines, body descriptions, and action labels for optimal native legibility.

### Typographic Token Specs

| Token Name | Font Style / Family | Size (pt) | Weight | Line Height | Tracking | Dynamic Type Style |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `ftDisplayLg` | SF Pro Rounded | 40 pt | Bold (700) | 48 pt | -0.03em | `.largeTitle` |
| `ftTimerDisplay`| SF Pro Rounded (Monospaced Digits)| 56 pt | Heavy (800)| 64 pt | -0.04em | Custom (`.system(size: 56, design: .rounded).monospacedDigit()`) |
| `ftHeadlineLg`| SF Pro Display | 28 pt | Semibold (600)| 34 pt | -0.02em | `.title` |
| `ftHeadlineSm`| SF Pro Text | 20 pt | Semibold (600)| 26 pt | -0.015em| `.title3` |
| `ftBodyLg` | SF Pro Text | 17 pt | Regular (400)| 24 pt | -0.01em | `.body` |
| `ftBodyMd` | SF Pro Text | 15 pt | Regular (400)| 21 pt | -0.005em| `.subheadline` |
| `ftLabelMd` | SF Pro Rounded (Monospaced) | 12 pt | Medium (500)| 16 pt | +0.02em | `.footnote` |
| `ftLabelSm` | SF Pro Rounded (Monospaced) | 10 pt | Bold (700) | 14 pt | +0.05em | `.caption2` |

> [!IMPORTANT]
> All labels and body text MUST adopt native SwiftUI `ScaledMetric` or standard system text styles to preserve user-configured Dynamic Type and Accessibility text scaling up to Accessibility XXXL.

---

## 4. Spacing, Geometry & Layout Tokens

The layout strictly obeys an **8pt modular spatial grid** (with 4pt half-step for micro-insets).

### Spatial Tokens

| Token | Dimension (pt) | Typical Application |
| :--- | :--- | :--- |
| `spacing-xxs` | 2 pt | Hairline indicator spacing, badge dot offsets |
| `spacing-xs` | 4 pt | Text-to-sublabel spacing, icon-to-badge gaps |
| `spacing-sm` | 8 pt | Card internal gap, icon-to-title horizontal spacing |
| `spacing-md` | 16 pt | Screen horizontal gutter (compact), card stack vertical gaps |
| `spacing-lg` | 24 pt | Screen standard margins, hero card internal padding |
| `spacing-xl` | 32 pt | Section-to-section vertical separation |
| `spacing-xxl` | 48 pt | Hero graphic to content separation |

### iOS Standard Geometry Matrix

| Metric Parameter | Value (pt) | Specification Rule |
| :--- | :--- | :--- |
| **Top Safe Area** | **62 pt** | Dynamic Island & status bar clearance on modern iPhones |
| **Bottom Safe Area** | **34 pt** | Home Indicator bar clearance |
| **Navigation Bar Height** | **44 pt** | Placed directly beneath top safe area |
| **Back Button Component**| **44 pt × 44 pt** | Standalone chevron icon centered inside a 44pt circular glass capsule (`.glassEffect(in: .circle)`). **Never display back title**. |
| **Primary CTA Button** | **50 pt height** | Full-width or inset capsule (`.capsule`), zero stroke border |
| **Regular Button** | **34 pt height** | Auxiliary buttons, category chips (`.capsule`), zero stroke border |
| **Text Fields** | **34 pt height** | Rounded text fields with exact `0.5pt` border stroke (`#232730`) |

### Target iPhone Canvas Resolutions (Portrait)

| Device Generation | Viewport Points (pt) | Native Pixels (px) | Scale Factor |
| :--- | :--- | :--- | :--- |
| **iPhone 17 / 18 Pro** | **402 × 874 pt** | 1206 × 2622 px | @3x |
| **iPhone 18 Pro Max** | **440 × 956 pt** | 1320 × 2868 px | @3x |
| **iPhone Air** | **420 × 912 pt** | 1260 × 2736 px | @3x |
| **iPhone 17e** | **390 × 844 pt** | 1170 × 2532 px | @3x |
| **iPhone 16** | **393 × 852 pt** | 1179 × 2556 px | @3x |

---

## 5. Component Specifications

### 5.1 Liquid Glass Implementation (iOS 18+ to iOS 27)

Liquid Glass is mandatory on system navigation bars, toolbars, modal bottom sheets, search overlays, and interactive tactile plates.

```swift
// Production Liquid Glass Modifier Pattern
struct FTLiquidGlassModifier: ViewModifier {
    var tintColor: Color? = nil
    var isInteractive: Bool = false
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(
                    .regular
                        .tint(tintColor ?? .clear)
                        .interactive(isInteractive),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
}
```

### 5.2 Capsule Buttons (50pt Large & 34pt Regular)

Apple HIG strictly mandates borderless capsules for high-priority actions in iOS 27.

1. **Large CTA Capsule (50pt)**:
   - Frame: `height = 50 pt`, `maxWidth = .infinity`.
   - Shape: Native `Capsule()`.
   - Style: Prominent Glass (`.buttonStyle(.glassProminent)`) or solid `ftPrimary` gradient.
   - Border: **Zero stroke** (no outline).
   - Label: 17pt SF Pro Text Semibold, centered, with integrated SF Symbol (e.g. `wave.3.right.circle.fill`).
2. **Regular Action Capsule (34pt)**:
   - Frame: `height = 34 pt`, padding `horizontal = 16 pt`.
   - Shape: `Capsule()`.
   - Style: Interactive glass (`.buttonStyle(.glass)`).
   - Border: **Zero stroke**.

### 5.3 Standalone Back Navigation Capsule

- **Hit Target**: 44 pt × 44 pt circular touch area.
- **Visual Appearance**: `Image(systemName: "chevron.left")` with 17pt font weight medium.
- **Background**: `.glassEffect(.regular.interactive(), in: .circle)`.
- **Title**: Strict compliance — **NO back title text** (clean Apple native minimalism).

### 5.4 Glass Cards & Containers

- **Corner Radius**: 24 pt continuous rounded corners.
- **Surface Fill**: `#16181D` (Slate Deep) with subtle radial backdrop blur.
- **Border Stroke**: Exact `0.5pt` solid stroke using `#232730`.
- **Inner Padding**: 20 pt vertical, 20 pt horizontal.

---

## 6. SwiftUI Mapping Table

| Design System Token / Component | Figma / Stitch Concept | SwiftUI API / ViewModifier (iOS 18+ & iOS 26+) |
| :--- | :--- | :--- |
| **Canvas Background** | Pitch Black `#000000` | `.background(Color.black.ignoresSafeArea())` |
| **Card Surface** | Slate Card `#16181D` | `.background(Color(hex: 0x16181D), in: .rect(cornerRadius: 24))` |
| **Card Border** | Precision Line `#232730` | `.overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: 0x232730), lineWidth: 0.5))` |
| **Primary Liquid Glass** | Translucent Blur Panel | `.modifier(FTLiquidGlassModifier(tintColor: .emerald, isInteractive: false))` |
| **Interactive Glass Button** | Glass Pill Button | `.buttonStyle(.glass)` or `.glassEffect(.regular.interactive(), in: .capsule)` |
| **50pt CTA Capsule** | Big Primary Button | `Button(...) { }.frame(height: 50).buttonStyle(FTPrimaryCapsuleStyle())` |
| **34pt Chip Capsule** | Quick Filter Pill | `Button(...) { }.frame(height: 34).buttonStyle(FTChipCapsuleStyle())` |
| **Circular Back Button** | 44pt Back Chevron | `Button(action: dismiss) { Image(systemName: "chevron.left") }.frame(width: 44, height: 44).glassEffect(in: .circle)` |
| **Timer Display Font** | Monospaced Numeric | `.font(.system(size: 56, weight: .heavy, design: .rounded)).monospacedDigit()` |
| **Section Header Font** | Title 3 Semibold | `.font(.system(size: 20, weight: .semibold, design: .default))` |
| **Haptic Feedback** | Tactile Touch Response | `.sensoryFeedback(.impact(weight: .heavy), trigger: isUnlocked)` |
| **Native App Picker** | App Block List | `FamilyActivityPicker(headerText: ..., selection: $selection)` |
| **Native NFC Scanner** | NFC Reader Sheet | `NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)` |
