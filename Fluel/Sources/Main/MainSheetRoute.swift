enum MainSheetRoute: Equatable, Identifiable {
    case create(presetID: String?)
    case licenses

    var id: String {
        switch self {
        case let .create(presetID):
            if let presetID {
                return "create-\(presetID)"
            }

            return "create"
        case .licenses:
            return "licenses"
        }
    }
}
