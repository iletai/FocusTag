import Testing
@testable import FocusTag

@MainActor
struct SmokeTests {
    @Test func appLaunchesDashboard() {
        _ = DashboardView()
    }
}
