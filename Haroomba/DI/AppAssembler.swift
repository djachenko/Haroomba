import Swinject

final class AppAssembler {
    static let shared = AppAssembler()
    let resolver: Resolver

    private let assembler: Assembler

    init() {
        assembler = Assembler([
            TetrisAssembly(),
            ARAssembly(),
        ])
        resolver = assembler.resolver
    }

    func resolve<T>(_ type: T.Type) -> T {
        resolver.resolve(type)!
    }
}
