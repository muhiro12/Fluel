import Foundation

struct FluelNotice: Equatable, Identifiable {
    let id: UUID
    let message: String
    let style: FluelNoticeStyle

    init(
        message: String,
        style: FluelNoticeStyle,
        id: UUID = .init()
    ) {
        self.id = id
        self.message = message
        self.style = style
    }
}
