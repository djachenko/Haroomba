import SwiftUI

struct GameOverView: View {
    let score: Int
    let ringsCleared: Int
    let duration: TimeInterval
    let leaderboard: LocalLeaderboard
    let onRestart: () -> Void
    let onMenu: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    statsCard
                    leaderboardCard
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Игра окончена")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("\(score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            Text("очков")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
                .foregroundStyle(.secondary)
            HStack {
                statItem(label: "Колец", value: "\(ringsCleared)")
                Divider()
                statItem(label: "Время", value: formattedDuration)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var leaderboardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Топ результаты")
                .font(.headline)
                .foregroundStyle(.secondary)
            ForEach(Array(leaderboard.entries.prefix(10).enumerated()), id: \.element.id) { i, entry in
                HStack {
                    Text("#\(i + 1)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(rankStyle(i))
                        .frame(width: 36, alignment: .leading)
                    Text("\(entry.score)")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                    Spacer()
                    Text("\(entry.ringsCleared) 🔵")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                if i < leaderboard.entries.prefix(10).count - 1 {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func rankStyle(_ index: Int) -> AnyShapeStyle {
        if index == 0 {
            return AnyShapeStyle(.yellow)
        }
        return AnyShapeStyle(.secondary)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onRestart) {
                Label("Играть снова", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button(action: onMenu) {
                Label("Главное меню", systemImage: "house")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var formattedDuration: String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return String(format: "%d:%02d", m, s)
    }
}
