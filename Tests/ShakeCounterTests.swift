import Foundation
import Testing
@testable import FocusTag

@MainActor
struct ShakeCounterTests {
    @Test func ignoresShakesBelowThreshold() {
        let counter = ShakeCounter()
        #expect(counter.register(magnitude: 2.0, at: Date()) == false)
        #expect(counter.shakes == 0)
    }

    @Test func rejectsShakesFasterThanMinInterval() {
        let counter = ShakeCounter()
        let start = Date()
        #expect(counter.register(magnitude: 3, at: start))
        #expect(counter.register(magnitude: 3, at: start.addingTimeInterval(0.1)) == false)
        #expect(counter.register(magnitude: 3, at: start.addingTimeInterval(0.3)))
        #expect(counter.shakes == 2)
    }

    @Test func pausesAtMilestoneThenCompletesAtTarget() {
        let counter = ShakeCounter()
        var now = Date()
        for _ in 0..<ShakeCounter.milestone {
            counter.register(magnitude: 3, at: now)
            now = now.addingTimeInterval(0.3)
        }
        #expect(counter.showMilestone)
        // Still inside the 1s pause: shake is dropped.
        #expect(counter.register(magnitude: 3, at: now) == false)
        now = now.addingTimeInterval(1)
        while !counter.isComplete {
            counter.register(magnitude: 3, at: now)
            now = now.addingTimeInterval(0.3)
        }
        #expect(counter.shakes == ShakeCounter.target)
        #expect(counter.shakesLeft == 0)
        #expect(counter.register(magnitude: 3, at: now) == false)
    }
}
