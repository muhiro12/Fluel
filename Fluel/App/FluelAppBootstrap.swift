import MHPlatform

@MainActor
struct FluelAppBootstrap {
    let appRuntime: MHAppRuntime

    static func live() -> Self {
        .init(
            appRuntime: .init(
                configuration: FluelAppConfiguration.runtimeConfiguration
            )
        )
    }
}
