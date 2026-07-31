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

    func toggleDone(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isDone.toggle()
    }

    func delete(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }

    func moveUpNext(from source: IndexSet, to destination: Int) {
        var upNext = items.filter { !$0.isDone }
        let finished = items.filter { $0.isDone }
        upNext.move(fromOffsets: source, toOffset: destination)
        items = upNext + finished
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
