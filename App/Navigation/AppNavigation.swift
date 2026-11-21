import BaseNavigationStack
import SwiftUI

/// Pushed screens. Recipes (tabs, deep links): skill `iletai-libs` references/navigation.md.
enum AppRoute: Hashable, Sendable {
    case appPicker
}

/// Sheets. Hash by `id` if a payload is not Hashable.
enum AppSheet: Identifiable, Hashable, Sendable {
    case paywall
    case nfcPairing
    var id: String {
        switch self {
        case .paywall: "paywall"
        case .nfcPairing: "nfc-pairing"
        }
    }
}

extension AppSheet: SheetPresentable {
    var sheetOptions: SheetOptions {
        SheetOptions(detents: [.large], dragIndicator: .visible, cornerRadius: 28)
    }
}

/// Full-screen covers.
enum AppCover: Identifiable, Hashable, Sendable {
    case emergency
    var id: String {
        switch self {
        case .emergency: "emergency"
        }
    }
}

typealias AppRouter = NavigationRouter<AppRoute, AppSheet, AppCover>

struct AppRouteView: View {
    let route: AppRoute
    var body: some View {
        switch route {
        case .appPicker: AppPickerView()
        }
    }
}

struct AppSheetView: View {
    let sheet: AppSheet
    var body: some View {
        switch sheet {
        case .paywall: PaywallView()
        case .nfcPairing: NFCPairingView()
        }
    }
}

struct AppCoverView: View {
    let cover: AppCover
    var body: some View {
        switch cover {
        case .emergency: EmergencyFrictionView()
        }
    }
}
