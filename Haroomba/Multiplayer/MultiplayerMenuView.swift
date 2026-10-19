import SwiftUI

struct MultiplayerMenuView: View {
    @State private var mpSession = MPSession()
    @State private var phase: Phase = .choice
    @State private var showGame = false

    enum Phase { case choice, hosting, browsing, waitingToStart }

    var body: some View {
        VStack(spacing: 28) {
            switch phase {
            case .choice:
                choiceView
            case .hosting:
                hostView
            case .browsing:
                guestView
            case .waitingToStart:
                waitingView
            }
        }
        .padding(24)
        .navigationTitle("Мультиплеер")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showGame) {
            ARGameContainerView() // TODO: pass mpSession
        }
    }

    private var choiceView: some View {
        VStack(spacing: 16) {
            Button {
                mpSession.startHosting()
                phase = .hosting
            } label: {
                Label("Создать игру", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                mpSession.startBrowsing()
                phase = .browsing
            } label: {
                Label("Присоединиться", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var hostView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Ожидание игроков…")
                .font(.headline)
            if !mpSession.connectedPeers.isEmpty {
                Text("Подключены: \(mpSession.connectedPeers.map(\.displayName).joined(separator: ", "))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Начать") {
                    mpSession.broadcast(.startGame)
                    showGame = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    private var guestView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Ищем игру рядом…")
                .font(.headline)
            if !mpSession.connectedPeers.isEmpty {
                Text("Подключено к: \(mpSession.connectedPeers.first?.displayName ?? "")")
                    .foregroundStyle(.secondary)
                    .onAppear { phase = .waitingToStart }
            }
        }
    }

    private var waitingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Ожидаем хоста…")
                .font(.headline)
        }
    }
}
