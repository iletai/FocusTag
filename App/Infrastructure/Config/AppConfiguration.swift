import Foundation

/// Build-time values from Info.plist (fed by Config/*.xcconfig). Never hardcode them in Swift.
enum AppConfiguration {
    enum Environment: String {
        case dev, staging, prod
    }

    /// From `APP_ENV` (Config/{Dev,Staging,Prod}.xcconfig). Staging talks to the production backend.
    static let environment: Environment = {
        guard let raw = string("APP_ENV"), let env = Environment(rawValue: raw) else {
            preconditionFailure("APP_ENV missing or invalid in Info.plist")
        }
        return env
    }()

    static var bundleIdentifier: String { Bundle.main.bundleIdentifier ?? "" }

    /// nil until `APP_STORE_URL` is set in Config/Backend-Prod.xcconfig (always nil in Dev).
    static var appStoreURL: URL? { string("APP_STORE_URL").flatMap(URL.init(string:)) }

    /// Legal links shown on the paywall (App Store guideline 3.1.2); identical in every environment, so not in xcconfig.
    static let privacyPolicyURL = URL(string: "https://apps-site-six.vercel.app/apps/focustag/privacy")!
    /// Apple's standard EULA, referenced in App Store Connect as the license agreement.
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    /// Custom Info.plist key; nil when missing or empty (unset xcconfig variables expand to "").
    static func string(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else { return nil }
        return value
    }
}
