import StoreKit
import SwiftUI

/// Loads the three Pro products and runs purchase/restore. Entitlement itself is observed by `FocusTagApp`
/// (`\.isPro`), so the view just dismisses when it flips to true.
@Observable
@MainActor
final class PaywallModel {
    enum Phase { case loading, ready, unavailable, offline }
    enum Plan { case yearly, weekly }

    private(set) var phase = Phase.loading
    private(set) var yearly: Product?
    private(set) var weekly: Product?
    private(set) var lifetime: Product?
    private(set) var isTrialEligible = false
    private(set) var isBusy = false
    private(set) var errorKey: LocalizedStringKey?
    private(set) var purchaseCount = 0
    var selected = Plan.yearly

    var selectedProduct: Product? { selected == .yearly ? yearly : weekly }
    var showsTrialCTA: Bool { selected == .yearly && isTrialEligible }

    func load() async {
        phase = .loading
        errorKey = nil
        do {
            let products = try await Product.products(for: [Store.yearlyID, Store.weeklyID, Store.lifetimeID])
            yearly = products.first { $0.id == Store.yearlyID }
            weekly = products.first { $0.id == Store.weeklyID }
            lifetime = products.first { $0.id == Store.lifetimeID }
            isTrialEligible = await yearly?.subscription?.isEligibleForIntroOffer ?? false
            phase = yearly == nil && weekly == nil ? .unavailable : .ready
        } catch {
            Log.store.error("Product load failed: \(error.localizedDescription)")
            if case StoreKitError.networkError = error { phase = .offline } else { phase = .unavailable }
        }
    }

    func purchase(_ product: Product?) async {
        guard let product, !isBusy else { return }
        isBusy = true
        errorKey = nil
        defer { isBusy = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                purchaseCount += 1
            case .success(.unverified):
                errorKey = "paywall.error.payment"
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            Log.store.error("Purchase failed: \(error.localizedDescription)")
            errorKey = "paywall.error.payment"
        }
    }

    func restore() async {
        isBusy = true
        errorKey = nil
        defer { isBusy = false }
        do {
            try await AppStore.sync()
        } catch {
            Log.store.error("Restore failed: \(error.localizedDescription)")
            errorKey = "paywall.error.payment"
        }
    }
}
