import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var newTitle: String = ""
    @State private var newKind: ItemKind = .book

    private var todayItems: [Item] {
        store.items.filter { $0.kind.tracksSequence || !$0.isFinished }
    }

    private var finishedItems: [Item] {
        store.items.filter { !$0.kind.tracksSequence && $0.isFinished }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            addBar
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !todayItems.isEmpty {
                        sectionHeader("Today")
                        ForEach(todayItems) { item in
                            row(for: item)
                            Divider().padding(.leading, 18)
                        }
                    }

                    if !finishedItems.isEmpty {
                        sectionHeader("Finished")
                        ForEach(finishedItems) { item in
                            row(for: item)
                            Divider().padding(.leading, 18)
                        }
                    }

                    if store.items.isEmpty {
                        Text("Nothing on the list yet — add a book, audiobook, show, movie, or game above.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(18)
                    }
                }
            }
            .background(Theme.paper)
        }
        .frame(minWidth: 480, minHeight: 560)
        .background(Theme.paper)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .tracking(0.6)
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 6)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Simple Entertainment List")
                .font(Theme.displayFont)
                .foregroundStyle(Theme.ink)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    private var addBar: some View {
        HStack(spacing: 8) {
            Picker("", selection: $newKind) {
                ForEach(ItemKind.allCases) { kind in
                    Label(kind.rawValue, systemImage: kind.symbol).tag(kind)
                }
            }
            .labelsHidden()
            .frame(width: 140)
            .tint(Theme.accent)

            TextField("Add a title…", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 15))
                .onSubmit(addItem)

            Button("Add", action: addItem)
                .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .tint(Theme.accent)
        }
        .padding(14)
    }

    private func addItem() {
        store.add(title: newTitle, kind: newKind)
        newTitle = ""
    }

    @ViewBuilder
    private func row(for item: Item) -> some View {
        if item.kind.tracksSequence {
            SequencedRowView(store: store, item: item)
        } else {
            SimpleRowView(store: store, item: item)
        }
    }
}

private struct SimpleRowView: View {
    @ObservedObject var store: Store
    let item: Item
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                store.toggleFinished(item)
            } label: {
                Image(systemName: item.isFinished ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isFinished ? Theme.accent : .secondary)
            }
            .buttonStyle(.plain)

            Image(systemName: item.kind.symbol)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(item.title)
                .font(.system(size: 17))
                .strikethrough(item.isFinished)
                .foregroundStyle(item.isFinished ? .secondary : .primary)

            Spacer()

            Button {
                store.delete(item)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}
