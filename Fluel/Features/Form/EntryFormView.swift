import FluelLibrary
import MHUI
import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct EntryFormView: View {
    enum Mode {
        case create
        case edit(Entry)
    }

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context

    @State private var title: String
    @State private var precision: EntryDatePrecision
    @State private var selectedDate: Date
    @State private var year: Int
    @State private var month: Int
    @State private var note: String
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var errorMessage: String?

    private let mode: Mode
    private let currentDate: Date
    private let calendar: Calendar

    init(
        mode: Mode,
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.mode = mode
        self.currentDate = currentDate
        self.calendar = calendar

        let resolvedEntry: Entry?

        switch mode {
        case .create:
            resolvedEntry = nil
        case let .edit(entry):
            resolvedEntry = entry
        }

        let defaultDate = resolvedEntry?.startComponents.earliestDate(calendar: calendar) ?? currentDate

        _title = State(initialValue: resolvedEntry?.title ?? String())
        _precision = State(initialValue: resolvedEntry?.startPrecision ?? .day)
        _selectedDate = State(initialValue: defaultDate)
        _year = State(initialValue: resolvedEntry?.startYear ?? calendar.component(.year, from: currentDate))
        _month = State(initialValue: resolvedEntry?.startMonth ?? calendar.component(.month, from: currentDate))
        _note = State(initialValue: resolvedEntry?.note ?? String())
        _photoData = State(initialValue: resolvedEntry?.photoData)
    }

    var body: some View {
        let photoButtonTitle = photoData == nil
            ? FluelCopy.choosePhoto()
            : FluelCopy.edit()

        Form {
            Section {
                TextField(
                    FluelCopy.titlePlaceholder(),
                    text: $title
                )
                .textInputAutocapitalization(.words)
                .mhInputChrome()
            } header: {
                Text(FluelCopy.titleFieldLabel())
            } footer: {
                Text(FluelCopy.titleFooter())
            }

            Section {
                Picker(
                    FluelCopy.precisionLabel(),
                    selection: $precision
                ) {
                    Text(FluelCopy.day())
                        .tag(EntryDatePrecision.day)
                    Text(FluelCopy.month())
                        .tag(EntryDatePrecision.month)
                    Text(FluelCopy.year())
                        .tag(EntryDatePrecision.year)
                }
                .pickerStyle(.segmented)

                switch precision {
                case .day:
                    DatePicker(
                        FluelCopy.dayField(),
                        selection: daySelection,
                        in: ...currentDate,
                        displayedComponents: .date
                    )
                case .month:
                    Picker(
                        FluelCopy.yearField(),
                        selection: $year
                    ) {
                        ForEach(yearRange, id: \.self) { year in
                            Text("\(year)")
                                .tag(year)
                        }
                    }

                    Picker(
                        FluelCopy.monthField(),
                        selection: $month
                    ) {
                        ForEach(availableMonths, id: \.value) { item in
                            Text(item.label)
                                .tag(item.value)
                        }
                    }
                case .year:
                    Picker(
                        FluelCopy.yearField(),
                        selection: $year
                    ) {
                        ForEach(yearRange, id: \.self) { year in
                            Text("\(year)")
                                .tag(year)
                        }
                    }
                }
            } header: {
                Text(FluelCopy.startSectionTitle())
            }

            Section {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images
                ) {
                    Label(
                        photoButtonTitle,
                        systemImage: "photo"
                    )
                }
                .buttonStyle(.mhSecondary)

                if photoData != nil {
                    Button(
                        FluelCopy.removePhoto(),
                        role: .destructive
                    ) {
                        photoData = nil
                        selectedPhotoItem = nil
                    }
                    .buttonStyle(.mhDestructive)
                }
            } header: {
                Text(FluelCopy.photoSectionTitle())
            }

            Section {
                TextEditor(text: $note)
                    .frame(minHeight: 120)
                    .mhInputChrome()

                if note.isEmpty == false {
                    Button(
                        FluelCopy.clearNote(),
                        role: .destructive
                    ) {
                        note = String()
                    }
                    .buttonStyle(.mhDestructive)
                }
            } header: {
                Text(FluelCopy.noteSectionTitle())
            } footer: {
                Text(noteFooterText)
            }
        }
        .mhFormChrome(
            title: Text(navigationTitle),
            subtitle: Text(screenSubtitle)
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(FluelCopy.cancel()) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button(FluelCopy.save()) {
                    save()
                }
                .bold()
                .disabled(canSave == false)
            }
        }
        .onChange(of: selectedPhotoItem) {
            Task {
                await loadSelectedPhotoIfNeeded()
            }
        }
        .onChange(of: precision) {
            syncSelectionsForPrecision()
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

    private var navigationTitle: String {
        switch mode {
        case .create:
            return FluelCopy.add()
        case .edit:
            return FluelCopy.edit()
        }
    }

    private var screenSubtitle: String {
        switch mode {
        case .create:
            return FluelCopy.createScreenSubtitle()
        case .edit:
            return FluelCopy.editScreenSubtitle()
        }
    }

    private var canSave: Bool {
        do {
            _ = try input.resolvedStartComponents(
                referenceDate: currentDate,
                calendar: calendar
            )
            return true
        } catch {
            return false
        }
    }

    private var daySelection: Binding<Date> {
        .init(
            get: {
                selectedDate
            },
            set: { newValue in
                selectedDate = newValue
                year = calendar.component(.year, from: newValue)
                month = calendar.component(.month, from: newValue)
            }
        )
    }

    private var yearRange: [Int] {
        let currentYear = calendar.component(.year, from: currentDate)

        return Array((1_900...currentYear).reversed()) // swiftlint:disable:this no_magic_numbers
    }

    private var availableMonths: [(value: Int, label: String)] {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        let monthSymbols = formatter.monthSymbols ?? []
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        let maxMonth = year == currentYear ? currentMonth : 12

        return monthSymbols
            .prefix(maxMonth)
            .enumerated()
            .map { offset, name in
                (
                    value: offset + 1,
                    label: name
                )
            }
    }

    private var input: EntryFormInput {
        let resolvedDay: Int?

        switch precision {
        case .day:
            resolvedDay = calendar.component(.day, from: selectedDate)
        case .month, .year:
            resolvedDay = nil
        }

        return .init(
            title: title,
            startPrecision: precision,
            startYear: precision == .day
                ? calendar.component(.year, from: selectedDate)
                : year,
            startMonth: precision == .year
                ? nil
                : (precision == .day
                    ? calendar.component(.month, from: selectedDate)
                    : month),
            startDay: resolvedDay,
            photoData: photoData,
            note: note
        )
    }

    private var selectedImage: UIImage? {
        guard let photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }

    private var noteFooterText: String {
        guard let countText = EntryFormatting.noteCharacterCountText(note) else {
            return FluelCopy.notePlaceholder()
        }

        return """
        \(FluelCopy.notePlaceholder())
        \(countText)
        """
    }

    private func syncSelectionsForPrecision() {
        if precision == .day {
            selectedDate = calendar.date(
                from: .init(
                    year: year,
                    month: month,
                    day: 1
                )
            ) ?? currentDate
        }

        if precision == .year {
            month = 1
        } else {
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentYear = calendar.component(.year, from: currentDate)

            if year == currentYear {
                month = min(month, currentMonth)
            }
        }
    }

    private func save() {
        do {
            switch mode {
            case .create:
                _ = try EntryRepository.create(
                    context: context,
                    input: input,
                    now: currentDate,
                    calendar: calendar
                )
            case let .edit(entry):
                try EntryRepository.update(
                    context: context,
                    entry: entry,
                    input: input,
                    now: currentDate,
                    calendar: calendar
                )
            }

            FluelWidgetReloader.reloadAllTimelines()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadSelectedPhotoIfNeeded() async {
        guard let selectedPhotoItem else {
            return
        }

        do {
            photoData = try await selectedPhotoItem.loadTransferable(type: Data.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        EntryFormView(
            mode: .create
        )
    }
    .fluelAppStyle()
}

#Preview("Edit", traits: .modifier(FluelSampleData())) {
    let context = try! FluelSampleData.makeSharedContext()
    let entries = try! context.modelContainer.mainContext.fetch(FetchDescriptor<Entry>())

    return NavigationStack {
        EntryFormView(
            mode: .edit(EntryListOrdering.active(entries).first ?? entries[0])
        )
    }
    .modelContainer(context.modelContainer)
    .fluelAppStyle()
}
