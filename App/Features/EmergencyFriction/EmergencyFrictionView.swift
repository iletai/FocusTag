import SwiftUI

/// 100-shake challenge that grants a 5-minute emergency unlock. Presented as a full-screen cover.
struct EmergencyFrictionView: View {
    @Environment(FocusShieldManager.self) private var shield
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var counter = ShakeCounter()
    @State private var bounceScale: CGFloat = 1
    @State private var reLockTrigger = 0
    @State private var didUnlock = false
    @ScaledMetric(relativeTo: .largeTitle) private var counterSize: CGFloat = 64

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: cancel) {
                    Text("emergency.action.relock")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.ftTextPrimary)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                        .background(Color.ftSurfaceElevated, in: Capsule())
                }
                Spacer()
            }
            FTBadge(key: "emergency.badge", color: .ftHazard)
            ring
            VStack(spacing: 8) {
                Text(LocalizedStringKey(didUnlock ? "emergency.toast.unlocked" : "emergency.title"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ftTextPrimary)
                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(counter.status == .unavailable ? Color.ftHazard : Color.ftTextSecondary)
            }
            .multilineTextAlignment(.center)
            ProgressView(value: counter.progress)
                .tint(Color.ftHazard)
                .accessibilityValue(Text(String(ftKey: "emergency.progress.format", Int(counter.progress * 100))))
            Text(String(ftKey: "emergency.progress.format", Int(counter.progress * 100)))
                .font(.footnote.monospaced())
                .foregroundStyle(Color.ftTextSecondary)
            Spacer(minLength: 0)
            Button(action: cancel) { Text("emergency.cta.cancel") }
                .buttonStyle(FTPrimaryCapsuleStyle(backgroundColor: .ftSurfaceElevated, foregroundColor: .ftTextPrimary))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(Color.ftBackground.ignoresSafeArea())
        .overlay(alignment: .top) { milestoneBanner }
        .interactiveDismissDisabled()
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: counter.shakes) { old, new in new > old && !counter.isComplete }
        .sensoryFeedback(.success, trigger: didUnlock)
        .sensoryFeedback(.impact(weight: .heavy), trigger: didUnlock)
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: reLockTrigger)
        .onChange(of: counter.shakes) { bounce(); completeIfNeeded() }
        .task(id: counter.showMilestone) {
            guard counter.showMilestone else { return }
            try? await Task.sleep(for: .seconds(3))
            counter.dismissMilestone()
        }
        .onAppear { counter.start() }
        .onDisappear { counter.stop() }
    }

    // MARK: - Content

    private var ring: some View {
        ZStack {
            Circle().stroke(Color.ftBorderSubtle, lineWidth: 8)
            Circle()
                .trim(from: 0, to: counter.progress)
                .stroke(Color.ftHazard, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.ftTactileSnap, value: counter.progress)
            VStack(spacing: 4) {
                if counter.status == .calibrating {
                    ProgressView()
                } else {
                    Text("\(counter.shakesLeft)")
                        .font(.system(size: counterSize, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(Color.ftTextPrimary)
                        .scaleEffect(bounceScale)
                    Text("emergency.counter.label")
                        .font(.caption2.weight(.bold).monospaced())
                        .tracking(1)
                        .foregroundStyle(Color.ftHazard)
                }
            }
        }
        .frame(width: 200, height: 200)
        .padding(12)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var milestoneBanner: some View {
        if counter.showMilestone {
            Text("emergency.milestone")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ftTextPrimary)
                .multilineTextAlignment(.center)
                .padding(16)
                .ftCardSurface()
                .padding(.horizontal, 24)
                .transition(.opacity)
        }
    }

    private var statusText: LocalizedStringKey {
        switch counter.status {
        case .unavailable: "emergency.error.unavailable"
        case .calibrating: "emergency.calibrating"
        case .running: "emergency.subtitle"
        }
    }

    // MARK: - Actions

    private func bounce() {
        guard !reduceMotion else { return }
        bounceScale = 1.15
        withAnimation(.ftRecoilSpring) { bounceScale = 1 }
    }

    private func completeIfNeeded() {
        guard counter.isComplete, !didUnlock else { return }
        didUnlock = true
        counter.stop()
        shield.unlockWithEmergencyShake()
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            router.dismiss()
        }
    }

    private func cancel() {
        counter.stop()
        reLockTrigger += 1
        Task {
            // Let the rigid latch haptic play before the cover goes away.
            try? await Task.sleep(for: .milliseconds(150))
            router.dismiss()
        }
    }
}
