# Product Specification & Screen Inventory: FocusTag

* **App Name Draft:** FocusTag
* **Bundle ID:** `com.iletai.focustag`
* **Platform:** iOS 17.0+ (SwiftUI, SwiftData, Swift 6)
* **Target:** Solo Indie Developer MVP (1–2 weeks build time)
* **Zero-Server Constraints:** 100% On-Device (`FamilyControls`, `ManagedSettings`, `CoreNFC`, `StoreKit 2`, `SwiftData`).

---

## 1. User Journey & Screen Inventory (5 Màn hình cốt lõi cho Stitch)

### Screen 1: Dashboard / Active Shield (Màn hình chính)
* **Mục đích:** Hiển thị trạng thái khiên khóa hiện tại và thống kê thời gian tập trung.
* **Thành phần UI:**
  * **Status Badge (Hero Card):** Trạng thái lớn dạng capsule "SHIELD ACTIVE" (màu Emerald Green) hoặc "UNLOCKED" (màu Slate Muted).
  * **Focus Session Ring/Timer:** Vòng tròn tiến độ hiển thị thời gian đã khóa hoặc thời gian còn lại trong ca tập trung.
  * **Active Blocklist Summary:** Danh sách icon các app đang bị khóa (ví dụ: TikTok, Instagram, X, Safari).
  * **Primary Action Button (CTA):** "Scan NFC Tag to Unlock" (Nút nổi bật lớn dưới đáy màn hình với icon sóng NFC).
  * **Secondary Action:** "Emergency Unlock" (Nút dạng text mờ dành cho mở khóa khẩn cấp).

### Screen 2: App Block Selector (`FamilyControls` Picker)
* **Mục đích:** Cấu hình danh sách ứng dụng và danh mục cần chặn.
* **Thành phần UI:**
  * Header giải thích: "Chọn các ứng dụng gây xao nhãng nhất của bạn".
  * Quick Category Chips: "Social Media", "Games", "Video Streaming", "Shopping".
  * Native `FamilyActivityPicker` Container: Hiển thị bộ chọn app native của hệ thống iOS.
  * Tùy chọn Strict Mode (Toggle): "Chặn cả việc cài đặt/gỡ cài đặt app".
  * CTA Button: "Lưu danh sách khóa".

### Screen 3: NFC Tag Pairing & Setup
* **Mục đích:** Hướng dẫn người dùng quét và gán bất kỳ thẻ NFC vật lý nào làm "Chìa khóa mở khóa".
* **Thành phần UI:**
  * Minh họa đồ họa (Illustration/Lottie): Hoạt họa đưa iPhone lại gần thẻ/nhãn dán NFC.
  * Hướng dẫn 3 bước: "1. Lấy bất kỳ thẻ NFC nào (thẻ cư dân, thẻ xe bus, hoặc nhãn dán) - 2. Đặt nó ở xa giường/bàn làm việc - 3. Chạm để ghép đôi".
  * Nút hành động: "Bắt đầu quét thẻ NFC".
  * Trạng thái quét: Tích hợp `NFCNDEFReaderSession` native sheet của iOS.
  * Card thẻ đã ghép: Hiển thị tên gợi nhớ (ví dụ: "Thẻ tủ lạnh", "Thẻ bàn làm việc") kèm nút đổi thẻ.

### Screen 4: Emergency Friction Unlock (Mở khóa khẩn cấp khi xa thẻ)
* **Mục đích:** Cho phép mở khóa 5 phút trong tình huống bất khả kháng nhưng áp dụng ma sát vận động nặng để chặn thói quen vô thức.
* **Thành phần UI:**
  * Cảnh báo lớn: "Bạn đang yêu cầu mở khóa khẩn cấp (5 phút)".
  * Thử thách thể chất: Thanh tiến độ "Lắc điện thoại 100 lần để mở khóa" (sử dụng `CoreMotion` gia tốc kế đếm số lần lắc thực tế).
  * Bộ đếm động: Số lần lắc còn lại (ví dụ: "Còn 68 lần lắc nữa... Đừng bỏ cuộc!").
  * Nút hủy bỏ: "Quay lại trạng thái khóa".

### Screen 5: Hard Paywall (Monetization Engine)
* **Mục đích:** Kích hoạt đăng ký trả phí ngay sau Onboarding hoặc khi người dùng cấu hình xong thẻ NFC.
* **Thành phần UI:**
  * Social Proof & Value Hook: "Lấy lại sự tập trung".
  * Feature Comparison Checklist:
    * Khóa không thể bỏ qua bằng mật khẩu.
    * Ghép nối không giới hạn thẻ NFC.
    * Báo cáo tiến độ giảm thời gian dùng máy.
    * 100% riêng tư, lưu trữ hoàn toàn trên máy.
  * Pricing Cards (2 Tùy chọn rõ ràng):
    * **Card A (Đề xuất nổi bật - Best Value):** $29.99/năm (~$2.49/tháng), kèm nhãn "3-Day Free Trial".
    * **Card B:** $4.99/tuần.
    * **Card C (Link text nhỏ phía dưới):** Gói Lifetime trọn đời $49.99.
  * CTA Button: "Bắt đầu 3 ngày dùng thử miễn phí" (Start 3-Day Free Trial & Subscribe).
  * Footer: Điều khoản, phục hồi giao dịch (Restore Purchases), hủy bất kỳ lúc nào qua App Store.

---

## 2. Token & Design System Guidance (cho Stitch)
* **Theme:** Dark Mode First kết hợp đường nét Clean, Minimalist phong cách Linear / Apple Native.
* **Màu sắc chủ đạo:**
  * Background: Pitch Black (`#000000`) và Slate Card (`#16181D`).
  * Accent Primary: Laser Emerald (`#10B981`) cho trạng thái bảo vệ an toàn.
  * Warning / Locked: Crimson Coral (`#F43F5E`) cho trạng thái đang chặn ứng dụng.
  * Typography: SF Pro Rounded cho các số đếm/timer; SF Pro Text cho body copy.
