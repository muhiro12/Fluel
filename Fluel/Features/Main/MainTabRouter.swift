import Observation

@MainActor
@Observable
final class MainTabRouter {
    var homePath = [MainDestination]()
    var dashboardPath = [MainDestination]()
    var settingsPath = [MainDestination]()

    var homeSheet: MainSheetRoute?
    var timelineSheet: MainSheetRoute?
    var dashboardSheet: MainSheetRoute?
    var settingsSheet: MainSheetRoute?

    func presentHomeCreate(
        presetID: String?
    ) {
        homeSheet = .create(presetID: presetID)
    }

    func presentTimelineCreate(
        presetID: String?
    ) {
        timelineSheet = .create(presetID: presetID)
    }

    func presentDashboardCreate(
        presetID: String?
    ) {
        dashboardSheet = .create(presetID: presetID)
    }

    func presentHomeLicenses() {
        homeSheet = .licenses
    }

    func presentDashboardLicenses() {
        dashboardSheet = .licenses
    }

    func presentSettingsLicenses() {
        settingsSheet = .licenses
    }

    func showHomeArchive() {
        homePath.append(.archive)
    }

    func showDashboardArchive() {
        dashboardPath.append(.archive)
    }

    func showSettingsArchive() {
        settingsPath.append(.archive)
    }
}
