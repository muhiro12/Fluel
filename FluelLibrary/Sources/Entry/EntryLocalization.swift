import Foundation

enum EntryLocalization {
    static func string(_ key: String) -> String {
        Bundle.module.localizedString(forKey: key, value: key, table: nil)
    }

    static func format(
        _ key: String,
        _ arguments: CVarArg...
    ) -> String {
        String(
            format: string(key),
            locale: .autoupdatingCurrent,
            arguments: arguments
        )
    }

    static func duration(
        value: Int,
        singularKey: String,
        pluralKey: String
    ) -> String {
        let unitKey = value == 1 ? singularKey : pluralKey

        return format(
            "duration.value.unit",
            value.formatted(),
            string(unitKey)
        )
    }
}
