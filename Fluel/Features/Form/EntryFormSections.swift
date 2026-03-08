import FluelLibrary
import MHUI
import PhotosUI
import SwiftUI

struct EntryFormTitleSection: View {
    @Binding var title: String

    var body: some View {
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
    }
}

struct EntryFormStartSection: View {
    @Binding var draft: EntryFormDraft

    var body: some View {
        Section {
            Picker(
                FluelCopy.precisionLabel(),
                selection: $draft.precision
            ) {
                Text(FluelCopy.day())
                    .tag(EntryDatePrecision.day)
                Text(FluelCopy.month())
                    .tag(EntryDatePrecision.month)
                Text(FluelCopy.year())
                    .tag(EntryDatePrecision.year)
            }
            .pickerStyle(.segmented)

            switch draft.precision {
            case .day:
                DatePicker(
                    FluelCopy.dayField(),
                    selection: daySelection,
                    in: ...draft.currentDate,
                    displayedComponents: .date
                )
            case .month:
                Picker(
                    FluelCopy.yearField(),
                    selection: $draft.year
                ) {
                    ForEach(draft.yearRange, id: \.self) { year in
                        Text("\(year)")
                            .tag(year)
                    }
                }

                Picker(
                    FluelCopy.monthField(),
                    selection: $draft.month
                ) {
                    ForEach(draft.availableMonths, id: \.value) { item in
                        Text(item.label)
                            .tag(item.value)
                    }
                }
            case .year:
                Picker(
                    FluelCopy.yearField(),
                    selection: $draft.year
                ) {
                    ForEach(draft.yearRange, id: \.self) { year in
                        Text("\(year)")
                            .tag(year)
                    }
                }
            }
        } header: {
            Text(FluelCopy.startSectionTitle())
        } footer: {
            if let startSectionFooterText = draft.startSectionFooterText {
                Text(startSectionFooterText)
            }
        }
    }
}

struct EntryFormPhotoSection: View {
    @Binding var draft: EntryFormDraft
    @Binding var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        let photoButtonTitle = draft.photoData == nil
            ? FluelCopy.choosePhoto()
            : FluelCopy.edit()

        Section {
            if let image = draft.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )
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

            if draft.photoData != nil {
                Button(
                    FluelCopy.removePhoto(),
                    role: .destructive
                ) {
                    draft.removePhoto()
                    selectedPhotoItem = nil
                }
                .buttonStyle(.mhDestructive)
            }
        } header: {
            Text(FluelCopy.photoSectionTitle())
        }
    }
}

struct EntryFormNoteSection: View {
    @Binding var note: String
    let footerText: String
    let onClear: () -> Void

    var body: some View {
        Section {
            TextEditor(text: $note)
                .frame(minHeight: 120)
                .mhInputChrome()

            if note.isEmpty == false {
                Button(
                    FluelCopy.clearNote(),
                    role: .destructive
                ) {
                    onClear()
                }
                .buttonStyle(.mhDestructive)
            }
        } header: {
            Text(FluelCopy.noteSectionTitle())
        } footer: {
            Text(footerText)
        }
    }
}

private extension EntryFormStartSection {
    var daySelection: Binding<Date> {
        .init(
            get: {
                draft.selectedDate
            },
            set: { newValue in
                draft.updateSelectedDate(newValue)
            }
        )
    }
}
