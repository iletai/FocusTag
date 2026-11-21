#if DEBUG
import SwiftUI

/// Debug-only launch seed for store screenshots: `-UITestSeed <scenario>`.
/// NFC, Screen Time and motion sensors do not exist in the simulator, so state is injected and those parts are faked.
/// Compiled out of Release builds.
enum UITestSeed {
    enum Scenario: String {
        case dashboard, empty, appPicker, nfcPairing, emergency, paywall
    }

    static let scenario = UserDefaults.standard.string(forKey: "UITestSeed").flatMap(Scenario.init(rawValue:))
    static var isActive: Bool { scenario != nil }

    /// Stands in for the opaque selection of `FamilyActivityPicker`, whose tokens cannot be constructed.
    static let fakeSelectedCount = 7
    static let fakeShakes = 62

    @MainActor
    static func apply(shield: FocusShieldManager, router: AppRouter) async {
        guard let scenario else { return }
        let isEmpty = scenario == .empty
        // In-memory only (no persistState), so the seed never leaks into stored user data.
        shield.blockedAppsCount = isEmpty ? 0 : fakeSelectedCount
        shield.isShieldActive = !isEmpty
        shield.isEmergencyActive = false
        shield.focusStartTime = isEmpty ? nil : Date().addingTimeInterval(-(3600 + 23 * 60 + 45))
        shield.elapsedSeconds = isEmpty ? 0 : 3600 + 23 * 60 + 45
        shield.pairedTag = isEmpty ? nil : PairedTag(name: "Fridge Tag", tagIdentifier: "04:A2:19:5C:7E:80")

        try? await Task.sleep(for: .seconds(0.5))
        switch scenario {
        case .dashboard, .empty: break
        case .appPicker: router.push(.appPicker)
        case .nfcPairing: router.present(sheet: .nfcPairing)
        case .emergency: router.present(cover: .emergency)
        case .paywall: router.present(sheet: .paywall)
        }
    }

    /// Static lookalike of the system picker (category rows with a selection mark).
    struct FakeActivityPicker: View {
        private let rows = [
            FakePickerRow(name: "Social", symbol: "bubble.left.and.bubble.right.fill", color: .blue),
            FakePickerRow(name: "Games", symbol: "gamecontroller.fill", color: .purple),
            FakePickerRow(name: "Entertainment", symbol: "play.tv.fill", color: .red),
            FakePickerRow(name: "Short Video", symbol: "play.rectangle.fill", color: .pink),
            FakePickerRow(name: "Shopping", symbol: "bag.fill", color: .orange),
            FakePickerRow(name: "News", symbol: "newspaper.fill", color: .gray),
            FakePickerRow(name: "Browsing", symbol: "safari.fill", color: .teal),
            FakePickerRow(name: "Streaming", symbol: "music.note", color: .indigo)
        ]

        var body: some View {
            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { index in
                    let isSelected = index < UITestSeed.fakeSelectedCount
                    HStack(spacing: 12) {
                        Image(systemName: rows[index].symbol)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(rows[index].color.gradient, in: .rect(cornerRadius: 9))
                        Text(rows[index].name).foregroundStyle(Color.ftTextPrimary)
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? Color.ftPrimary : Color.ftTextTertiary)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxHeight: .infinity)
                    if index < rows.count - 1 { Divider().overlay(Color.ftBorderSubtle) }
                }
            }
            .background(Color.ftSurface)
        }
    }
}

private struct FakePickerRow {
    let name: String
    let symbol: String
    let color: Color
}
#endif
