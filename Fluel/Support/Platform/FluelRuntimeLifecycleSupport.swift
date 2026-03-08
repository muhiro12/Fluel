import MHPlatform
import SwiftUI

/// Compatibility task wrapper for the current MHPlatform package pin, which
/// does not yet ship lifecycle plan helpers.
struct MHAppRuntimeTask: Sendable {
    private let operation: @MainActor @Sendable (MHAppRuntime) async -> Void

    init(
        _ operation: @escaping @MainActor @Sendable (MHAppRuntime) async -> Void
    ) {
        self.operation = operation
    }

    @MainActor
    func run(runtime: MHAppRuntime) async {
        await operation(runtime)
    }
}

/// Compatibility lifecycle plan matching the shape used by newer MHPlatform.
struct MHAppRuntimeLifecyclePlan: Sendable {
    static let empty = Self()

    let startupTasks: [MHAppRuntimeTask]
    let activeTasks: [MHAppRuntimeTask]
    let skipFirstActivePhase: Bool

    init(
        startupTasks: [MHAppRuntimeTask] = [],
        activeTasks: [MHAppRuntimeTask] = [],
        skipFirstActivePhase: Bool = false
    ) {
        self.startupTasks = startupTasks
        self.activeTasks = activeTasks
        self.skipFirstActivePhase = skipFirstActivePhase
    }
}

enum FluelRuntimeLifecycleSupport {
    @MainActor
    static func makePlan() -> MHAppRuntimeLifecyclePlan {
        .init(skipFirstActivePhase: true)
    }
}

@MainActor
private final class FluelRuntimeLifecycleState {
    let runtime: MHAppRuntime
    let plan: MHAppRuntimeLifecyclePlan

    private var hasHandledInitialAppearance = false
    private var hasSeenActivePhase = false

    init(
        runtime: MHAppRuntime,
        plan: MHAppRuntimeLifecyclePlan
    ) {
        self.runtime = runtime
        self.plan = plan
    }

    func handleInitialAppearance() async {
        guard hasHandledInitialAppearance == false else {
            return
        }

        hasHandledInitialAppearance = true
        runtime.startIfNeeded()

        for task in plan.startupTasks {
            await task.run(runtime: runtime)
        }
    }

    func handleScenePhase(_ scenePhase: ScenePhase) async {
        guard scenePhase == .active else {
            return
        }

        if hasHandledInitialAppearance == false {
            await handleInitialAppearance()
        }

        defer {
            hasSeenActivePhase = true
        }

        if plan.skipFirstActivePhase, hasSeenActivePhase == false {
            return
        }

        for task in plan.activeTasks {
            await task.run(runtime: runtime)
        }
    }
}

@MainActor
private struct FluelRuntimeLifecycleModifier: ViewModifier {
    @Environment(\.scenePhase)
    private var scenePhase

    @State private var lifecycle: FluelRuntimeLifecycleState

    init(
        runtime: MHAppRuntime,
        plan: MHAppRuntimeLifecyclePlan
    ) {
        _lifecycle = .init(
            initialValue: .init(
                runtime: runtime,
                plan: plan
            )
        )
    }

    func body(content: Content) -> some View {
        content
            .task {
                await lifecycle.handleInitialAppearance()
            }
            .onChange(of: scenePhase) { _, newPhase in
                Task { @MainActor in
                    await lifecycle.handleScenePhase(newPhase)
                }
            }
    }
}

extension View {
    @MainActor
    func mhAppRuntimeLifecycle(
        runtime: MHAppRuntime,
        plan: MHAppRuntimeLifecyclePlan = .empty
    ) -> some View {
        modifier(
            FluelRuntimeLifecycleModifier(
                runtime: runtime,
                plan: plan
            )
        )
    }
}
