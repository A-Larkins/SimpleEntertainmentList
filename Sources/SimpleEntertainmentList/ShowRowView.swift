import SwiftUI

struct ShowRowView: View {
    @ObservedObject var store: Store
    let item: Item
    @State private var newEpisodeLabel: String = ""
    @State private var isHovering = false

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

            ForEach(pendingToday) { episode in
                episodeRow(episode)
            }

            addEpisodeField
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

    private func episodeRow(_ episode: Episode) -> some View {
        EpisodeRow(store: store, item: item, episode: episode)
    }

    private var addEpisodeField: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 14)

            TextField("Add episode…", text: $newEpisodeLabel)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .onSubmit {
                    store.addEpisode(to: item, label: newEpisodeLabel)
                    newEpisodeLabel = ""
                }
        }
        .padding(.leading, 28)
    }
}

private struct EpisodeRow: View {
    @ObservedObject var store: Store
    let item: Item
    let episode: Episode
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                store.toggleEpisodeWatched(item: item, episode: episode)
            } label: {
                Image(systemName: episode.watched ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(episode.watched ? Theme.accent : .secondary)
            }
            .buttonStyle(.plain)

            Text(episode.label)
                .font(.system(size: 15))
                .strikethrough(episode.watched)
                .foregroundStyle(episode.watched ? .secondary : .primary)

            Spacer()

            Button {
                store.deleteEpisode(item: item, episode: episode)
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
