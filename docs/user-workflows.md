# User Workflows

## First Entry

When the user has no entries, Fluel should invite them to begin with one thing
or place they live with.

The empty state should make the first step small:

- Add one entry.
- Choose a familiar example if useful.
- Refine the date or note later.

The first-run feeling should be calm, not instructional-heavy.

## Create An Entry

The creation flow should let the user:

- Enter a non-empty title.
- Choose the start precision: day, month, or year.
- Choose a start that is today or earlier.
- Add an optional photo.
- Add an optional note.
- Use a preset as a head start.
- Save or cancel.

If the user has unsaved edits and tries to leave, the product should confirm
before discarding changes.

## Edit An Entry

Editing should let the user adjust what they know, including how precisely the
start is known.

The user should be able to refine the date later without treating the original
approximate entry as wrong.

## Browse Active Entries

The active list should show entries that are still part of daily life.

The user should be able to:

- Sort active entries.
- Search entries.
- Filter by note or photo presence.
- Clear search and filter state.
- See summary information when enabled.
- Open entry detail.
- Archive an entry.
- Start a new entry.
- Use quick presets when available.

## Review Entry Detail

Entry detail should answer the central question for one entry:

How long has this been with me?

The detail should show:

- Title.
- Photo when present.
- Time together.
- Start date.
- Start range when approximate.
- Known precision.
- Full elapsed text.
- Total days or total months where meaningful.
- Created, updated, and archived context.
- Note when present.

From detail, the user should be able to share, duplicate, edit, archive, or
restore. Permanent delete belongs only to archived entries.

## Duplicate An Entry

Duplicating should start a new create flow from an existing entry's title,
start, note, and photo.

The preserved product intent is reuse of a familiar shape. The exact copy
mechanics are not a rebuild requirement.

## Archive, Restore, And Delete

Archiving moves an entry out of daily life while keeping it readable.

The archive workflow should support:

- Opening a dedicated archive.
- Sorting archived entries.
- Searching archived entries.
- Filtering archived entries.
- Opening archived detail.
- Restoring an archived entry to active status.
- Permanently deleting an archived entry after confirmation.

Permanent deletion should feel deliberate and should not be the primary way to
remove something from the active list.

## Read The Dashboard

The dashboard should let the user see the whole shape first.

It should include:

- Total, active, and archived counts.
- Note and photo counts.
- The longest-running active entry.
- The most recently archived entry when present.
- Upcoming milestones.
- Recent activity.
- Quick actions such as adding, opening archive, opening licenses, and using
  presets.

The dashboard is an overview, not a replacement for detail.

## Read The Timeline

The timeline should let the user read back the quiet sequence of entries being
added, adjusted, and archived.

The user should be able to:

- Filter by activity kind.
- Filter by time scope.
- Search by entry title or activity kind.
- Clear active search or filters.
- Read activity grouped by month.
- See a summary of the visible slice.
- See monthly trends.
- See upcoming milestones related to visible activity.
- Share the current timeline summary.

## Use Presets

Presets help the user begin from a familiar thing or place.

The user should be able to:

- Use starter presets.
- Create custom presets.
- Edit custom presets.
- Delete custom presets after confirmation.
- Pin presets.
- Reuse recent presets.
- Choose one default preset so new entries opened from Add begin with it.

Pinning, unpinning, setting a default preset, and clearing a default preset
should give clear non-blocking confirmation.

Presets should feel like reusable starts, not templates that force rigid data.

## Adjust Settings

Settings should let the user adjust how Fluel surfaces information.

Preserved settings concepts:

- Toggle list summary cards.
- Toggle note previews.
- Toggle metadata badges.
- Toggle dashboard highlights.
- Reset display preferences.
- Open preset management.
- View basic data status.
- Open archived entries.
- Open licenses or support-related surfaces.
- Show hints again.

Resetting display preferences and showing hints again should give clear
non-blocking confirmation.

Diagnostics and internal logging are not product concepts to preserve unless a
future product decision makes them user-facing.

## Glance Outside The App

The widget-style glance should let the user see the longest-running active
entry without opening the app.

Small glance:

- Entry title.
- Primary elapsed time.
- Start label.
- Active count.

Larger glance:

- Active and archived counts.
- Note and photo counts.
- Upcoming milestone.
- Recent activity.
- Recently archived entry when present.
