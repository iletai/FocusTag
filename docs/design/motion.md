# FocusTag — Motion & Haptic Physics Specification

> **Platform Ground Truth**: iOS 27 look; Deployment Target: **iOS 18.0+**; iPhone Only.  
> **Source of Truth**: `docs/product/SPEC.md` & `RESEARCH_REPORT.md`.  
> **Core Theme**: Tactile Instrumentation & Physical Resistance Physics.

---

## 1. Motion Principles

1. **Physical Resistance & Weight**: Animations must communicate mechanical friction and intentional resistance. Transitions are neither floaty nor whimsical; they feel like precision instruments and physical locks snapping into place.
2. **Spring Physics Over Easing**: Every view transition uses Apple native spring curves (`response` and `dampingRatio`) calibrated to mimic physical spring tension.
3. **Multi-Sensory Alignment**: Visual pulses are strictly synchronised with tactile haptic pulses (`UIImpactFeedbackGenerator` and `.sensoryFeedback`) within 16ms of frame rendering.
4. **Accessibility First (Reduce Motion)**: Under `accessibilityReduceMotion`, spring physics and continuous pulsing are replaced with simple cross-fades and steady opacity values.

---

## 2. Spring Physics Tokens

```swift
extension Animation {
    /// Snappy tactile snap for button presses, card taps, and toggle flips
    static let ftTactileSnap = Animation.spring(response: 0.28, dampingRatio: 0.72)
    
    /// Sheet and screen entry transition spring
    static let ftSheetSpring = Animation.spring(response: 0.38, dampingRatio: 0.82)
    
    /// Shake bounce counter recoil
    static let ftRecoilSpring = Animation.spring(response: 0.22, dampingRatio: 0.55)
    
    /// Gentle breathing glow for active shield
    static let ftBreathingGlow = Animation.easeInOut(duration: 2.4).repeatForever(autoreverses: true)
}
```

---

## 3. Screen Transitions & State Change Choreography

### 3.1 Screen Entry & Modal Transitions

| Presentation | SwiftUI Pattern | Motion Choreography | Fallback (Reduce Motion) |
| :--- | :--- | :--- | :--- |
| **Dashboard to App Selector** | `NavigationLink` | Horizontal slide with 15% parallax background card dimming | Instant cross-fade (0.2s) |
| **NFC Pairing Modal** | `.sheet(isPresented:)` | Upward slide with spring `ftSheetSpring`; grabber handle micro-pulse | Instant cross-fade sheet |
| **Emergency Friction Unlock** | `.fullScreenCover` | Upward scale from bottom (`scaleEffect: 0.95 -> 1.0`, opacity `0 -> 1`) | Fade opacity 0.2s |
| **Subscription Paywall** | `.sheet` / `.fullScreen` | Delayed presentation (0.35s delay) with liquid glass backdrop blur | Fade opacity 0.25s |

### 3.2 Dynamic Micro-Interactions

#### A. Active Shield Countdown Ring Pulse
- **Visual**: The emerald outer glow ring expands from `scale: 1.0` to `scale: 1.04` and back over a 2.4-second cycle.
- **SwiftUI Implementation**:
  ```swift
  Circle()
      .stroke(Color.ftPrimaryGlow, lineWidth: 12)
      .scaleEffect(isBreathing ? 1.04 : 1.0)
      .animation(reduceMotion ? .none : .ftBreathingGlow, value: isBreathing)
  ```

#### B. Shake Counter Recoil (Screen 4: Emergency Unlock)
- **Visual**: Upon detecting acceleration exceeding `2.2g`, the counter number bounces up to `1.15x` scale and snaps back within 220ms.
- **SwiftUI Implementation**:
  ```swift
  Text("\(shakesLeft)")
      .font(.system(size: 64, weight: .heavy, design: .rounded))
      .scaleEffect(bounceScale)
      .onChange(of: shakesLeft) { _, _ in
          guard !reduceMotion else { return }
          bounceScale = 1.15
          withAnimation(.ftRecoilSpring) {
              bounceScale = 1.0
          }
      }
  ```

#### C. NFC Tag Tap Confirmation
- **Visual**: When tag UID matches, the dashboard ring morphs from Emerald into a concentric ripple wave that radiates outward 3 times before settling into unlocked state.

---

## 4. Haptic SensoryFeedback Matrix

All haptics integrate directly via iOS 17+ / 18+ `.sensoryFeedback` APIs and CoreHaptics for compound patterns.

| Interaction Event | Haptic Trigger API | Tactile Feeling | Psychological Purpose |
| :--- | :--- | :--- | :--- |
| **NFC Tag Scanned (Success)** | `.sensoryFeedback(.success, trigger: unlockTrigger)` | Crisp double-click pulse | Satisfying confirmation of physical key contact. |
| **NFC Tag Rejected (Wrong Tag)**| `.sensoryFeedback(.error, trigger: errorTrigger)` | Heavy 3-beat buzz | Sharp negative friction discouraging wrong keys. |
| **Valid Shake Increment** | `.sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: shakesLeft)` | Firm mechanical notch tick | Physical verification of effort expended. |
| **100 Shakes Completed** | `.sensoryFeedback(.heavy, trigger: isUnlocked)` + `.sensoryFeedback(.success, trigger: isUnlocked)` | Deep dual rumble | Relief and release after strenuous friction. |
| **Emergency Abort / Re-Lock** | `.sensoryFeedback(.impact(weight: .rigid), trigger: reLockTrigger)` | Solid mechanical latch | Positive reinforcement for maintaining focus discipline. |
| **Category Chip Selected** | `.sensoryFeedback(.selection, trigger: selectedCategory)` | Subtle micro-click | Native iOS feel when switching filters. |
| **Paywall Purchase Success** | `.sensoryFeedback(.success, trigger: purchaseState)` | Celebratory resonance | Rewarding commitment to digital wellness. |

---

## 5. Accessibility & Reduce Motion Compliance

```swift
struct FTMotionWrapper<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @ViewBuilder let content: (Bool) -> Content

    var body: some View {
        content(reduceMotion)
    }
}
```

- When `accessibilityReduceMotion == true`:
  1. All infinite pulsing and breathing effects are completely disabled.
  2. Shake bounce recoil (`scaleEffect`) is disabled; the digit changes value cleanly.
  3. Modal entries switch from spring physics to linear opacity fade (`duration: 0.2`).
  4. Radial glow blurs remain static without animated pulsing.
  5. Haptic feedback remains fully enabled as it provides non-visual confirmation.
