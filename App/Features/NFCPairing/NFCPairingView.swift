import SwiftUI

struct NFCPairingView: View {
    @Environment(FocusShieldManager.self) private var shield
    @Environment(AppRouter.self) private var router
    @Environment(\.isPro) private var isPro
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var reader = NFCTagReader()
    @State private var scannedID: String?
    @State private var nickname = ""
    @State private var errorMessage: String?
    @State private var isPulsing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack { FTCircularCloseButtonStyle { router.dismiss() }; Spacer() }
                illustration
                VStack(spacing: 8) {
                    Text(LocalizedStringKey(scannedID == nil ? "nfc_pairing.title" : "nfc_pairing.success.title"))
                        .font(.title.weight(.semibold))
                        .foregroundStyle(Color.ftTextPrimary)
                    Text(LocalizedStringKey(scannedID == nil ? "nfc_pairing.subtitle" : "nfc_pairing.success.desc"))
                        .font(.subheadline)
                        .foregroundStyle(Color.ftTextSecondary)
                }
                .multilineTextAlignment(.center)
                if scannedID == nil { stepsCard } else { nicknameField }
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.ftHazard)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.ftBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { cta.padding(.horizontal, 24).padding(.bottom, 8) }
        .sensoryFeedback(.success, trigger: scannedID)
        .sensoryFeedback(.error, trigger: errorMessage)
    }

    // MARK: - Content

    private var illustration: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(Color.ftPrimary.opacity(0.35 - Double(index) * 0.1), lineWidth: 2)
                    .frame(width: 100 + CGFloat(index) * 40, height: 100 + CGFloat(index) * 40)
                    .scaleEffect(isPulsing ? 1.08 : 1)
            }
            Image(systemName: scannedID == nil ? "wave.3.forward.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 88))
                .foregroundStyle(Color.ftPrimary)
                .accessibilityHidden(true)
        }
        .frame(height: 180)
        .animation(reduceMotion ? nil : .ftBreathingGlow, value: isPulsing)
        .onAppear { isPulsing = true }
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(["nfc_pairing.step1", "nfc_pairing.step2", "nfc_pairing.step3"].enumerated()), id: \.offset) { index, key in
                if index > 0 { Divider().overlay(Color.ftBorderSubtle) }
                Text(LocalizedStringKey(key))
                    .font(.subheadline)
                    .foregroundStyle(Color.ftTextPrimary)
                    .padding(.vertical, 12)
            }
            if let tag = shield.pairedTag {
                Divider().overlay(Color.ftBorderSubtle)
                Text(String(ftKey: "nfc_pairing.current", tag.name))
                    .font(.footnote.monospaced())
                    .foregroundStyle(Color.ftPrimary)
                    .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .ftCardSurface()
    }

    private var nicknameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("nfc_pairing.tag_name.label")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.ftTextSecondary)
            TextField("nfc_pairing.tag_name.placeholder", text: $nickname)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .frame(minHeight: 34)
                .background(Color.ftSurface, in: .rect(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ftBorderSubtle, lineWidth: 0.5))
        }
    }

    private var cta: some View {
        Group {
            if scannedID == nil {
                Button { Task { await scan() } } label: {
                    Label("nfc_pairing.cta.start", systemImage: "wave.3.right.circle.fill")
                }
            } else {
                Button("nfc_pairing.cta.done", action: finish)
            }
        }
        .buttonStyle(FTPrimaryCapsuleStyle())
    }

    // MARK: - Actions

    private func scan() async {
        errorMessage = nil
        do {
            let id = try await reader.scan(prompt: String(localized: "nfc.scan.prompt"))
            if id == shield.pairedTag?.tagIdentifier {
                errorMessage = String(localized: "nfc_pairing.error.duplicate")
            } else {
                scannedID = id
            }
        } catch let error as NFCTagReader.ReadError {
            errorMessage = error.message
        } catch {
            Log.app.error("NFC pairing failed: \(error.localizedDescription)")
        }
    }

    private func finish() {
        guard let scannedID else { return }
        shield.pairTag(name: nickname.trimmingCharacters(in: .whitespaces), identifier: scannedID)
        if shield.blockedAppsCount > 0, !shield.isShieldActive, !shield.isEmergencyActive {
            shield.relockShield()
        }
        router.dismiss()
        guard !isPro else { return }
        // Spec: paywall follows tag setup; wait for the sheet to finish dismissing (router refuses two modals).
        Task { [router] in
            try? await Task.sleep(for: .seconds(0.35))
            router.present(sheet: .paywall)
        }
    }
}
