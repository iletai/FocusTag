import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Semantic Color Tokens

extension Color {
    /// Root canvas background (OLED pitch black in dark mode)
    static let ftBackground = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                : UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1)
        }
    )

    /// Primary surface card container (#16181D)
    static let ftSurface = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.086, green: 0.094, blue: 0.114, alpha: 1)
                : UIColor.white
        }
    )

    /// Elevated surface for sheets and popups (#1C2027)
    static let ftSurfaceElevated = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.125, blue: 0.153, alpha: 1)
                : UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        }
    )

    /// Subtle structural border (#232730)
    static let ftBorderSubtle = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.137, green: 0.153, blue: 0.188, alpha: 1)
                : UIColor(white: 0, alpha: 0.08)
        }
    )

    /// Laser Emerald primary accent (#10B981)
    static let ftPrimary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1)
                : UIColor(red: 0.02, green: 0.588, blue: 0.412, alpha: 1)
        }
    )

    /// Glowing ambient aura for emerald accents
    static let ftPrimaryGlow = Color(red: 0.063, green: 0.725, blue: 0.506, opacity: 0.3)

    /// Hazard & Emergency accent (#F43F5E)
    static let ftHazard = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.957, green: 0.247, blue: 0.369, alpha: 1)
                : UIColor(red: 0.882, green: 0.114, blue: 0.282, alpha: 1)
        }
    )

    /// Primary label color
    static let ftTextPrimary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.886, green: 0.886, blue: 0.914, alpha: 1)
                : UIColor(red: 0.059, green: 0.09, blue: 0.165, alpha: 1)
        }
    )

    /// Secondary label color
    static let ftTextSecondary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.58, green: 0.639, blue: 0.722, alpha: 1)
                : UIColor(red: 0.278, green: 0.333, blue: 0.412, alpha: 1)
        }
    )

    /// Tertiary & disclaimer label color
    static let ftTextTertiary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1)
                : UIColor(red: 0.58, green: 0.639, blue: 0.722, alpha: 1)
        }
    )
}

// MARK: - Motion & Animation Tokens

extension Animation {
    /// Snappy tactile snap for button presses, card taps, and toggle flips
    static let ftTactileSnap = Animation.spring(response: 0.28, dampingFraction: 0.72)

    /// Sheet and screen entry transition spring
    static let ftSheetSpring = Animation.spring(response: 0.38, dampingFraction: 0.82)

    /// Shake bounce counter recoil
    static let ftRecoilSpring = Animation.spring(response: 0.22, dampingFraction: 0.55)

    /// Gentle breathing glow for active shield
    static let ftBreathingGlow = Animation.easeInOut(duration: 2.4).repeatForever(autoreverses: true)
}

// MARK: - Liquid Glass Modifier

struct FTLiquidGlassModifier: ViewModifier {
    var tintColor: Color?
    var isInteractive: Bool = false
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(Color.ftSurface.opacity(0.85), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.ftBorderSubtle, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func ftCardSurface(cornerRadius: CGFloat = 24) -> some View {
        modifier(FTLiquidGlassModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Button Styles

/// 50pt prominent capsule CTA button
struct FTPrimaryCapsuleStyle: ButtonStyle {
    var backgroundColor: Color = .ftPrimary
    var foregroundColor: Color = .black
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .default))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Capsule()
                    .fill(backgroundColor.opacity(isEnabled ? 1.0 : 0.4))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.ftTactileSnap, value: configuration.isPressed)
    }
}

/// 34pt chip filter capsule button
struct FTChipCapsuleStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold, design: .default))
            .foregroundStyle(isSelected ? Color.black : Color.ftTextPrimary)
            .padding(.horizontal, 16)
            .frame(height: 34)
            .background(
                Capsule()
                    .fill(isSelected ? Color.ftPrimary : Color.ftSurfaceElevated)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.ftBorderSubtle, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.ftTactileSnap, value: configuration.isPressed)
    }
}

/// 44pt standalone circular back or close button
struct FTCircularBackButtonStyle: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.ftTextPrimary)
                .frame(width: 44, height: 44)
                .background(Color.ftSurfaceElevated, in: Circle())
                .overlay(
                    Circle().stroke(Color.ftBorderSubtle, lineWidth: 0.5)
                )
        }
        .accessibilityLabel(Text("common.back"))
    }
}

struct FTCircularCloseButtonStyle: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.ftTextPrimary)
                .frame(width: 44, height: 44)
                .background(Color.ftSurfaceElevated, in: Circle())
                .overlay(
                    Circle().stroke(Color.ftBorderSubtle, lineWidth: 0.5)
                )
        }
        .accessibilityLabel(Text("common.close"))
    }
}
