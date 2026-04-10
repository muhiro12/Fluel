#if DEBUG
import MHPlatform

struct FluelRecordedLogEvent: Equatable, Sendable {
    let level: String
    let category: String
    let message: String
    let metadata: [String: String]

    init(
        event: MHLogEvent
    ) {
        level = event.level.name
        category = event.category
        message = event.message
        metadata = event.metadata
    }
}
#endif
