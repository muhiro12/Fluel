import Foundation

public enum FluelLocalization {
    public static func string(
        key: String,
        defaultValue: String,
        japaneseFallback: String? = nil,
        bundle: Bundle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let localizedBundle = bundle.localizedBundle(for: locale)
        let value = localizedBundle.localizedString(
            forKey: key,
            value: defaultValue,
            table: nil
        )

        if FluelLocale(locale: locale) == .japanese,
           value == defaultValue,
           let japaneseFallback {
            return japaneseFallback
        }

        return value
    }

    public static func formattedString(
        key: String,
        defaultValue: String,
        japaneseFallback: String? = nil,
        bundle: Bundle,
        locale: Locale = .autoupdatingCurrent,
        arguments: [CVarArg]
    ) -> String {
        let format = string(
            key: key,
            defaultValue: defaultValue,
            japaneseFallback: japaneseFallback,
            bundle: bundle,
            locale: locale
        )

        return String(
            format: format,
            locale: locale,
            arguments: arguments
        )
    }
}

private extension Bundle {
    func localizedBundle(
        for locale: Locale
    ) -> Bundle {
        guard let localization = localizationIdentifier(for: locale),
              let path = path(forResource: localization, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self
        }

        return bundle
    }

    func localizationIdentifier(
        for locale: Locale
    ) -> String? {
        switch FluelLocale(locale: locale) {
        case .english:
            return "en"
        case .japanese:
            return "ja"
        case .spanish:
            return "es"
        case .french:
            return "fr"
        case .simplifiedChinese:
            return "zh-Hans"
        }
    }
}
