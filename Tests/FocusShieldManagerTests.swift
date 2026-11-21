import FamilyControls
import Foundation
import Testing
@testable import FocusTag

@MainActor
private final class FakeShieldStore: ShieldStore {
    private(set) var applyCount = 0
    private(set) var clearCount = 0
    private(set) var lastCall = ""

    func apply(_ selection: FamilyActivitySelection) {
        applyCount += 1
        lastCall = "apply"
    }

    func clear() {
        clearCount += 1
        lastCall = "clear"
    }
}

@MainActor
private final class TestClock {
    var date = Date(timeIntervalSince1970: 1_000_000)
}

@MainActor
struct FocusShieldManagerTests {
    private let store = FakeShieldStore()
    private let clock = TestClock()
    private let defaults = UserDefaults(suiteName: UUID().uuidString) ?? .standard

    private func makeManager() -> FocusShieldManager {
        FocusShieldManager(defaults: defaults, shieldStore: store, now: { [clock] in clock.date })
    }

    @Test func freshInstallIsEmptyAndUnlocked() {
        let manager = makeManager()
        #expect(manager.blockedAppsCount == 0)
        #expect(!manager.isShieldActive)
        #expect(manager.pairedTag == nil)
    }

    @Test func wrongTagKeepsShieldLockedAndRaisesAlert() {
        let manager = makeManager()
        manager.pairTag(name: "Desk", identifier: "abc")
        manager.relockShield()
        #expect(manager.unlockWithNFC(identifier: "zzz") == false)
        #expect(manager.isShieldActive)
        #expect(manager.showInvalidTagAlert)
        #expect(manager.invalidTagAttemptName == "Desk")
    }

    @Test func pairedTagUnlocks() {
        let manager = makeManager()
        manager.pairTag(name: "Desk", identifier: "abc")
        manager.relockShield()
        #expect(manager.unlockWithNFC(identifier: "ABC"))
        #expect(!manager.isShieldActive)
    }

    @Test func emergencyShakeStartsFiveMinuteWindow() throws {
        let manager = makeManager()
        manager.relockShield()
        manager.unlockWithEmergencyShake()
        #expect(manager.isEmergencyActive)
        #expect(!manager.isShieldActive)
        #expect(try #require(manager.emergencyExpiresAt) == clock.date.addingTimeInterval(300))
    }

    @Test func unlockWithoutPairedTagIsRejectedAndChangesNothing() {
        let manager = makeManager()
        manager.relockShield()
        let before = store.clearCount
        #expect(manager.unlockWithNFC(identifier: "abc") == false)
        #expect(manager.isShieldActive)
        #expect(!manager.showInvalidTagAlert)
        #expect(store.clearCount == before)
    }

    @Test func emergencyExpiryRelocksAndReappliesShield() throws {
        let manager = makeManager()
        manager.relockShield()
        manager.unlockWithEmergencyShake()
        #expect(store.lastCall == "clear")

        clock.date.addTimeInterval(299)
        manager.checkExpiry()
        #expect(manager.isEmergencyActive)

        clock.date.addTimeInterval(1)
        manager.checkExpiry()
        #expect(!manager.isEmergencyActive)
        #expect(manager.emergencyExpiresAt == nil)
        #expect(manager.isShieldActive)
        #expect(store.lastCall == "apply")
    }

    @Test func emergencyStatePersistsAcrossInit() throws {
        let manager = makeManager()
        manager.relockShield()
        manager.unlockWithEmergencyShake()
        let expires = try #require(manager.emergencyExpiresAt)

        clock.date.addTimeInterval(60)
        let reloaded = makeManager()
        #expect(reloaded.isEmergencyActive)
        #expect(reloaded.emergencyExpiresAt == expires)
        #expect(!reloaded.isShieldActive)
    }

    @Test func emergencyThatExpiredWhileAppWasClosedRelocksOnLaunch() {
        let manager = makeManager()
        manager.relockShield()
        manager.unlockWithEmergencyShake()

        clock.date.addTimeInterval(600)
        let reloaded = makeManager()
        #expect(!reloaded.isEmergencyActive)
        #expect(reloaded.isShieldActive)
        #expect(store.lastCall == "apply")
    }

    @Test func shieldStoreFollowsLockAndUnlock() {
        let manager = makeManager()
        #expect(store.lastCall == "clear")   // launch with nothing active
        manager.pairTag(name: "Desk", identifier: "abc")
        manager.relockShield()
        #expect(store.lastCall == "apply")
        #expect(manager.unlockWithNFC(identifier: "abc"))
        #expect(store.lastCall == "clear")
    }

    @Test func emptySelectionClearsShield() {
        let manager = makeManager()
        manager.relockShield()
        manager.updateBlockedSettings(selection: FamilyActivitySelection(), strict: false)
        #expect(!manager.isShieldActive)
        #expect(store.lastCall == "clear")
    }

    @Test func tagHashIsStableSha256Hex() {
        let digest = NFCTagReader.hash(uid: Data([0x04, 0xA2]))
        #expect(digest.count == 64)
        #expect(digest == NFCTagReader.hash(uid: Data([0x04, 0xA2])))
    }
}
