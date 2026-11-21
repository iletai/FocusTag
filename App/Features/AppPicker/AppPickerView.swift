import FamilyControls
import SwiftUI

/// Chooses the apps/categories/domains to shield with Apple's picker. The system gives opaque tokens only;
/// it has no API to pre-filter by category, so the design's filter chips are intentionally not built.
struct AppPickerView: View {
    private enum Access { case pending, granted, denied }

    @Environment(FocusShieldManager.self) private var shield
    @Environment(AppRouter.self) private var router
    @Environment(\.openURL) private var openURL

    @State private var access = Access.pending
    @State private var selection = FamilyActivitySelection()
    @State private var isStrict = false
    @State private var didLoad = false

    private var selectedCount: Int {
        #if DEBUG
        if UITestSeed.isActive { return UITestSeed.fakeSelectedCount }
        #endif
        return selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("blocklist.title")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Color.ftTextPrimary)
                Text("blocklist.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftTextSecondary)
            }
            switch access {
            case .pending: ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .granted: grantedContent
            case .denied: deniedCard
            }
        }
        .padding(.horizontal, 24)
        .background(Color.ftBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { saveBar.padding(.horizontal, 24).padding(.bottom, 8) }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { FTCircularBackButtonStyle { router.pop() } }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: isStrict)
        .task { await authorize() }
        .onAppear(perform: loadStoredSelection)
    }

    // MARK: - Content

    private var grantedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(ftKey: "blocklist.selected.count", selectedCount))
                .font(.footnote.weight(.medium).monospaced())
                .foregroundStyle(Color.ftTextSecondary)
            picker
                .clipShape(.rect(cornerRadius: 24))
                .frame(maxHeight: .infinity)
            Toggle(isOn: $isStrict) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("blocklist.strict_mode.title")
                        .font(.headline)
                        .foregroundStyle(Color.ftTextPrimary)
                    Text("blocklist.strict_mode.desc")
                        .font(.footnote)
                        .foregroundStyle(Color.ftTextSecondary)
                }
            }
            .tint(Color.ftPrimary)
            .padding(16)
            .ftCardSurface()
        }
    }

    @ViewBuilder
    private var picker: some View {
        #if DEBUG
        if UITestSeed.isActive { UITestSeed.FakeActivityPicker() } else { FamilyActivityPicker(selection: $selection) }
        #else
        FamilyActivityPicker(selection: $selection)
        #endif
    }

    private var deniedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.ftHazard)
                .accessibilityHidden(true)
            Text("blocklist.permission.denied.title")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ftTextPrimary)
            Text("blocklist.permission.denied.desc")
                .font(.subheadline)
                .foregroundStyle(Color.ftTextSecondary)
            Button("blocklist.permission.open_settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
            .buttonStyle(FTPrimaryCapsuleStyle())
        }
        .multilineTextAlignment(.center)
        .padding(24)
        .frame(maxWidth: .infinity)
        .ftCardSurface()
    }

    private var saveBar: some View {
        VStack(spacing: 8) {
            if access == .granted, selectedCount == 0 {
                Text("blocklist.empty.hint")
                    .font(.footnote)
                    .foregroundStyle(Color.ftTextSecondary)
            }
            Button("blocklist.cta.save") {
                shield.updateBlockedSettings(selection: selection, strict: isStrict)
                router.pop()
            }
            .buttonStyle(FTPrimaryCapsuleStyle(isEnabled: selectedCount > 0))
            .disabled(selectedCount == 0)
            .opacity(access == .granted ? 1 : 0)
        }
    }

    // MARK: - Actions

    private func loadStoredSelection() {
        guard !didLoad else { return }
        didLoad = true
        selection = shield.activitySelection
        isStrict = shield.isStrictMode
    }

    private func authorize() async {
        #if DEBUG
        if UITestSeed.isActive { access = .granted; return }
        #endif
        let center = AuthorizationCenter.shared
        guard center.authorizationStatus != .approved else {
            access = .granted
            return
        }
        do {
            try await center.requestAuthorization(for: .individual)
            access = .granted
        } catch {
            Log.app.error("Screen Time authorization failed: \(error.localizedDescription)")
            access = .denied
        }
    }
}
