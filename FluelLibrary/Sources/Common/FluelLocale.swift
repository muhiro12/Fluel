import Foundation

enum FluelLocale: Equatable {
    case english
    case japanese

    init(locale: Locale) {
        let languageIdentifier = locale.language.languageCode?.identifier ?? locale.identifier

        if languageIdentifier.hasPrefix("ja") {
            self = .japanese
        } else {
            self = .english
        }
    }

    func numberText(_ value: Int, locale: Locale) -> String {
        value.formatted(
            .number
                .locale(locale)
        )
    }

    func join(_ parts: [String]) -> String {
        switch self {
        case .english:
            return parts.joined(separator: ", ")
        case .japanese:
            return parts.joined()
        }
    }

    func yearUnit(_ value: Int, locale: Locale) -> String {
        let number = numberText(value, locale: locale)

        switch self {
        case .english:
            if value == 1 {
                return "\(number) year"
            }

            return "\(number) years"
        case .japanese:
            return "\(number)年"
        }
    }

    func monthUnit(_ value: Int, locale: Locale) -> String {
        let number = numberText(value, locale: locale)

        switch self {
        case .english:
            if value == 1 {
                return "\(number) month"
            }

            return "\(number) months"
        case .japanese:
            return "\(number)か月"
        }
    }

    func dayUnit(_ value: Int, locale: Locale) -> String {
        let number = numberText(value, locale: locale)

        switch self {
        case .english:
            if value == 1 {
                return "\(number) day"
            }

            return "\(number) days"
        case .japanese:
            return "\(number)日"
        }
    }
}
