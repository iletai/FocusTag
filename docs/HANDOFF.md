# Session Handoff: FocusTag Project Initiation

* **Author / Owner:** `iletai`
* **Repository:** `iletai/FocusTag` (Private, checked out at `~/orca/FocusTag`)
* **Bundle ID:** `com.iletai.focustag`
* **Target Category:** Productivity & Utilities
* **Monetization:** Hard Paywall ($4.99/week with 3-day trial, $29.99/year, $49.99 lifetime)
* **Zero-Server Tech Stack:** SwiftUI, SwiftData, `FamilyControls`, `ManagedSettings`, `CoreNFC`, `CoreMotion`, `StoreKit 2`

---

## 1. Artifacts Created & Validated (Step 4 Data Contracts)
1. **`RESEARCH_REPORT.md`**: Báo cáo nghiên cứu 5 chiều bóc tách từ 81 nguồn dữ liệu NotebookLM (RevenueCat, Adapty, Apple HIG).
2. **`docs/product/SPEC.md`**: Đặc tả chi tiết 5 màn hình cốt lõi (Dashboard Active Shield, App Picker, NFC Pairing, Emergency Friction Shake, Hard Paywall) dành riêng cho `expert-designer` agent và Stitch CLI.
3. **`.env.scaffold`**: File cấu hình biến môi trường chuẩn bị cho lệnh `new_app.sh` của `ios-new-app`.
4. **`fastlane/metadata/{en-US, vi}`**: Metadata ASO chuẩn App Store (Tên, phụ đề, từ khóa, mô tả).

---

## 2. Downstream Next Steps (Handoff Instructions)

### Giai đoạn A: Dựng UI & Flow trên Stitch CLI (`expert-designer`)
Đọc trực tiếp file `docs/product/SPEC.md` để khởi tạo Stitch project và sinh các màn hình:
```bash
stitch project init --name "FocusTag" --platform ios
# Dựng 5 màn hình theo SPEC.md: Dashboard, FamilyPicker, NFCPairing, EmergencyFriction, HardPaywall
```

### Giai đoạn B: Scaffold Xcode Project (`ios-new-app`)
Sử dụng script house standard để tạo project 3 môi trường (Dev/Staging/Prod):
```bash
cd /Users/lequangtrongtai/orca/FocusTag
source .env.scaffold
APPLE_TEAM_ID="$APPLE_TEAM_ID" ~/.agents/skills/ios-new-app/scripts/new_app.sh "$APP_NAME" "$BUNDLE_ID" ~/Developer/"$APP_NAME" --with "$FEATURES"
```

### Giai đoạn C: Tích hợp thư viện nội bộ
Tái sử dụng các thư viện sẵn có trong portfolio:
- `BaseNavigationStack`: Điều hướng mượt mà, type-safe giữa các flow.
- `AppUpdateKit`: Quản lý ép cập nhật / bảo trì qua remote config.
