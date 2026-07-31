import Foundation

@MainActor
final class Store: ObservableObject {
    @Published var items: [Item] = [] {
        didSet { save() }
    }

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SimpleEntertainmentList", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    func add(title: String, kind: ItemKind) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.insert(Item(title: trimmed, kind: kind), at: 0)
    }

    /// Marks a simple (non-show) item done for good — it archives to Finished.
    func toggleFinished(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isFinished.toggle()
    }

    func delete(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }

    func setDailyGoal(_ item: Item, goal: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].dailyEpisodeGoal = max(1, goal)
    }

    func addEpisode(to item: Item, label: String) {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].episodes.append(Episode(label: trimmed))
    }

    func toggleEpisodeWatched(item: Item, episode: Episode) {
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }),
              let episodeIndex = items[itemIndex].episodes.firstIndex(where: { $0.id == episode.id }) else { return }
        let watched = items[itemIndex].episodes[episodeIndex].watched
        items[itemIndex].episodes[episodeIndex].watched = !watched
        items[itemIndex].episodes[episodeIndex].watchedDate = watched ? nil : Date()
    }

    func deleteEpisode(item: Item, episode: Episode) {
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[itemIndex].episodes.removeAll { $0.id == episode.id }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        items = (try? JSONDecoder().decode([Item].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }
}
