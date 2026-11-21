import FamilyControls
import ManagedSettingsUI
import SwiftUI

struct DashboardView: View {
    @Environment(FocusShieldManager.self) private var shield
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var reader = NFCTagReader()
    @State private var scanError: String?
    @State private var errorShakes: CGFloat = 0
    @State private var isErrorFlash = false
    @State private var showRipple = false

    var body: some View {
        @Bindable var shield = shield
        ScrollView {
            VStack(spacing: 24) {
                if shield.blockedAppsCount == 0 {
                    DashboardEmptyState { router.push(.appPicker) }
                } else {
                    activeContent
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.ftBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { actions.padding(.horizontal, 24).padding(.bottom, 8) }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { router.present(sheet: .nfcPairing) } label: {
                    Image(systemName: "wave.3.right.circle.fill")
                }
                .accessibilityLabel(Text("nfc_pairing.title"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.push(.appPicker) } label: {
                    Image(systemName: "apps.iphone")
                }
                .accessibilityLabel(Text("blocklist.title"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .alert(Text("dashboard.alert.invalid_tag.title"), isPresented: $shield.showInvalidTagAlert) {
            Button("common.done", role: .cancel) {}
        } message: {
            Text(String(ftKey: "dashboard.alert.invalid_tag.message", shield.invalidTagAttemptName))
        }
        .sensoryFeedback(.success, trigger: shield.triggerUnlockHaptic)
        .sensoryFeedback(.error, trigger: shield.triggerErrorHaptic)
        .onChange(of: shield.triggerUnlockHaptic) { playRipple() }
        .onChange(of: shield.triggerErrorHaptic) { flashError() }
    }

    // MARK: - Content

    private var isLocked: Bool { shield.isShieldActive }

    private var activeContent: some View {
        VStack(spacing: 24) {
            if isLocked {
                FTBadge(key: "dashboard.badge.active", color: .ftPrimary, showsDot: true)
            } else {
                FTBadge(key: "dashboard.badge.unlocked", color: .ftTextSecondary)
            }
            ZStack {
                ShieldRing(isLocked: isLocked, isErrorFlash: isErrorFlash)
                    .modifier(FTShakeEffect(shakes: errorShakes))
                if showRipple { RippleRings() }
            }
            Text(String(ftKey: "dashboard.locked_apps.count", shield.blockedAppsCount))
                .font(.body.weight(.medium))
                .foregroundStyle(Color.ftTextSecondary)
            LockedAppsCard(selection: shield.activitySelection)
        }
    }

    @ViewBuilder
    private var actions: some View {
        if shield.blockedAppsCount > 0 {
            VStack(spacing: 4) {
                if let scanError {
                    Text(scanError)
                        .font(.footnote)
                        .foregroundStyle(Color.ftHazard)
                        .multilineTextAlignment(.center)
                }
                if isLocked {
                    Button { Task { await scanToUnlock() } } label: {
                        Label("dashboard.cta.scan_nfc", systemImage: "wave.3.right.circle.fill")
                    }
                    .buttonStyle(FTPrimaryCapsuleStyle())
                    Button { router.present(cover: .emergency) } label: {
                        Text("dashboard.cta.emergency")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.ftTextSecondary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                } else {
                    Button { shield.relockShield() } label: {
                        Label("dashboard.cta.rearm", systemImage: "lock.shield.fill")
                    }
                    .buttonStyle(FTPrimaryCapsuleStyle())
                }
            }
        }
    }

    // MARK: - Actions

    private func scanToUnlock() async {
        scanError = nil
        // Without a registered key there is nothing to compare against: send the user to pairing.
        guard shield.pairedTag != nil else {
            router.present(sheet: .nfcPairing)
            return
        }
        do {
            let id = try await reader.scan(prompt: String(localized: "nfc.scan.prompt"))
            _ = shield.unlockWithNFC(identifier: id)
        } catch let error as NFCTagReader.ReadError {
            scanError = error.message
        } catch {
            Log.app.error("NFC scan failed: \(error.localizedDescription)")
        }
    }

    private func playRipple() {
        guard !reduceMotion else { return }
        showRipple = true
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            showRipple = false
        }
    }

    private func flashError() {
        isErrorFlash = true
        if !reduceMotion {
            withAnimation(.linear(duration: 0.6)) { errorShakes += 3 }
        }
        Task {
            try? await Task.sleep(for: .seconds(0.8))
            isErrorFlash = false
        }
    }
}

// MARK: - Subviews

private struct ShieldRing: View {
    @Environment(FocusShieldManager.self) private var shield
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var timerSize: CGFloat = 56
    @State private var isBreathing = false

    let isLocked: Bool
    let isErrorFlash: Bool

    private var tint: Color {
        if isErrorFlash { return .ftHazard }
        return isLocked ? .ftPrimary : .ftTextTertiary
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.ftPrimaryGlow, lineWidth: 12)
                .opacity(isLocked ? 1 : 0)
                .scaleEffect(isBreathing && isLocked ? 1.04 : 1.0)
                .animation(reduceMotion ? nil : .ftBreathingGlow, value: isBreathing)
            Circle().stroke(Color.ftBorderSubtle, lineWidth: 8)
            Circle()
                .trim(from: 0, to: remainingFraction)
                .stroke(tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(shield.formattedTimer)
                        .font(.system(size: timerSize, weight: .heavy, design: .rounded).monospacedDigit())
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundStyle(Color.ftTextPrimary)
                }
                Text(LocalizedStringKey(isLocked ? "dashboard.timer.subtitle" : "dashboard.timer.relock"))
                    .font(.footnote)
                    .foregroundStyle(Color.ftTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 220, height: 220)
        .padding(12)
        .onAppear { isBreathing = true }
        .animation(.ftTactileSnap, value: isErrorFlash)
    }

    /// Full ring while locked; shrinks over the 5-minute emergency window.
    private var remainingFraction: Double {
        guard shield.isEmergencyActive, let expires = shield.emergencyExpiresAt else { return 1 }
        return min(1, max(0, expires.timeIntervalSinceNow / 300))
    }
}

private struct RippleRings: View {
    @State private var expanded = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(Color.ftPrimary, lineWidth: 2)
                    .scaleEffect(expanded ? 1.7 : 1)
                    .opacity(expanded ? 0 : 0.6)
                    .animation(.easeOut(duration: 1).delay(Double(index) * 0.3), value: expanded)
            }
        }
        .frame(width: 220, height: 220)
        .allowsHitTesting(false)
        .onAppear { expanded = true }
    }
}

private struct LockedAppsCard: View {
    let selection: FamilyActivitySelection

    var body: some View {
        let tokens = Array(selection.applicationTokens.prefix(4))
        HStack(spacing: 16) {
            if tokens.isEmpty {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.title2)
                    .foregroundStyle(Color.ftPrimary)
            } else {
                ForEach(tokens, id: \.self) { token in
                    Label(token).labelStyle(.iconOnly).scaleEffect(1.6).frame(width: 48, height: 48)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48)
        .padding(16)
        .ftCardSurface()
    }
}

private struct DashboardEmptyState: View {
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .strokeBorder(Color.ftPrimary, style: StrokeStyle(lineWidth: 3, dash: [8, 8]))
                .frame(width: 220, height: 220)
                .overlay {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.ftPrimary)
                        .accessibilityHidden(true)
                }
                .padding(.top, 24)
            VStack(spacing: 8) {
                Text("dashboard.empty.title")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Color.ftTextPrimary)
                Text("dashboard.empty.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftTextSecondary)
            }
            .multilineTextAlignment(.center)
            Button(action: onSelect) {
                Text("dashboard.empty.cta")
            }
            .buttonStyle(FTPrimaryCapsuleStyle())
        }
    }
}
