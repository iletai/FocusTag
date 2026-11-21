import SwiftUI

extension String {
    /// Localized format string from the catalog, e.g. `String(ftKey: "dashboard.locked_apps.count", count)`.
    init(ftKey key: String.LocalizationValue, _ args: CVarArg...) {
        self.init(format: String(localized: key), arguments: args)
    }
}

/// Horizontal shake that plays `shakes` full cycles while `shakes` animates from n to n + cycles.
struct FTShakeEffect: GeometryEffect {
    var travel: CGFloat = 8
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: travel * sin(shakes * .pi * 2), y: 0))
    }
}

/// Uppercase mono status capsule ("SHIELD ACTIVE", "EMERGENCY UNLOCK: 5 MIN").
struct FTBadge: View {
    let key: LocalizedStringKey
    let color: Color
    var showsDot = false

    var body: some View {
        HStack(spacing: 8) {
            if showsDot {
                Circle().fill(color).frame(width: 8, height: 8)
            }
            Text(key)
                .font(.footnote.weight(.bold).monospaced())
                .tracking(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 16)
        .frame(minHeight: 28)
        .background(color.opacity(0.14), in: Capsule())
    }
}
