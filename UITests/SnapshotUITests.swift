import XCTest

/// Store screenshots. Each scene launches the DEBUG-only `-UITestSeed <scenario>` state (see UITestSeed.swift),
/// because NFC, Screen Time and motion do not work in the simulator.
/// Raw PNGs are kept as attachments (names match docs/brand/screenshots-manifest.json); scripts/capture_screenshots.sh exports them.
/// Not MainActor: default isolation would change the XCTestCase inits, which are nonisolated.
final nonisolated class SnapshotUITests: XCTestCase {
    private struct Scene {
        let seed: String
        let name: String
        let settle: TimeInterval
    }

    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureScreenshots() throws {
        let scenes = [
            Scene(seed: "dashboard", name: "01-dashboard", settle: 3),
            Scene(seed: "empty", name: "01-dashboard-empty", settle: 3),
            Scene(seed: "appPicker", name: "02-app-picker", settle: 3),
            Scene(seed: "nfcPairing", name: "03-nfc-pairing", settle: 3),
            Scene(seed: "emergency", name: "04-emergency-unlock", settle: 3),
            Scene(seed: "paywall", name: "05-paywall", settle: 6)   // close button fades in after 2s; products load
        ]
        for scene in scenes {
            let app = XCUIApplication()
            setupSnapshot(app)
            app.launchArguments += ["-UITestSeed", scene.seed, "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
            app.launch()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
            Thread.sleep(forTimeInterval: scene.settle)
            snapshot(scene.name)   // fastlane snapshot output

            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = scene.name
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
    }
}
