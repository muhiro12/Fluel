enum FluelMutationFailurePhase: String, Equatable {
    case preflight
    case primaryMutation
    case postCommitFollowUp
}
