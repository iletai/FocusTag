import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.isPro) private var isPro
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var model = PaywallModel()
    @State private var showClose = false

    private let features: [LocalizedStringKey] = [
        "paywall.feature.nfc_lock", "paywall.feature.unlimited_tags",
        "paywall.feature.strict_mode", "paywall.feature.privacy"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                topBar
                banner
                VStack(spacing: 8) {
                    Text("paywall.headline")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.ftTextPrimary)
                    Text("paywall.subheadline")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftTextSecondary)
                }
                .multilineTextAlignment(.center)
                featureList
                plans
            }
            .padding(.horizontal, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.ftBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { footer.padding(.horizontal, 24).padding(.bottom, 8) }
        .sensoryFeedback(.success, trigger: model.purchaseCount)
        .task { await model.load() }
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(reduceMotion ? nil : .ftTactileSnap) { showClose = true }
        }
        // An existing entitlement (or a fresh purchase/restore) means there is nothing left to sell.
        .task(id: isPro) { if isPro { router.dismiss() } }
    }

    // MARK: - Sections

    private var topBar: some View {
        HStack {
            if showClose { FTCircularCloseButtonStyle { router.dismiss() }.transition(.opacity) } else { Color.clear.frame(width: 44, height: 44) }
            Spacer()
            Button("paywall.cta.restore") { Task { await model.restore() } }
                .buttonStyle(FTChipCapsuleStyle(isSelected: false))
                .disabled(model.isBusy)
        }
    }

    @ViewBuilder
    private var banner: some View {
        if let key = bannerKey {
            HStack(spacing: 12) {
                Text(key)
                    .font(.footnote)
                    .foregroundStyle(Color.ftTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if model.phase != .ready {
                    Button("common.retry") { Task { await model.load() } }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.ftPrimary)
                }
            }
            .padding(16)
            .ftCardSurface(cornerRadius: 16)
        }
    }

    private var bannerKey: LocalizedStringKey? {
        if let key = model.errorKey { return key }
        switch model.phase {
        case .offline: return "paywall.error.offline"
        case .unavailable: return "paywall.error.unavailable"
        default: return nil
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(features.indices, id: \.self) { index in
                Label {
                    Text(features[index])
                        .font(.subheadline)
                        .foregroundStyle(Color.ftTextPrimary)
                } icon: {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.ftPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .ftCardSurface()
    }

    @ViewBuilder
    private var plans: some View {
        switch model.phase {
        case .loading:
            VStack(spacing: 12) {
                PlanSkeleton()
                PlanSkeleton()
            }
        case .ready:
            VStack(spacing: 12) {
                if let yearly = model.yearly { yearlyCard(yearly) }
                if let weekly = model.weekly { weeklyCard(weekly) }
            }
        case .unavailable, .offline:
            EmptyView()
        }
    }

    private func yearlyCard(_ product: Product) -> some View {
        let monthly = product.priceFormatStyle.format(product.price / 12)
        let desc = model.isTrialEligible
            ? String(ftKey: "paywall.plan.annual.desc", product.displayPrice, monthly)
            : String(ftKey: "paywall.plan.annual.desc_no_trial", product.displayPrice, monthly)
        return PlanCard(isSelected: model.selected == .yearly, badge: "paywall.plan.annual.badge",
                        title: "paywall.plan.annual.title", detail: desc) {
            withAnimation(.ftTactileSnap) { model.selected = .yearly }
        }
    }

    private func weeklyCard(_ product: Product) -> some View {
        PlanCard(isSelected: model.selected == .weekly, badge: nil, title: "paywall.plan.weekly.title",
                 detail: String(ftKey: "paywall.plan.weekly.desc", product.displayPrice)) {
            withAnimation(.ftTactileSnap) { model.selected = .weekly }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Button { Task { await model.purchase(model.selectedProduct) } } label: {
                if model.isBusy {
                    ProgressView().tint(.black)
                } else {
                    Text(LocalizedStringKey(model.showsTrialCTA ? "paywall.cta.subscribe" : "paywall.cta.subscribe_plain"))
                }
            }
            .buttonStyle(FTPrimaryCapsuleStyle(isEnabled: model.selectedProduct != nil))
            .disabled(model.selectedProduct == nil || model.isBusy)
            if let lifetime = model.lifetime {
                Button { Task { await model.purchase(lifetime) } } label: {
                    Text(String(ftKey: "paywall.plan.lifetime.link", lifetime.displayPrice))
                        .font(.footnote.monospaced())
                        .foregroundStyle(Color.ftTextSecondary)
                        .frame(minHeight: 44)
                }
                .disabled(model.isBusy)
            }
            Text("paywall.footer.legal")
                .font(.caption2)
                .foregroundStyle(Color.ftTextTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: 24) {
                Link("paywall.legal.terms", destination: AppConfiguration.termsOfUseURL)
                Link("paywall.legal.privacy", destination: AppConfiguration.privacyPolicyURL)
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color.ftTextSecondary)
            .frame(minHeight: 44)
        }
    }
}

// MARK: - Subviews

private struct PlanCard: View {
    let isSelected: Bool
    let badge: LocalizedStringKey?
    let title: LocalizedStringKey
    let detail: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                if let badge { FTBadge(key: badge, color: .ftPrimary) }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline).foregroundStyle(Color.ftTextPrimary)
                        Text(detail).font(.footnote).foregroundStyle(Color.ftTextSecondary)
                    }
                    .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.ftPrimary : Color.ftTextTertiary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .ftCardSurface()
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.ftPrimary, lineWidth: isSelected ? 1.5 : 0)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct PlanSkeleton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDim = false

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.ftSurface)
            .frame(height: 88)
            .opacity(isDim ? 0.4 : 0.9)
            .animation(reduceMotion ? nil : .easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isDim)
            .onAppear { isDim = true }
            .accessibilityHidden(true)
    }
}
