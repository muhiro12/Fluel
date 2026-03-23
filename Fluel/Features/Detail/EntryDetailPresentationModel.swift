import Observation

@MainActor
@Observable
final class EntryDetailPresentationModel {
    enum Effect: Equatable {
        case idle
        case dismiss
    }

    enum SheetRoute: Identifiable, Equatable {
        case edit
        case duplicate

        var id: String {
            switch self {
            case .edit:
                return "edit"
            case .duplicate:
                return "duplicate"
            }
        }
    }

    var errorMessage: String?
    var isConfirmingDelete = false
    var sheetRoute: SheetRoute?

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

    func presentDeleteConfirmation() {
        isConfirmingDelete = true
    }

    func dismissDeleteConfirmation() {
        isConfirmingDelete = false
    }

    func presentEdit() {
        sheetRoute = .edit
    }

    func presentDuplicate() {
        sheetRoute = .duplicate
    }

    func dismissSheet() {
        sheetRoute = nil
    }
}
