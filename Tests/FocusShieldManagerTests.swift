import Foundation
import Testing
@testable import FocusTag

@MainActor
struct FocusShieldManagerTests {
    private func makeManager() -> FocusShieldManager {
        FocusShieldManager(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)
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
        let remaining = try #require(manager.emergencyExpiresAt).timeIntervalSinceNow
        #expect((290...300).contains(remaining))
    }

    @Test func tagHashIsStableSha256Hex() {
        let digest = NFCTagReader.hash(uid: Data([0x04, 0xA2]))
        #expect(digest.count == 64)
        #expect(digest == NFCTagReader.hash(uid: Data([0x04, 0xA2])))
    }
}
