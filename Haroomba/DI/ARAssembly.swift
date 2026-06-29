import Swinject

final class ARAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GameSettings.self) { _ in .shared }
            .inObjectScope(.container)

        container.register(LocalLeaderboard.self) { _ in .shared }
            .inObjectScope(.container)

        container.register(ARGameRenderer.self) { r in
            ARGameRenderer(settings: r.resolve(GameSettings.self)!)
        }.inObjectScope(.transient)

        container.register(ARInputHandler.self) { r in
            ARInputHandler(settings: r.resolve(GameSettings.self)!)
        }.inObjectScope(.transient)
    }
}
