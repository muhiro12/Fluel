enum FluelMutationResult: Equatable {
    case success
    case degradedSuccess(message: String)
    case failure(FluelMutationFailure)
}
