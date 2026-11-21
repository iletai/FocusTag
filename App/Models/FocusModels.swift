import Foundation

/// Physical NFC Tag registered as an unlock key
public struct PairedTag: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var name: String
    public var tagIdentifier: String
    public let pairedAt: Date

    public init(id: UUID = UUID(), name: String, tagIdentifier: String, pairedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tagIdentifier = tagIdentifier
        self.pairedAt = pairedAt
    }
}

/// Category filter chips for block selector
public enum BlockCategory: String, CaseIterable, Identifiable, Sendable {
    case all
    case social
    case games
    case video

    public var id: String { rawValue }

    public var titleKey: String {
        switch self {
        case .all: return "blocklist.category.all"
        case .social: return "blocklist.category.social"
        case .games: return "blocklist.category.games"
        case .video: return "blocklist.category.video"
        }
    }

    public var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .social: return "bubble.left.and.bubble.right.fill"
        case .games: return "gamecontroller.fill"
        case .video: return "play.tv.fill"
        }
    }
}
