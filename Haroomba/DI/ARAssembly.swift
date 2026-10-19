import JustKitDI
import Swinject

final class ARAssembly: Assembly {
    func assemble(container: Container) {
        container.autoregisterOnMain(GameSettings.init)
            .inObjectScope(.container)

        container.autoregisterOnMain(LocalLeaderboard.init)
            .inObjectScope(.container)

        container.autoregisterOnMain(ARGameRenderer.init)
            .inObjectScope(.transient)

        container.autoregisterOnMain(ARInputHandler.init)
            .inObjectScope(.transient)
    }
}
