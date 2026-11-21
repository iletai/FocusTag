import CoreMotion
import Foundation

/// Counts hard physical shakes (|userAcceleration| above `threshold` g) for the emergency unlock.
@Observable
@MainActor
final class ShakeCounter {
    enum Status: Equatable {
        case calibrating, running, unavailable
    }

    static let target = 100
    static let threshold = 2.2
    /// Minimum gap between two counted shakes; stops a single jolt or a fast scripted spoof from counting twice.
    static let minInterval: TimeInterval = 0.25
    static let milestone = 50

    private(set) var shakes = 0
    private(set) var status = Status.calibrating
    private(set) var showMilestone = false

    @ObservationIgnored private let motion = CMMotionManager()
    @ObservationIgnored private var lastShake = Date.distantPast
    @ObservationIgnored private var pausedUntil = Date.distantPast

    var shakesLeft: Int { Self.target - shakes }
    var progress: Double { Double(shakes) / Double(Self.target) }
    var isComplete: Bool { shakes >= Self.target }

    func start() {
        #if DEBUG
        if UITestSeed.isActive {   // simulator has no motion sensor; show a mid-challenge state
            shakes = UITestSeed.fakeShakes
            status = .running
            return
        }
        #endif
        guard motion.isDeviceMotionAvailable else {
            status = .unavailable
            Log.app.error("Device motion unavailable")
            return
        }
        motion.deviceMotionUpdateInterval = 1.0 / 30.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let a = data?.userAcceleration else { return }
            let magnitude = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
            MainActor.assumeIsolated { self?.handle(magnitude: magnitude) }
        }
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
    }

    private func handle(magnitude: Double) {
        if status != .running { status = .running }
        register(magnitude: magnitude, at: Date())
    }

    /// Returns true when this sample counted as a shake.
    @discardableResult
    func register(magnitude: Double, at now: Date) -> Bool {
        guard !isComplete, magnitude > Self.threshold,
              now.timeIntervalSince(lastShake) >= Self.minInterval,
              now >= pausedUntil else { return false }
        lastShake = now
        shakes += 1
        if shakes == Self.milestone {
            // 1s forced pause at the halfway mark breaks the autopilot loop.
            pausedUntil = now.addingTimeInterval(1)
            showMilestone = true
        }
        return true
    }

    func dismissMilestone() {
        showMilestone = false
    }
}
