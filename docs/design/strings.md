# FocusTag — Bilingual String Catalog & Copywriting Specification

> **Format**: Structured for direct export into Xcode 16+ `Localizable.xcstrings`.  
> **Locales**: English (Base / Primary: `en`), Vietnamese (Target: `vi`).  
> **Tone of Voice**: Clear, direct, disciplined, empowering, respectful.

---

## 1. Global & Common Navigation Strings

| Key | English (`en`) | Vietnamese (`vi`) | Comment / Context |
| :--- | :--- | :--- | :--- |
| `common.done` | Done | Xong | Top navigation bar action |
| `common.cancel` | Cancel | Hủy | Sheet dismiss or cancel action |
| `common.save` | Save | Lưu | Settings save button |
| `common.close` | Close | Đóng | Modal dismiss button |
| `common.retry` | Try Again | Thử lại | Error recovery button |
| `common.settings` | Settings | Cài đặt | Navigation title or button |
| `common.back` | Back | Quay lại | Accessibility voiceover label (hidden visually) |

---

## 2. Screen 1: Active Shield Dashboard

| Key | English (`en`) | Vietnamese (`vi`) | Comment / Context |
| :--- | :--- | :--- | :--- |
| `dashboard.badge.active` | SHIELD ACTIVE | KHIÊN ĐANG BẬT | Hero status capsule |
| `dashboard.badge.unlocked` | UNLOCKED | ĐÃ MỞ KHÓA | Hero status capsule when unlocked |
| `dashboard.timer.subtitle` | Time in deep focus | Thời gian tập trung sâu | Label beneath focus ring |
| `dashboard.locked_apps.count` | %lld Apps Currently Locked | Đang khóa %lld ứng dụng | Pluralized lock status |
| `dashboard.cta.scan_nfc` | Scan NFC Tag to Unlock | Quét thẻ NFC để mở khóa | 50pt Primary Capsule CTA |
| `dashboard.cta.emergency` | Emergency Friction Unlock | Mở khóa khẩn cấp bằng ma sát | 34pt Ghost Text button |
| `dashboard.empty.title` | No Apps Shielded Yet | Chưa có ứng dụng nào được khóa | Empty state headline |
| `dashboard.empty.subtitle` | Select the apps that steal your attention to activate your physical lock. | Chọn các ứng dụng gây xao nhãng để kích hoạt khiên khóa vật lý. | Empty state description |
| `dashboard.empty.cta` | Select Distracting Apps | Chọn ứng dụng gây xao nhãng | Empty state CTA button |
| `dashboard.alert.invalid_tag.title` | Wrong NFC Key | Sai thẻ NFC | Error toast header |
| `dashboard.alert.invalid_tag.message`| This tag is not registered. Tap your designated key (%@). | Thẻ này chưa được đăng ký. Hãy chạm đúng thẻ chìa khóa (%@). | Error toast body |

---

## 3. Screen 2: App Block Selector (`FamilyControls`)

| Key | English (`en`) | Vietnamese (`vi`) | Comment / Context |
| :--- | :--- | :--- | :--- |
| `blocklist.title` | Block Distracting Apps | Chặn ứng dụng xao nhãng | Screen Navigation Title |
| `blocklist.subtitle` | Selected apps and websites will be locked until you physically tap your NFC tag. | Các app và web đã chọn sẽ bị khóa cho đến khi bạn chạm thẻ NFC thực tế. | Screen header subtitle |
| `blocklist.category.all` | All | Tất cả | Quick filter chip |
| `blocklist.category.social` | Social Media | Mạng xã hội | Quick filter chip |
| `blocklist.category.games` | Games | Trò chơi | Quick filter chip |
| `blocklist.category.video` | Entertainment | Giải trí & Video | Quick filter chip |
| `blocklist.strict_mode.title` | Strict Mode | Chế độ nghiêm ngặt | Toggle card title |
| `blocklist.strict_mode.desc` | Saves your Strict Mode preference with this blocklist. | Lưu tùy chọn Chế độ nghiêm ngặt cùng danh sách chặn này. | Toggle card description |
| `blocklist.cta.save` | Save Blocklist | Lưu danh sách khóa | 50pt Primary Capsule CTA |
| `blocklist.permission.denied.title`| Screen Time Access Required | Cần cấp quyền Screen Time | Permission alert title |
| `blocklist.permission.denied.desc` | Apple Screen Time permission is required to shield apps securely on your device. | Cần cấp quyền Screen Time của Apple để bảo vệ ứng dụng hoàn toàn trên thiết bị của bạn. | Permission alert description |
| `blocklist.permission.open_settings`| Open iOS Settings | Mở Cài đặt iOS | Action button to open Settings |

---

## 4. Screen 3: NFC Tag Pairing & Setup

| Key | English (`en`) | Vietnamese (`vi`) | Comment / Context |
| :--- | :--- | :--- | :--- |
| `nfc_pairing.title` | Pair Your Physical Key | Ghép đôi chìa khóa vật lý | Modal Screen Title |
| `nfc_pairing.subtitle` | Any NFC card or sticker works (apartment tag, bus pass, or sticky tag). | Dùng được mọi thẻ NFC (thẻ thang máy, thẻ xe bus, hoặc nhãn dán NFC). | Subtitle description |
| `nfc_pairing.step1` | 1. Place the tag away from your desk or bed (e.g. Fridge). | 1. Đặt thẻ ở xa bàn làm việc hoặc giường ngủ (ví dụ: Tủ lạnh). | Guide step 1 |
| `nfc_pairing.step2` | 2. Tap phone to register this tag as your unlock key. | 2. Chạm điện thoại để đăng ký thẻ làm chìa khóa mở. | Guide step 2 |
| `nfc_pairing.step3` | 3. Whenever you need to unlock, you must walk to the tag. | 3. Mỗi khi muốn mở khóa, bạn buộc phải đứng dậy đi tới thẻ. | Guide step 3 |
| `nfc_pairing.cta.start` | Start Scanning NFC Tag | Bắt đầu quét thẻ NFC | 50pt Primary Capsule CTA |
| `nfc_pairing.tag_name.label` | Tag Location Nickname | Tên gợi nhớ vị trí thẻ | Input field title |
| `nfc_pairing.tag_name.placeholder`| e.g. Kitchen Fridge Tag | ví dụ: Thẻ Tủ Lạnh Nhà Bếp | Input field placeholder |
| `nfc_pairing.success.title` | Tag Successfully Paired! | Đã ghép đôi thẻ thành công! | Success alert title |
| `nfc_pairing.success.desc` | This tag is now your sole physical key to unlock distracting apps. | Thẻ này giờ là chìa khóa vật lý duy nhất để mở khóa các app xao nhãng. | Success alert description |
| `nfc_pairing.error.unsupported`| Unsupported tag format. Please try standard NTAG or transit cards. | Định dạng thẻ không hỗ trợ. Vui lòng thử thẻ NTAG hoặc thẻ xe thông dụng. | Error message |

---

## 5. Screen 4: Emergency Friction Shake

| Key | English (`en`) | Vietnamese (`vi`) | Comment / Context |
| :--- | :--- | :--- | :--- |
| `emergency.badge` | EMERGENCY UNLOCK: 5 MIN | MỞ KHÓA KHẨN CẤP: 5 PHÚT | Top hazard badge |
| `emergency.counter.label` | SHAKES LEFT | LẦN LẮC NỮA | Label under dynamic counter |
| `emergency.title` | Vigorously shake your phone | Lắc mạnh điện thoại của bạn | Instruction headline |
| `emergency.subtitle` | 100 physical shakes interrupt unconscious scrolling habits and prove true urgency. | 100 lần lắc giúp ngắt cơn thèm lướt điện thoại vô thức và xác thực tình huống khẩn cấp. | Instruction description |
| `emergency.progress.format` | %lld%% Completed | Đã hoàn thành %lld%% | Progress indicator string |
| `emergency.cta.cancel` | Keep Locked (I Don't Need It) | Vẫn giữ khóa (Tôi không cần nữa) | 50pt Secondary Capsule CTA |
| `emergency.action.relock` | Cancel & Re-Lock | Hủy & Tiếp tục khóa | Top bar capsule button |
| `emergency.toast.unlocked` | Emergency Unlocked for 5 Minutes | Đã mở khóa khẩn cấp trong 5 phút | Completion alert |

---

## 6. Screen 5: Hard Paywall (Subscription & Monetization)

| Key | English (`en`) | Vietnamese (`vi`) | Comment / Context |
| :--- | :--- | :--- | :--- |
| `paywall.headline` | Take back your focus | Lấy lại sự tập trung | Hero value proposition |
| `paywall.subheadline` | Block distracting apps until you tap your NFC tag. | Chặn các ứng dụng gây xao nhãng cho đến khi bạn chạm thẻ NFC. | Hero subheadline |
| `paywall.feature.nfc_lock` | Unlock with your own NFC tag | Mở khóa bằng thẻ NFC của riêng bạn | Feature checklist item 1 |
| `paywall.feature.unlimited_tags`| Unlimited physical NFC tag pairings | Ghép nối không giới hạn thẻ NFC | Feature checklist item 2 |
| `paywall.feature.strict_mode`| Strict Mode option for your blocklist | Tùy chọn Chế độ nghiêm ngặt cho danh sách chặn | Feature checklist item 3 |
| `paywall.feature.privacy` | Your NFC tag and app choices stay on your device | Thẻ NFC và lựa chọn ứng dụng của bạn luôn nằm trên thiết bị | Feature checklist item 4 |
| `paywall.plan.annual.badge` | BEST VALUE | TIẾT KIỆM NHẤT | Plan A top highlight badge |
| `paywall.plan.annual.title` | Annual Access | Gói Hàng Năm | Plan A title |
| `paywall.plan.annual.desc` | 3-Day Free Trial, then %@/year (%@/mo) | 3 ngày dùng thử miễn phí, sau đó %@/năm (%@/tháng) | Plan A description |
| `paywall.plan.weekly.title` | Weekly Access | Gói Hàng Tuần | Plan B title |
| `paywall.plan.weekly.desc` | %@ / week, billed weekly | %@ / tuần, thanh toán hàng tuần | Plan B description |
| `paywall.plan.lifetime.link` | Or unlock Lifetime Access for %@ | Hoặc mua Trọn Đời một lần duy nhất %@ | Plan C small text link |
| `paywall.cta.subscribe` | Start 3-Day Free Trial & Subscribe | Bắt đầu 3 ngày dùng thử & Đăng ký | 50pt Primary Capsule CTA |
| `paywall.cta.restore` | Restore Purchases | Khôi phục mua hàng | Top navigation bar action |
| `paywall.footer.legal` | Subscription automatically renews unless canceled in App Store Settings at least 24h before trial ends. Terms of Service & Privacy Policy. | Đăng ký tự động gia hạn trừ khi hủy trong Cài đặt App Store ít nhất 24h trước khi hết hạn dùng thử. Điều khoản dịch vụ & Chính sách bảo mật. | Legal disclaimer footer |
