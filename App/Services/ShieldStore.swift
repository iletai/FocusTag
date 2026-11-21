import FamilyControls
import ManagedSettings

/// Seam over `ManagedSettingsStore` so unit tests can assert apply/clear without the Family Controls entitlement.
@MainActor
protocol ShieldStore {
    func apply(_ selection: FamilyActivitySelection)
    func clear()
}

/// Real shield: writes the selection into the system-wide ManagedSettings shield.
/// Without the entitlement the system ignores the writes, so this is safe on the simulator.
@MainActor
struct ManagedSettingsShieldStore: ShieldStore {
    private let store = ManagedSettingsStore()

    func apply(_ selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    func clear() {
        store.clearAllSettings()
    }
}
