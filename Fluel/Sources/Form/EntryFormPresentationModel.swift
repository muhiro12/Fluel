import Observation

@MainActor
@Observable
final class EntryFormPresentationModel {
    enum Effect: Equatable {
        case idle
        case dismiss
    }

    var errorMessage: String?
    var isConfirmingDiscard = false

    func handle(
        _ result: FluelMutationResult,
        noticeCenter: FluelNoticeCenter
    ) -> Effect {
        switch result {
        case .success:
            errorMessage = nil
            return .dismiss
        case let .degradedSuccess(message):
            errorMessage = nil
            noticeCenter.presentWarning(message: message)
            return .dismiss
        case let .failure(failure):
            errorMessage = failure.message
            return .idle
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func requestDiscardConfirmation() {
        isConfirmingDiscard = true
    }

    func dismissDiscardConfirmation() {
        isConfirmingDiscard = false
    }
}
