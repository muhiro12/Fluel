# Domain Concepts

## Entry

An entry represents one thing or place the user has been living with over
time.

Essential fields as product concepts:

- Title: the non-empty name the user gives the thing or place.
- Start: when the relationship began.
- Precision: how exactly the start is known.
- Note: an optional small memory or description.
- Photo: an optional visual memory.
- Archive state: whether the entry is still part of daily life.
- Created and updated moments: useful for activity history.

These are domain concepts, not storage schema requirements.

## Start And Precision

The start can be known at three levels:

- Day: an exact calendar date.
- Month: sometime within a known month.
- Year: sometime within a known year.

The product should never require users to invent a precise day when they only
know the month or year.

Future starts are not valid. The start should be today or earlier.

## Approximate Starts

Month and year starts are approximate. When deriving elapsed time or
milestones from an approximate start, the old product used the earliest
possible date in the known range. The product intent to preserve is:

- Approximate starts are allowed.
- Approximate calculations should be labeled honestly.
- The user can refine precision later if they learn more.

## Time Together

Time together is the elapsed duration from the entry's start to the relevant
reference date.

The product uses this concept in several ways:

- Primary elapsed text for rows, detail, dashboard, widget, and sharing.
- Full elapsed breakdown in detail.
- Total days when day precision is known.
- Total months when month precision is known.
- Year-only elapsed text when only the year is known.

Elapsed time should not become negative. If the start is today, this is still a
valid entry and should read as today or this month/year depending on precision.

## Active And Archived

Active means the thing or place is still with the user in daily life.

Archived means it has moved out of daily life but remains readable and
separate.

Important domain behavior:

- Active entries appear in the main current-life list.
- Archived entries appear in a separate archive.
- Archived entries can be restored.
- Permanent deletion should require the entry to be archived first.
- Archived entries can still be searched, sorted, filtered, opened, and shared.

## Notes And Photos

Notes and photos are optional supporting context.

Notes can be shown as previews and counted. Photos can be used as visual
metadata and counted. The user should be able to filter entries by note or
photo presence.

## Sorting

The product intent includes several ways to order entries.

Active entries:

- Longest together.
- Most recent start.
- Alphabetical.
- Recently updated.

Archived entries:

- Recently archived.
- Oldest archived.
- Longest together before archive.
- Alphabetical.

The default product emphasis is longest together for active entries.

## Search And Filters

Entry search should match more than the title. Preserved searchable concepts
include title, note, start date text, start precision, approximate start range,
and archive date text.

Entry list filters:

- All.
- With note.
- With photo.

Timeline filters:

- All activity.
- Added.
- Updated.
- Archived.

Timeline scope:

- Recent 6 months.
- Recent year.
- All time.

## Activity

Activity is a user-visible history derived from entry changes.

Preserved activity kinds:

- Added.
- Updated.
- Archived.

The timeline groups activity by month and can summarize the visible slice.

## Timeline Summary And Trends

The timeline should be able to show:

- How many activity items are visible out of the total.
- How many months are represented.
- Added, updated, and archived counts.
- Monthly trends across the visible activity.
- Upcoming milestones for entries visible in the current timeline context.

## Milestones

Milestones are upcoming yearly marks for active entries.

A milestone should communicate:

- The entry title.
- The milestone duration, such as 2 years.
- The date of the milestone.
- Days remaining.
- Whether the start is approximate.

Milestones should be ordered by nearest upcoming date.

## Presets

A preset is a reusable starting point for creating an entry.

Preserved preset concepts:

- Title.
- Symbol or visual cue.
- Relative start, such as started today, months ago, or years ago.
- Start precision.
- Optional note.
- Built-in or custom origin.
- Pinned status.
- Recent use.
- Optional default preset behavior.

Starter examples to preserve as product knowledge:

- This home.
- Wallet.
- Bag.
- Shoes.
- Watch.
- Plant.
- Notebook.

Furniture also appears as a sample ordinary thing and should remain part of
the product's example language.

Desk lamp appears as a sample archived ordinary thing. Preserve it as example
vocabulary for a small household object whose daily-life presence can later
move into the archive.

## Sharing

Sharing exists for one entry and for a timeline slice.

Entry sharing should include the title, time together, start label, approximate
start range when relevant, known precision, note when present, and archive
state when relevant.

Timeline sharing should include filter and scope context, summary counts,
monthly trends when present, and upcoming milestones when present.
