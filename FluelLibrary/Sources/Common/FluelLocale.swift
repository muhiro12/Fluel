import Foundation

enum FluelLocale: Equatable {
    case english
    case japanese
    case spanish
    case french
    case simplifiedChinese

    init(locale: Locale) {
        let languageIdentifier = locale.language.languageCode?.identifier ?? locale.identifier

        if languageIdentifier.hasPrefix("ja") {
            self = .japanese
        } else if languageIdentifier.hasPrefix("es") {
            self = .spanish
        } else if languageIdentifier.hasPrefix("fr") {
            self = .french
        } else if languageIdentifier.hasPrefix("zh") {
            self = .simplifiedChinese
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
        case .english, .spanish, .french:
            return parts.joined(separator: ", ")
        case .japanese, .simplifiedChinese:
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
        case .spanish:
            if value == 1 {
                return "\(number) año"
            }

            return "\(number) años"
        case .french:
            if value == 1 {
                return "\(number) an"
            }

            return "\(number) ans"
        case .simplifiedChinese:
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
        case .spanish:
            if value == 1 {
                return "\(number) mes"
            }

            return "\(number) meses"
        case .french:
            if value == 1 {
                return "\(number) mois"
            }

            return "\(number) mois"
        case .simplifiedChinese:
            return "\(number)个月"
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
        case .spanish:
            if value == 1 {
                return "\(number) día"
            }

            return "\(number) días"
        case .french:
            if value == 1 {
                return "\(number) jour"
            }

            return "\(number) jours"
        case .simplifiedChinese:
            return "\(number)天"
        }
    }
}
