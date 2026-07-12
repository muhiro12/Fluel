#!/usr/bin/env python3

import json
import re
import sys
from pathlib import Path


REQUIRED_LOCALES = ("en", "ja")
STRING_KEY_PATTERN = re.compile(r'^"((?:\\.|[^"\\])*)"\s*=')


def catalog_failures(path: Path) -> list[str]:
    failures: list[str] = []

    try:
        catalog = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        return [f"{path}: invalid JSON ({error})"]

    if catalog.get("sourceLanguage") != "en":
        failures.append(f"{path}: sourceLanguage must be en")

    for key, entry in catalog.get("strings", {}).items():
        if entry.get("extractionState") == "stale":
            failures.append(f"{path}: {key!r} is stale and should be removed")

        if entry.get("shouldTranslate") is False:
            continue

        localizations = entry.get("localizations", {})

        for locale in REQUIRED_LOCALES:
            localization = localizations.get(locale)

            if localization is None:
                failures.append(f"{path}: {key!r} is missing locale {locale}")
                continue

            states = localization_states(localization)

            if not states:
                failures.append(f"{path}: {key!r} has no translation state for {locale}")
            elif any(state != "translated" for state in states):
                failures.append(
                    f"{path}: {key!r} has non-translated state for {locale}: "
                    f"{', '.join(sorted(states))}"
                )

    return failures


def localization_states(value: object) -> set[str]:
    if isinstance(value, dict):
        states = {
            state
            for key, child in value.items()
            if key == "state" and isinstance(child, str)
            for state in [child]
        }

        for child in value.values():
            states.update(localization_states(child))

        return states

    if isinstance(value, list):
        states: set[str] = set()

        for child in value:
            states.update(localization_states(child))

        return states

    return set()


def strings_keys(path: Path) -> tuple[set[str], list[str]]:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as error:
        return set(), [f"{path}: could not be read ({error})"]

    keys: set[str] = set()
    failures: list[str] = []

    for line_number, line in enumerate(lines, start=1):
        stripped_line = line.strip()

        if not stripped_line or stripped_line.startswith("/*"):
            continue

        match = STRING_KEY_PATTERN.match(stripped_line)

        if match is None:
            failures.append(f"{path}:{line_number}: unsupported .strings syntax")
            continue

        key = match.group(1)

        if key in keys:
            failures.append(f"{path}:{line_number}: duplicate key {key!r}")

        keys.add(key)

    return keys, failures


def library_failures(repository_root: Path) -> list[str]:
    resources = repository_root / "FluelLibrary" / "Sources" / "Resources"
    paths = {
        locale: resources / f"{locale}.lproj" / "Localizable.strings"
        for locale in REQUIRED_LOCALES
    }
    failures: list[str] = []
    keys_by_locale: dict[str, set[str]] = {}

    for locale, path in paths.items():
        if not path.is_file():
            failures.append(f"{path}: missing required library localization")
            continue

        keys, read_failures = strings_keys(path)
        keys_by_locale[locale] = keys
        failures.extend(read_failures)

    if len(keys_by_locale) == len(REQUIRED_LOCALES):
        reference_locale = REQUIRED_LOCALES[0]
        reference_keys = keys_by_locale[reference_locale]

        for locale in REQUIRED_LOCALES[1:]:
            missing_keys = sorted(reference_keys - keys_by_locale[locale])
            extra_keys = sorted(keys_by_locale[locale] - reference_keys)

            for key in missing_keys:
                failures.append(f"{paths[locale]}: missing key {key!r}")

            for key in extra_keys:
                failures.append(f"{paths[locale]}: unexpected key {key!r}")

    return failures


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: check_localizations.py <repository-root>", file=sys.stderr)
        return 2

    repository_root = Path(sys.argv[1]).resolve()
    catalog_paths = sorted(repository_root.glob("Fluel/Resources/*.xcstrings"))
    failures: list[str] = []

    if not catalog_paths:
        failures.append("Fluel/Resources: no String Catalogs found")

    for path in catalog_paths:
        failures.extend(catalog_failures(path))

    failures.extend(library_failures(repository_root))

    if failures:
        print("Localization check failed:", file=sys.stderr)

        for failure in failures:
            print(f"- {failure}", file=sys.stderr)

        return 1

    print(
        "Localization check passed "
        f"({len(catalog_paths)} catalogs; locales: {', '.join(REQUIRED_LOCALES)})."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
