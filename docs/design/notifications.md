# FocusTag — iOS Notifications & Live Focus Activity Specification

> **Platform Ground Truth**: iOS 27 look; Deployment Target: **iOS 18.0+**; iPhone Only.  
> **Source of Truth**: `docs/product/SPEC.md` & `RESEARCH_REPORT.md`.  
> **Apple HIG Compliance**: Human Interface Guidelines for User Notifications & Live Activities.

---

## 1. Notification Strategy & Philosophy

FocusTag strictly abides by Apple's user-centric notification principles:
1. **Never Spam**: Notifications are strictly triggered by user-defined schedules or critical focus events. Zero marketing pushes.
2. **Time-Sensitive Categorization**: Only urgent focus transitions (e.g. emergency unlock expiration warning) utilize the `time-sensitive` interruption level.
3. **Actionable from Lock Screen**: Every notification provides direct capsule action buttons (`UNNotificationAction`) so users can act without opening the app unless required.
4. **On-Device Scheduling**: 100% scheduled via `UNUserNotificationCenter` locally. No remote push server dependencies.

---

## 2. Notification Types & Trigger Matrix

| ID / Category | Interruption Level | Trigger Condition | Title (EN / VI) | Body (EN / VI) | Actions |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ft_session_prompt` | `active` | Scheduled calendar time (e.g. 09:00 AM Work Focus) | **Time to Focus** / **Đến giờ tập trung** | Tap your desk NFC tag to arm your shield and block distracting apps. / Chạm thẻ NFC trên bàn để bật khiên và khóa app xao nhãng. | • `ARM_NOW` ("Arm Shield Now")<br>• `SNOOZE_10` ("In 10 Minutes") |
| `ft_emergency_warning` | `timeSensitive` | 4 minutes into 5-minute emergency unlock (1 min left) | **1 Minute Left** / **Chỉ còn 1 phút** | Emergency unlock expires in 60s. Wrap up what you are doing before the shield re-arms. / Mở khóa khẩn cấp sẽ hết hạn sau 60 giây. Khiên sẽ tự động khóa lại. | • `RELOCK_NOW` ("Re-Lock Now") |
| `ft_daily_milestone` | `passive` | Daily at 21:00 PM (Bedtime summary) | **Focus Milestone** / **Cột mốc tập trung** | You reclaimed 3 hours and 15 minutes from social media today. Great discipline! / Hôm nay bạn đã lấy lại 3 giờ 15 phút khỏi mạng xã hội. Tuyệt vời! | None (Informational) |

---

## 3. Interactive Notification Action Contracts

```swift
import UserNotifications

enum FTNotificationCategory {
    static let sessionPrompt = "FT_CATEGORY_SESSION_PROMPT"
    static let emergencyWarning = "FT_CATEGORY_EMERGENCY_WARNING"
    
    static func registerCategories() {
        // 1. Session Prompt Actions
        let armAction = UNNotificationAction(
            identifier: "FT_ACTION_ARM_NOW",
            title: String(localized: "Arm Shield Now", comment: "Notification action to enable lock"),
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "FT_ACTION_SNOOZE_10",
            title: String(localized: "Remind in 10m", comment: "Snooze action"),
            options: []
        )
        let promptCategory = UNNotificationCategory(
            identifier: sessionPrompt,
            actions: [armAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // 2. Emergency Expiration Actions
        let relockAction = UNNotificationAction(
            identifier: "FT_ACTION_RELOCK_NOW",
            title: String(localized: "Re-Lock Now", comment: "Immediately restore block"),
            options: [.destructive]
        )
        let emergencyCategory = UNNotificationCategory(
            identifier: emergencyWarning,
            actions: [relockAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([promptCategory, emergencyCategory])
    }
}
```

---

## 4. Live Activity & Dynamic Island Specification (Optional Focus Extension)

When an Active Shield session is running, FocusTag provides a persistent status display in the Dynamic Island and Lock Screen via `ActivityKit`.

### 4.1 Dynamic Island States

```
Compact Leading:  [ 🛡️ 10B981 ]
Compact Trailing: [ 02:14:05 ]

Expanded Island:
+-------------------------------------------------------------+
| [ 🛡️ SHIELD ACTIVE ]                         02:14:05 LEFT  |
| 4 Distracting Apps Blocked                                  |
| [ Tap NFC Key to Unlock (Kitchen Fridge) ]                  |
+-------------------------------------------------------------+
```

### 4.2 Dynamic Island SwiftUI Contract

```swift
#if canImport(ActivityKit) && canImport(WidgetKit)
import ActivityKit
import WidgetKit
import SwiftUI

struct FTFocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var lockedAppsCount: Int
        var isEmergencyUnlock: Bool
    }
    var sessionName: String
}

@available(iOS 16.1, *)
struct FTFocusActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FTFocusActivityAttributes.self) { context in
            // Lock Screen Banner presentation (Liquid Glass material)
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(Color(hex: 0x10B981))
                VStack(alignment: .leading) {
                    Text(context.attributes.sessionName)
                        .font(.headline)
                    Text("\(context.state.lockedAppsCount) apps locked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(timerInterval: Date()...Date().addingTimeInterval(TimeInterval(context.state.remainingSeconds)), countsDown: true)
                    .font(.system(.title3, design: .rounded).monospacedDigit())
            }
            .padding()
            .background(.ultraThinMaterial)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Shield Active", systemImage: "shield.fill")
                        .font(.caption2)
                        .foregroundColor(Color(hex: 0x10B981))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...Date().addingTimeInterval(TimeInterval(context.state.remainingSeconds)), countsDown: true)
                        .font(.caption2.monospacedDigit())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tap designated NFC key to release lock")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Image(systemName: "shield.fill")
                    .foregroundColor(Color(hex: 0x10B981))
            } compactTrailing: {
                Text(timerInterval: Date()...Date().addingTimeInterval(TimeInterval(context.state.remainingSeconds)), countsDown: true)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                Image(systemName: "shield.fill")
                    .foregroundColor(Color(hex: 0x10B981))
            }
        }
    }
}
#endif
```
