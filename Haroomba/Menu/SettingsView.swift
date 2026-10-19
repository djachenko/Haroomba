import SwiftUI

struct SettingsView: View {
    @Bindable var settings: GameSettings

    var body: some View {
        Form {
            cylinderSection
            visualSection
            gameplaySection
            multiplayerSection
            tutorialSection
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.large)
    }

    private var cylinderSection: some View {
        Section("Цилиндр") {
            LabeledContent {
                Text(String(format: "%.1f м", settings.cylinderRadius))
            } label: {
                Text("Радиус")
            }
            Slider(value: $settings.cylinderRadius, in: 0.8...2.5, step: 0.1)
        }
    }

    private var visualSection: some View {
        Section("Внешний вид") {
            LabeledContent("Прозрачность блоков") {
                Text(String(format: "%.0f%%", settings.blockOpacity * 100))
            }
            Slider(value: $settings.blockOpacity, in: 0.2...1.0, step: 0.05)

            LabeledContent("Прозрачность сетки") {
                Text(String(format: "%.0f%%", settings.gridOpacity * 100))
            }
            Slider(value: $settings.gridOpacity, in: 0.0...0.6, step: 0.05)

            Toggle("Ghost piece", isOn: $settings.showGhostPiece)
        }
    }

    private var gameplaySection: some View {
        Section("Геймплей") {
            Picker("Сброс блока", selection: $settings.dropMode) {
                Text("Мягкий (soft)").tag(DropMode.soft)
                Text("Мгновенный (hard)").tag(DropMode.hard)
            }

            Picker("Анимация очистки кольца", selection: $settings.ringClearAnimation) {
                Text("Мгновенно").tag(RingClearAnimationMode.instant)
                Text("Растворение").tag(RingClearAnimationMode.dissolve)
            }
        }
    }

    private var multiplayerSection: some View {
        Section("Мультиплеер") {
            Toggle("Коллизия блоков игроков", isOn: $settings.playerBlocksCollide)
        }
    }

    private var tutorialSection: some View {
        Section("Обучение") {
            Toggle("Показывать подсказки", isOn: $settings.showTutorial)
            Button("Показать обучение снова") {
                settings.hasSeenTutorial = false
            }
            .foregroundStyle(.tint)
        }
    }
}
