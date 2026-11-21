# Deep Research & Market Analysis Report: FocusTag
* **App Concept:** FocusTag — Physical Friction Screen Time & Habit Lock
* **Category:** Productivity / Utilities
* **Target Audience:** Sinh viên, Knowledge Workers, Người nghiện Reels/TikTok/Social Media muốn cai nghiện màn hình triệt để
* **Data Sources:** RevenueCat State of Subscription Apps 2026, Adapty State of In-App Subscriptions, AppsFlyer iOS Benchmarks, NotebookLM Research (`88cddad9-c142-4ea5-aa7c-84d3de9c4f9b` & `ec867fb0-6a58-408b-b036-e89cdc547e1a`)

---

## 1. Phân tích đối thủ & Điểm đau khách hàng (Pain Points Mining)

### Điểm đau cốt lõi từ 1-star & 2-star Reviews của các app Screen Time hiện nay:
1. **Quá dễ dàng để bỏ qua (Bypass Fatigue):** Tính năng Screen Time mặc định của Apple hay các app như One Sec, Opal, Forest đều có nút "Bỏ qua giới hạn trong 15 phút" hoặc nhập mật mã. Khi thèm dopamin, ngón tay người dùng tự động bấm bỏ qua trong vô thức.
2. **Khóa quá gắt gao gây ức chế (Emergency Hostage):** Nhiều app khóa cứng hoàn toàn khiến người dùng rơi vào tình huống nguy cấp không thể dùng điện thoại, dẫn đến việc họ xóa luôn ứng dụng.
3. **Giá đăng ký quá đắt (Subscription Rage):** Người dùng bức xúc khi các app năng suất cơ bản đòi $60 – $100/năm hoặc $9.99/tuần mà không mang lại giá trị tương xứng sau tuần đầu tiên.

### 3 Khoảng trống thị trường lớn nhất (Market Gaps):
* **Khoảng trống 1 — Ma sát vật lý (Physical Friction):** Chưa có app nào tận dụng thẻ NFC gia dụng (thẻ xe bus, thẻ thang máy, nhãn NFC 500đ dán ngoài phòng) làm chìa khóa giải mã duy nhất, buộc người dùng phải đứng dậy rời khỏi giường/bàn làm việc.
* **Khoảng trống 2 — 100% Privacy & Zero-Server:** Người dùng e ngại các app Screen Time bên thứ ba theo dõi hành vi lướt web hoặc gửi dữ liệu về máy chủ.
* **Khoảng trống 3 — Mức giá hợp lý & Có tùy chọn Trọn đời:** Một mức giá dễ thở kết hợp Hard Paywall có dùng thử 3 ngày đạt tỷ lệ chuyển đổi cao vượt trội.

---

## 2. Bóc tách tính năng & MVP tối giản cho Solo Indie Dev (1–2 tuần)

### Nhóm A: 20% Tính năng cốt lõi tạo ra 80% Giá trị (MVP Scope)
1. **Lựa chọn ứng dụng chặn:** Sử dụng `FamilyControls` & `FamilyActivityPicker` để người dùng tick chọn app gây xao nhãng (TikTok, Facebook, Instagram, YouTube, X, Games).
2. **Kích hoạt Khiên bảo vệ (Shield):** Tích hợp `ManagedSettings` (`ManagedSettingsStore`) và `DeviceActivity` để chặn truy cập app mục tiêu ngay tức thì.
3. **Cơ chế Mở khóa bằng Thẻ NFC (Core Hook):** Quét bất kỳ thẻ NFC nào (thẻ cư dân, thẻ ngân hàng chạm, nhãn dán NTAG213/215) qua `CoreNFC`. Khi chạm đúng thẻ đã đăng ký, ứng dụng gỡ khiên khóa trong thời gian chỉ định (15m, 30m hoặc kết thúc ca làm việc).
4. **Mở khóa Khẩn cấp bằng Ma sát Vận động (Emergency Friction):** Nếu ở ngoài đường không có thẻ NFC, người dùng phải lắc máy liên tục 100 lần (`CoreMotion`) để mở khóa 5 phút.
5. **Hard Paywall sau Onboarding:** 3 ngày dùng thử miễn phí, chuyển đổi sang gói tuần hoặc gói năm.

### Nhóm B: Tính năng loại bỏ ở giai đoạn MVP (Anti-Bloatware)
* Không làm tài khoản đăng nhập đám mây (Cloud Auth/Sync).
* Không làm mạng xã hội kết bạn hay bảng xếp hạng cộng đồng.
* Không làm AI phân tích cảm xúc hay chatbot hỗ trợ.

---

## 3. Chiến lược kiếm tiền & Benchmark Chuyển đổi (Monetization Strategy)

* **Mô hình:** **Hard Paywall** sau màn hình giới thiệu tính năng & Onboarding ghép thẻ NFC.
* **Benchmark từ RevenueCat & Adapty 2026 cho nhóm Productivity/Utilities:**
  * **Day 0 Conversion:** 71.9% người trả phí chuyển đổi ngay trong Day 0.
  * **Tỷ lệ chuyển đổi dùng thử (Trial Conversion):** 8.5% – 12% (nhóm có tính năng tương tác vật lý đạt mức cận trên).
  * **1-Year Realized LTV:** Median **$30.16**, top 25% đạt **$49.26**, nhóm giữ chân dài hạn đạt **$68.90**.
* **Khung giá đề xuất (US & Global):**
  * Gói tuần: **$4.99/tuần** (kèm 3 ngày Free Trial) — kích thích dòng tiền tức thì.
  * Gói năm: **$29.99/năm** (chiết khấu 88%, đề xuất mặc định).
  * Gói Lifetime (Mua đứt): **$49.99** (tạo neo giá cao để đẩy người dùng mua gói năm).

---

## 4. Khung kiến trúc kỹ thuật iOS Native (Zero-Server Architecture)

* **UI Layer:** SwiftUI (iOS 17+), thiết kế chuẩn Apple HIG với hiệu ứng haptic phản hồi xúc giác mạnh mẽ khi chạm NFC.
* **Data Layer:** `SwiftData` lưu trữ danh sách thẻ NFC đã ghép (UID hash), lịch sử số lần mở khóa thành công, mục tiêu tập trung.
* **Apple Native Frameworks:**
  * `FamilyControls`: Xin quyền quản lý Screen Time của chính thiết bị (Individual authorization).
  * `ManagedSettings`: Cấu hình `shield.applications` và `shield.applicationCategories`.
  * `ManagedSettingsUI`: Tùy biến giao diện màn hình khóa khi người dùng bấm vào app bị chặn (hiển thị thông báo: "Chạm thẻ FocusTag để mở").
  * `CoreNFC`: Đọc thẻ NFC định dạng NDEF và tag UID.
  * `StoreKit 2`: Xử lý giao dịch mua trong ứng dụng hoàn toàn on-device với `Transaction.currentEntitlements`.
* **Chi phí vận hành:** **0 USD/tháng**. Không cơ sở dữ liệu cloud, không token AI, không máy chủ backend.

---

## 5. Tối ưu ASO & Kịch bản Viral TikTok/Reels

### Bộ từ khóa ASO (App Store Search Optimization)
* **App Name:** FocusTag: NFC Screen Time Lock
* **Subtitle:** Physical Habit & App Blocker
* **Keywords:** screen time,app blocker,nfc,focus,lock apps,dopamine detox,productivity,habit tracker,stop scrolling,study

### Kịch bản Video Ngắn Viral (TikTok / Reels / Shorts)
* **Clip 1 (The Bed Lockout - Hook thị giác cực mạnh):**
  * *0-3s:* Quay cảnh tay đang lướt TikTok trên giường lúc 1h sáng, bỗng nhiên màn hình nhảy thông báo khóa: "FocusTag: Thẻ mở khóa đang dán ở tủ lạnh phòng khách!".
  * *3-10s:* Nhân vật ngậm ngùi bước chân ra khỏi giường, đi xuống bếp chạm điện thoại vào tủ lạnh.
  * *10-15s:* Text: "Cách duy nhất để tôi không thức trắng đêm lướt điện thoại. Link in bio."
* **Clip 2 (Desk Discipline - Before vs After):**
  * So sánh màn hình: Bên trái gỡ Screen Time của Apple trong 2 giây vs Bên phải FocusTag bắt buộc phải đứng dậy đi lấy thẻ xe bus mới mở được Instagram.
