import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var newTitle: String = ""
    @State private var newKind: ItemKind = .book

    private var upNext: [Item] {
        store.items.filter { !$0.isDone }
    }

    private var finished: [Item] {
        store.items.filter { $0.isDone }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            addBar

            List {
                if !upNext.isEmpty {
                    Section("Up Next") {
                        ForEach(Array(upNext.enumerated()), id: \.element.id) { index, item in
                            row(for: item, position: index + 1)
                        }
                        .onMove { source, destination in
                            store.moveUpNext(from: source, to: destination)
                        }
                    }
                }

                if !finished.isEmpty {
                    Section("Finished") {
                        ForEach(finished) { item in
                            row(for: item, position: nil)
                        }
                    }
                }

                if store.items.isEmpty {
                    Text("Nothing on the list yet — add a book, movie, or show above.")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
        }
        .frame(minWidth: 440, minHeight: 500)
        .background(Theme.paper)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Simple Entertainment List")
                .font(Theme.displayFont)
                .foregroundStyle(Theme.ink)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 2)
    }

    private var addBar: some View {
        HStack(spacing: 8) {
            Picker("", selection: $newKind) {
                ForEach(ItemKind.allCases) { kind in
                    Label(kind.rawValue, systemImage: kind.symbol).tag(kind)
                }
            }
            .labelsHidden()
            .frame(width: 110)
            .tint(Theme.accent)

            TextField("Add a title…", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addItem)

            Button("Add", action: addItem)
                .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .tint(Theme.accent)
        }
        .padding(12)
    }

    private func addItem() {
        store.add(title: newTitle, kind: newKind)
        newTitle = ""
    }

    private func row(for item: Item, position: Int?) -> some View {
        HStack {
            if let position {
                Text("\(position)")
                    .font(.system(.body, design: .rounded).monospacedDigit())
                    .foregroundStyle(Theme.accent)
                    .frame(width: 18, alignment: .trailing)
            }

            Button {
                store.toggleDone(item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? Theme.accent : .secondary)
            }
            .buttonStyle(.plain)

            Image(systemName: item.kind.symbol)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)

            Spacer()
        }
        .contentShape(Rectangle())
        .swipeActions {
            Button("Delete", role: .destructive) {
                store.delete(item)
            }
        }
    }
}
