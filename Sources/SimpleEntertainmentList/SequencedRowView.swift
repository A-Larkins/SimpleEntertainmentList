import SwiftUI

/// Row for anything worked through in numbered pieces with a daily pace —
/// episodes for a show, chapters for a book or audiobook.
struct SequencedRowView: View {
    @ObservedObject var store: Store
    let item: Item
    @State private var newUnitLabel: String = ""
    @State private var isHovering = false

    private var unitName: String { item.kind.unitName }

    private var pendingToday: [Episode] {
        item.pendingEpisodesForToday()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: item.kind.symbol)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Text(item.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                Spacer()

                goalStepper

                deleteButton
            }

            if pendingToday.isEmpty && !item.episodes.isEmpty {
                Text("All caught up for today")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 28)
            }

            ForEach(pendingToday) { unit in
                unitRow(unit)
            }

            addUnitField
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }

    private var deleteButton: some View {
        Button {
            store.delete(item)
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .opacity(isHovering ? 1 : 0)
    }

    private var goalStepper: some View {
        HStack(spacing: 6) {
            Button {
                store.setDailyGoal(item, goal: item.dailyEpisodeGoal - 1)
            } label: {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.plain)
            .disabled(item.dailyEpisodeGoal <= 1)

            Text("\(item.dailyEpisodeGoal)/day")
                .font(.system(size: 13, design: .rounded).monospacedDigit())
                .foregroundStyle(Theme.accent)
                .frame(minWidth: 44)

            Button {
                store.setDailyGoal(item, goal: item.dailyEpisodeGoal + 1)
            } label: {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Theme.accent)
    }

    private func unitRow(_ unit: Episode) -> some View {
        SequenceUnitRow(store: store, item: item, unit: unit)
    }

    private var addUnitField: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 14)

            TextField("Add \(unitName)…", text: $newUnitLabel)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .onSubmit {
                    store.addEpisode(to: item, label: newUnitLabel)
                    newUnitLabel = ""
                }
        }
        .padding(.leading, 28)
    }
}

private struct SequenceUnitRow: View {
    @ObservedObject var store: Store
    let item: Item
    let unit: Episode
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                store.toggleEpisodeWatched(item: item, episode: unit)
            } label: {
                Image(systemName: unit.watched ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(unit.watched ? Theme.accent : .secondary)
            }
            .buttonStyle(.plain)

            Text(unit.label)
                .font(.system(size: 15))
                .strikethrough(unit.watched)
                .foregroundStyle(unit.watched ? .secondary : .primary)

            Spacer()

            Button {
                store.deleteEpisode(item: item, episode: unit)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
        }
        .padding(.leading, 28)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}
