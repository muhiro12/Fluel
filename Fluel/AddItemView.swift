//
//  AddItemView.swift
//  Fluel
//
//  Created by OpenAI on 2026/03/07.
//

import SwiftData
import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var startDate = Date.now
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("対象") {
                    TextField("財布", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("開始日") {
                    DatePicker(
                        "使い始めた日",
                        selection: $startDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
            }
            .navigationTitle("追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
        .alert(
            "保存できませんでした",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("閉じる", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        let item = Item(name: trimmedName, startDate: startDate)
        modelContext.insert(item)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.delete(item)
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: Item.self, inMemory: true)
}
