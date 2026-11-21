import Foundation
import SwiftUI

import FamilyControls
#if canImport(ManagedSettings)
import ManagedSettings
#endif

@Observable
@MainActor
public final class FocusShieldManager {
    public static let shared = FocusShieldManager()

    // MARK: - State Properties

    public var isShieldActive: Bool = false
    public var focusStartTime: Date?
    public var elapsedSeconds: TimeInterval = 0
    public var pairedTag: PairedTag?
    public var activitySelection = FamilyActivitySelection()
    public var blockedAppsCount: Int = 0
    public var isStrictMode: Bool = false
    public var isEmergencyActive: Bool = false
    public var emergencyExpiresAt: Date?

    public var showInvalidTagAlert: Bool = false
    public var invalidTagAttemptName: String = ""
    public var triggerUnlockHaptic: Bool = false
    public var triggerErrorHaptic: Bool = false

    private var timer: Timer?

    // MARK: - Storage Keys

    private let kShieldActive = "FocusTag.isShieldActive"
    private let kStartTime = "FocusTag.focusStartTime"
    private let kPairedTag = "FocusTag.pairedTag"
    private let kBlockedAppsCount = "FocusTag.blockedAppsCount"
    private let kStrictMode = "FocusTag.isStrictMode"
    private let kActivitySelection = "FocusTag.activitySelection"
    private let defaults: UserDefaults

    // MARK: - Initializer

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadPersistedState()
        startTimerLoop()
    }

    // MARK: - Formatted Strings

    public var formattedTimer: String {
        if isEmergencyActive, let expires = emergencyExpiresAt {
            let remaining = max(0, Int(expires.timeIntervalSinceNow))
            let minutes = remaining / 60
            let seconds = remaining % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        let total = Int(elapsedSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - State Persistence

    private func loadPersistedState() {
        isShieldActive = defaults.bool(forKey: kShieldActive)

        if let savedStart = defaults.object(forKey: kStartTime) as? Date {
            focusStartTime = savedStart
            elapsedSeconds = max(0, Date().timeIntervalSince(savedStart))
        }

        blockedAppsCount = defaults.object(forKey: kBlockedAppsCount) as? Int ?? 0
        isStrictMode = defaults.bool(forKey: kStrictMode)

        if let data = defaults.data(forKey: kPairedTag),
           let tag = try? JSONDecoder().decode(PairedTag.self, from: data) {
            pairedTag = tag
        }

        if let data = defaults.data(forKey: kActivitySelection),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = selection
        }
    }

    private func persistState() {
        defaults.set(isShieldActive, forKey: kShieldActive)
        defaults.set(focusStartTime, forKey: kStartTime)
        defaults.set(blockedAppsCount, forKey: kBlockedAppsCount)
        defaults.set(isStrictMode, forKey: kStrictMode)
        defaults.set(try? JSONEncoder().encode(activitySelection), forKey: kActivitySelection)

        if let tag = pairedTag, let data = try? JSONEncoder().encode(tag) {
            defaults.set(data, forKey: kPairedTag)
        } else {
            defaults.removeObject(forKey: kPairedTag)
        }
    }

    // MARK: - Timer

    private func startTimerLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        if isEmergencyActive {
            if let expires = emergencyExpiresAt, Date() >= expires {
                // Emergency period expired, re-lock!
                isEmergencyActive = false
                emergencyExpiresAt = nil
                isShieldActive = true
                focusStartTime = Date()
                elapsedSeconds = 0
                persistState()
            }
        } else if isShieldActive {
            if let start = focusStartTime {
                elapsedSeconds = Date().timeIntervalSince(start)
            } else {
                focusStartTime = Date()
                elapsedSeconds = 0
            }
        }
    }

    // MARK: - Actions

    public func pairTag(name: String, identifier: String) {
        let newTag = PairedTag(name: name.isEmpty ? "Fridge Tag" : name, tagIdentifier: identifier)
        pairedTag = newTag
        persistState()
    }

    public func unlockWithNFC(identifier: String) -> Bool {
        guard let expected = pairedTag?.tagIdentifier else {
            // If no tag is configured yet, accept any tag and pair it
            isShieldActive = false
            triggerUnlockHaptic.toggle()
            persistState()
            return true
        }

        if identifier.caseInsensitiveCompare(expected) == .orderedSame {
            isShieldActive = false
            isEmergencyActive = false
            emergencyExpiresAt = nil
            triggerUnlockHaptic.toggle()
            persistState()
            return true
        } else {
            invalidTagAttemptName = pairedTag?.name ?? "Designated Tag"
            showInvalidTagAlert = true
            triggerErrorHaptic.toggle()
            return false
        }
    }

    public func unlockWithEmergencyShake() {
        isShieldActive = false
        isEmergencyActive = true
        emergencyExpiresAt = Date().addingTimeInterval(300) // 5 minutes
        triggerUnlockHaptic.toggle()
    }

    public func relockShield() {
        isEmergencyActive = false
        emergencyExpiresAt = nil
        isShieldActive = true
        focusStartTime = Date()
        elapsedSeconds = 0
        persistState()
    }

    public func updateBlockedSettings(selection: FamilyActivitySelection, strict: Bool) {
        activitySelection = selection
        let count = selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
        blockedAppsCount = count
        isStrictMode = strict
        if count == 0 {
            isShieldActive = false
        } else if !isShieldActive && !isEmergencyActive {
            isShieldActive = true
            focusStartTime = Date()
            elapsedSeconds = 0
        }
        persistState()
    }
}
