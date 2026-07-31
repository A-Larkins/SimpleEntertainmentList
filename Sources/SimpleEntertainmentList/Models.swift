import Foundation

enum ItemKind: String, Codable, CaseIterable, Identifiable {
    case book = "Book"
    case movie = "Movie"
    case show = "Show"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .book: return "book.closed"
        case .movie: return "film"
        case .show: return "tv"
        }
    }
}

struct Item: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var kind: ItemKind
    var isDone: Bool = false
    var dateAdded: Date = Date()
}
