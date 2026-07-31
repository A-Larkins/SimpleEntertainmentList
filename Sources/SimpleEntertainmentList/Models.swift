import Foundation

enum ItemKind: String, Codable, CaseIterable, Identifiable {
    case book = "Book"
    case audiobook = "Audiobook"
    case movie = "Movie"
    case show = "Show"
    case sports = "Sports"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .book: return "book.closed"
        case .audiobook: return "headphones"
        case .movie: return "film"
        case .show: return "tv"
        case .sports: return "sportscourt"
        }
    }

    /// Whether this kind is worked through in numbered pieces (episodes, chapters)
    /// with a daily pace, rather than as a single sitting.
    var tracksSequence: Bool {
        switch self {
        case .show, .book, .audiobook: return true
        case .movie, .sports: return false
        }
    }

    /// Show episodes are a concrete, fixed unit. Books/audiobooks are freeform —
    /// a chunk could be "4 chapters", "25 pages", whatever the day calls for —
    /// so there's no fixed noun for them.
    var unitName: String? {
        self == .show ? "episode" : nil
    }
}

struct Episode: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var label: String
    var watched: Bool = false
    var watchedDate: Date? = nil
}

struct Item: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var kind: ItemKind
    var isFinished: Bool = false
    var dailyEpisodeGoal: Int = 1
    var episodes: [Episode] = []
    var dateAdded: Date = Date()

    enum CodingKeys: String, CodingKey {
        case id, title, kind, isFinished, dailyEpisodeGoal, episodes, dateAdded
        case legacyIsDone = "isDone"
    }

    init(title: String, kind: ItemKind) {
        self.title = title
        self.kind = kind
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try c.decode(String.self, forKey: .title)
        kind = try c.decode(ItemKind.self, forKey: .kind)
        dateAdded = try c.decodeIfPresent(Date.self, forKey: .dateAdded) ?? Date()

        let legacyDone = try c.decodeIfPresent(Bool.self, forKey: .legacyIsDone) ?? false
        isFinished = try c.decodeIfPresent(Bool.self, forKey: .isFinished) ?? legacyDone
        dailyEpisodeGoal = try c.decodeIfPresent(Int.self, forKey: .dailyEpisodeGoal) ?? 1
        episodes = try c.decodeIfPresent([Episode].self, forKey: .episodes) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(kind, forKey: .kind)
        try c.encode(isFinished, forKey: .isFinished)
        try c.encode(dailyEpisodeGoal, forKey: .dailyEpisodeGoal)
        try c.encode(episodes, forKey: .episodes)
        try c.encode(dateAdded, forKey: .dateAdded)
    }

    /// Episodes already watched today, counted against the daily goal.
    func episodesWatchedToday(calendar: Calendar = .current) -> Int {
        episodes.filter { episode in
            guard episode.watched, let watchedDate = episode.watchedDate else { return false }
            return calendar.isDateInToday(watchedDate)
        }.count
    }

    /// The next episodes due today, capped by whatever's left of the daily goal.
    func pendingEpisodesForToday(calendar: Calendar = .current) -> [Episode] {
        let remaining = max(0, dailyEpisodeGoal - episodesWatchedToday(calendar: calendar))
        guard remaining > 0 else { return [] }
        return Array(episodes.filter { !$0.watched }.prefix(remaining))
    }
}
