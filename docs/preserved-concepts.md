# Preserved Concepts

## Preservation Rule

Preserve product concepts and user value. Discard implementation details.

The existing code, tests, localizations, history, and design notes should be
read as evidence of intent, not as a rebuild blueprint.

## Concepts To Preserve

### Entry

An entry is one thing or place the user has been living with over time.

An entry should have:

- A user-facing title.
- A start point.
- A known precision for that start point.
- Optional note content.
- Optional photo content.
- An active or archived state.

### Things And Places

The product centers ordinary belongings and places, not abstract tasks or
events. Preserved examples include wallet, bag, shoes, watch, notebook, plant,
furniture, and this home.

### Time Together

The core display concept is time together: how long an entry has been with the
user since its start point.

This concept should remain more prominent than raw dates.

### Known Precision

The user may know the start to the exact day, to the month, or only to the
year. The product should preserve that precision rather than forcing fake
exactness.

Approximate starts should be clearly labeled.

### Active Entries

Active entries are things or places still with the user in daily life.

The active list should support browsing, sorting, searching, filtering, quick
creation, and opening details.

### Archived Entries

Archived entries are things or places no longer part of daily life but still
worth keeping readable and separate.

Archived entries may be restored. Permanent deletion should be a deliberate
action and should apply only after archiving.

### Notes And Photos

Notes and photos add lightweight memory to an entry. They are optional and
should not become required fields.

The tone of note capture should stay small and low-pressure.

### Detail Review

The detail experience should let the user focus on one entry's elapsed time,
start information, precision, total days or months where meaningful, note,
photo, and archive state.

The user should be able to share, duplicate, edit, archive, restore, and, when
archived, delete from this context.

### Dashboard

The dashboard is the product's overview surface. It should show the whole
shape of the collection: counts, active and archived state, note and photo
presence, the longest-running active entry, upcoming milestones, and recent
activity.

### Timeline

The timeline lets the user read back the quiet sequence of entries being
added, adjusted, and archived.

It should support activity kind filters, time scope filters, search, summary,
monthly trends, timeline-scoped milestone highlights, and sharing.

### Milestones

Milestones are upcoming yearly anniversaries for active entries. They should
show what duration is coming, how many days remain, and whether the start is
approximate.

### Presets

Presets are reusable starting points for familiar things or places. They help
new entries begin closer to the user's usual shape.

Preserve built-in starter presets, custom presets, pinned presets, recent
presets, and an optional default preset.

### Guidance

Hints should help users discover the product gently. Important hint topics are
creating the first entry, reusing presets, filtering, reading the timeline,
understanding the dashboard, keeping detail actions close, choosing precision,
managing presets, and using a default preset.

### Display Preferences

The user should be able to adjust how much supporting information is surfaced,
including list summary cards, note previews, metadata badges, and dashboard
highlights.

### Widget-Style Glance

The glanceable surface should show the longest-running active entry and nearby
highlights. The preserved product concept is passive status at a glance, not
the old widget implementation.

## Implementation Details To Discard

Do not preserve these as rebuild requirements:

- The existing Xcode project.
- The existing source file structure.
- Target, module, type, property, or parameter names.
- SwiftUI view hierarchy.
- Screen model or router structure.
- SwiftData schema details.
- Persistence container details.
- App Group identifiers.
- Widget scheduling details.
- Tip framework implementation.
- Photos picker implementation.
- Share implementation.
- Third-party packages and design-system dependencies.
- CI scripts, verification scripts, and repository guard scripts.
- Architecture decision records that describe module boundaries.
- Workarounds, temporary debug paths, diagnostics plumbing, and capture flows.

Preserve only the user-facing concepts those details were trying to support.
