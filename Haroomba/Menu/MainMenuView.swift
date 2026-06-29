import SwiftUI

struct MainMenuView: View {
    @State private var showSettings = false
    @State private var showMultiplayer = false
    @State private var showAR = false

    let settings: GameSettings = .shared

    var body: some View {
        NavigationStack {
            ZStack {
                background
                content
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(settings: settings)
            }
            .navigationDestination(isPresented: $showMultiplayer) {
                MultiplayerMenuView()
            }
            .fullScreenCover(isPresented: $showAR) {
                ARGameContainerView()
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [.black, Color(white: 0.08)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()
            titleBlock
            Spacer()
            buttonStack
            Spacer()
            debugButton
        }
        .padding(.horizontal, 32)
    }

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text("HAROOMBA")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .tracking(6)
            Text("AR Tetris")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.5))
                .tracking(4)
        }
    }

    private var buttonStack: some View {
        VStack(spacing: 14) {
            menuButton(title: "Играть в AR", icon: "arkit", color: .cyan) {
                showAR = true
            }
            menuButton(title: "Мультиплеер", icon: "person.2.fill", color: .orange) {
                showMultiplayer = true
            }
            menuButton(title: "Настройки", icon: "gearshape.fill", color: .gray) {
                showSettings = true
            }
        }
    }

    @ViewBuilder
    private var debugButton: some View {
        #if DEBUG
        Button("2D Debug") {
            // present TestUI
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                let vc = TestUIPresenter.makeViewController()
                vc.modalPresentationStyle = .fullScreen
                root.present(vc, animated: true)
            }
        }
        .foregroundStyle(.white.opacity(0.3))
        .font(.footnote)
        .padding(.bottom, 32)
        #endif
    }

    private func menuButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// Wrapper to create ARGameViewController via SwiftUI fullScreenCover
struct ARGameContainerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let resolver = AppAssembler.shared.resolver
        let vc = ARGameViewController(
            settings: resolver.resolve(GameSettings.self)!,
            renderer: resolver.resolve(ARGameRenderer.self)!,
            inputHandler: resolver.resolve(ARInputHandler.self)!,
            leaderboard: resolver.resolve(LocalLeaderboard.self)!,
            tetrisInput: resolver.resolve(TetrisInput.self)!
        )
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

#if DEBUG
enum TestUIPresenter {
    static func makeViewController() -> UIViewController {
        TestUIAssembly.instance.vc()
    }
}
import TestUI
#endif
