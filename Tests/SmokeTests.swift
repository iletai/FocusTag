import Testing
@testable import FocusTag

struct SmokeTests {
    @Test func appLaunchesDashboard() {
        _ = DashboardView()
    }
}
