import Swinject
import Tetris

final class TetrisAssembly: Assembly {
    private let width: Int
    private let height: Int

    init(width: Int = 9, height: Int = 13) {
        self.width = width
        self.height = height
    }

    func assemble(container: Container) {
        let w = width, h = height
        container.register(TetrisInput.self) { _ in
            makeTetrisInput(width: w, height: h)
        }.inObjectScope(.container)
    }
}
