import Foundation

struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let score: Int
    let ringsCleared: Int
    let duration: TimeInterval
    let date: Date

    init(score: Int, ringsCleared: Int, duration: TimeInterval) {
        self.id = UUID()
        self.score = score
        self.ringsCleared = ringsCleared
        self.duration = duration
        self.date = Date()
    }
}

final class LocalLeaderboard {
    static let shared = LocalLeaderboard()

    private let key = "leaderboard"
    private let maxEntries = 10

    private(set) var entries: [LeaderboardEntry] = []

    init() {
        load()
    }

    func add(score: Int, ringsCleared: Int, duration: TimeInterval) {
        let entry = LeaderboardEntry(score: score, ringsCleared: ringsCleared, duration: duration)
        entries.append(entry)
        entries.sort { $0.score > $1.score }
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([LeaderboardEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
