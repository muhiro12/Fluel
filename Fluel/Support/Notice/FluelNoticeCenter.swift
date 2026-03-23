import Observation

@MainActor
@Observable
final class FluelNoticeCenter {
    var activeNotice: FluelNotice?

    func presentWarning(
        message: String
    ) {
        activeNotice = .init(
            message: message,
            style: .warning
        )
    }

    func dismiss() {
        activeNotice = nil
    }

    func dismiss(
        id: FluelNotice.ID
    ) {
        guard activeNotice?.id == id else {
            return
        }

        activeNotice = nil
    }
}
