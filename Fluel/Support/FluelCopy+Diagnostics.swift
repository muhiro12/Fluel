import Foundation

extension FluelCopy {
    static func diagnostics(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Diagnostics",
            japanese: "診断",
            locale: locale
        )
    }

    static func enableDiagnosticsMode(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Enable diagnostics mode",
            japanese: "診断モードを有効にする",
            locale: locale
        )
    }

    static func openDiagnosticsConsole(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Open diagnostics console",
            japanese: "診断コンソールを開く",
            locale: locale
        )
    }
}
