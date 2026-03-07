//
//  ContentView.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Item.startDate, order: .forward)]) private var items: [Item]
    @State private var isPresentingAddItem = false

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                Group {
                    if items.isEmpty {
                        EmptyStateView {
                            isPresentingAddItem = true
                        }
                    } else {
                        List {
                            Section {
                                ForEach(items) { item in
                                    NavigationLink {
                                        ItemDetailView(item: item)
                                    } label: {
                                        ItemRow(item: item, referenceDate: context.date)
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            } header: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("長く一緒にいる順")
                                    Text("開始日が古いものほど上に並びます。")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .textCase(nil)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("Fluel")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if items.isEmpty == false {
                            EditButton()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentingAddItem = true
                        } label: {
                            Label("追加", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddItem) {
            AddItemView()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }

            try? modelContext.save()
        }
    }
}

private struct ItemRow: View {
    let item: Item
    let referenceDate: Date

    var body: some View {
        let elapsed = ElapsedTimeSnapshot(
            startDate: item.startDate,
            referenceDate: referenceDate
        )

        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline.weight(.medium))

                Text(item.startDate, format: .dateTime.year().month().day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 6) {
                Text(elapsed.dayHeadline)
                    .font(.headline)
                    .monospacedDigit()

                Text(elapsed.compactBreakdown)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 10)
    }
}

private struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("まだ何も積もっていません")
                .font(.title2.weight(.medium))

            Text("対象と開始日を登録すると、時間が静かに積もっていきます。")
                .foregroundStyle(.secondary)

            Button("最初の対象を追加", action: onAdd)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
