import FluelLibrary
import SwiftData
import SwiftUI
import UIKit

struct EntryDetailView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context

    let entry: Entry

    @State private var errorMessage: String?
    @State private var isPresentingEditor = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let snapshot = EntryElapsedSnapshot(
                startComponents: entry.startComponents,
                referenceDate: timeline.date
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let image = entryImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.title)
                            .font(.largeTitle.weight(.medium))

                        Text(
                            EntryFormatting.startLabelText(
                                for: entry.startComponents
                            )
                        )
                        .font(.headline)
                        .foregroundStyle(.secondary)

                        if let archivedAt = entry.archivedAt {
                            Text(
                                EntryFormatting.archivedOnText(
                                    archivedAt
                                )
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(
                            EntryFormatting.primaryElapsedText(
                                for: snapshot
                            )
                        )
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)

                        Text(
                            EntryFormatting.detailElapsedText(
                                for: snapshot
                            )
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }

                    detailCard(snapshot: snapshot)

                    if let note = entry.note {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(FluelCopy.noteSectionTitle())
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(note)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(
                            Color(uiColor: .secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(
                            FluelCopy.edit()
                        ) {
                            isPresentingEditor = true
                        }

                        if entry.isArchived {
                            Button(
                                FluelCopy.restore()
                            ) {
                                restore()
                            }
                        } else {
                            Button(
                                FluelCopy.archive()
                            ) {
                                archive()
                            }
                        }
                    } label: {
                        Label(
                            FluelCopy.more(),
                            systemImage: "ellipsis.circle"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                EntryFormView(
                    mode: .edit(entry)
                )
            }
        }
        .alert(
            FluelCopy.error(),
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button(FluelCopy.ok(), role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? String())
        }
    }

    @ViewBuilder
    private func detailCard(
        snapshot: EntryElapsedSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            DetailMetricView(
                title: FluelCopy.started(),
                value: EntryFormatting.startDateText(
                    for: entry.startComponents
                )
            )

            DetailMetricView(
                title: FluelCopy.knownAs(),
                value: EntryFormatting.precisionText(
                    for: entry.startPrecision
                )
            )

            DetailMetricView(
                title: FluelCopy.elapsedInFull(),
                value: EntryFormatting.detailElapsedText(
                    for: snapshot
                )
            )

            if let totalMeasureText = EntryFormatting.totalMeasureText(
                for: snapshot
            ) {
                DetailMetricView(
                    title: snapshot.totalDays != nil
                        ? FluelCopy.totalDays()
                        : FluelCopy.totalMonths(),
                    value: totalMeasureText
                )
            }
        }
        .padding(20)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }

    private var entryImage: UIImage? {
        guard let photoData = entry.photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }

    private func archive() {
        do {
            try EntryRepository.archive(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restore() {
        do {
            try EntryRepository.restore(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct DetailMetricView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let context = try! FluelSampleData.makeSharedContext()
    let entries = try! context.modelContainer.mainContext.fetch(FetchDescriptor<Entry>())

    return NavigationStack {
        EntryDetailView(entry: EntryListOrdering.active(entries).first ?? entries[0])
    }
    .modelContainer(context.modelContainer)
}
