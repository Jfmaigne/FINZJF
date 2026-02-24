import SwiftUI
import CoreData

// Redundant conformance removed. BudgetEntryOccurrence already conforms to Identifiable.
// extension BudgetEntryOccurrence: Identifiable { }

struct RecettesFixesSheet: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var occurrences: [BudgetEntryOccurrence] = []
    @State private var editedOccurrence: BudgetEntryOccurrence?
    @State private var showEditSheet: Bool = false
    
    private let monthKey = BudgetProjectionManager.monthKey(for: Date())
    
    private func todayInsertionIndex(in items: [BudgetEntryOccurrence]) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        for (idx, item) in items.enumerated() {
            if let d = item.date {
                let day = cal.startOfDay(for: d)
                if day >= today {
                    return idx
                }
            }
        }
        return items.count
    }

    private struct TodaySeparatorView: View {
        var body: some View {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 1)
                Text("Aujourd’hui")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.52, green: 0.21, blue: 0.93).opacity(0.12),
                                        Color(red: 1.00, green: 0.29, blue: 0.63).opacity(0.12)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundColor(Color.secondary)
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 1)
            }
            .padding(.vertical, 4)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Recettes fixes
                if !fixedIncomes.isEmpty {
                    Section(header: Text("Recettes fixes").font(.headline)) {
                        let fixedIdx = todayInsertionIndex(in: fixedIncomes)
                        ForEach(Array(fixedIncomes.enumerated()), id: \.element.id) { offset, occurrence in
                            if offset == fixedIdx {
                                TodaySeparatorView()
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowSeparator(.hidden)
                            }
                            RowView(occurrence: occurrence, onEdit: { startEditing(occurrence) }) {
                                deleteOccurrence(occurrence)
                            }
                        }
                        if fixedIdx == fixedIncomes.count {
                            TodaySeparatorView()
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowSeparator(.hidden)
                        }
                    }
                }

                // Recettes complémentaires
                if !complementaryIncomes.isEmpty {
                    Section(header: Text("Recettes complémentaires").font(.headline)) {
                        let compIdx = todayInsertionIndex(in: complementaryIncomes)
                        ForEach(Array(complementaryIncomes.enumerated()), id: \.element.id) { offset, occurrence in
                            if offset == compIdx {
                                TodaySeparatorView()
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowSeparator(.hidden)
                            }
                            RowView(occurrence: occurrence, onEdit: { startEditing(occurrence) }) {
                                deleteOccurrence(occurrence)
                            }
                        }
                        if compIdx == complementaryIncomes.count {
                            TodaySeparatorView()
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(.compact)
            .navigationTitle("Recettes du mois")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear(perform: fetchOccurrences)
            .sheet(isPresented: $showEditSheet) {
                if let occurrence = editedOccurrence {
                    EditOccurrenceSheet(occurrence: occurrence) { updated in
                        // Save changes to Core Data and refresh
                        do {
                            try context.save()
                            fetchOccurrences()
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } catch {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            print("Failed to save occurrence: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    private var fixedIncomes: [BudgetEntryOccurrence] {
        occurrences.filter { $0.kind == "income" && $0.isManual == false }
    }
    private var complementaryIncomes: [BudgetEntryOccurrence] {
        occurrences.filter { $0.kind == "income" && $0.isManual == true }
    }
    
    private func fetchOccurrences() {
        let request = BudgetEntryOccurrence.fetchRequest()
        request.predicate = NSPredicate(format: "monthKey == %@", monthKey)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BudgetEntryOccurrence.date, ascending: true)]
        do {
            occurrences = try context.fetch(request)
        } catch {
            occurrences = []
        }
    }

    private func deleteOccurrence(_ occurrence: BudgetEntryOccurrence) {
        context.delete(occurrence)
        do {
            try context.save()
            // Refresh the list after deletion
            fetchOccurrences()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Failed to delete occurrence: \(error.localizedDescription)")
            // Optionally show an alert to the user
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func startEditing(_ occurrence: BudgetEntryOccurrence) {
        editedOccurrence = occurrence
        showEditSheet = true
    }

    private struct RowView: View {
        let occurrence: BudgetEntryOccurrence
        let onEdit: () -> Void
        let onDelete: () -> Void // Closure to perform deletion
        
        var body: some View {
            HStack {
                Text(dateFormatted(occurrence.date))
                    .font(.callout)
                    .frame(width: 70, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(occurrence.title ?? "")
                        .font(.body)
                    // The description seems to be stored in `title` as well,
                    // based on `AddOperationQuickSheet`. Let's assume `complement` or `provider`
                    // might be used for additional detail if available, or just the main title.
                    // For now, if the title holds both, we might want to parse it or decide.
                    // Assuming for now `title` is the main thing and `comment` or `provider`
                    // would be separate fields if desired.
                    // If `title` sometimes contains "Catégorie - Description",
                    // you might want a more sophisticated parsing here.
                    // For now, just show the main title.
                }
                Spacer()
                Text(amountFormatted(occurrence.amount))
                    .font(.body.monospacedDigit())
                    .foregroundColor(.green)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
            )
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    onEdit()
                } label: {
                    Label("Modifier", systemImage: "pencil")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        
        private func dateFormatted(_ date: Date?) -> String {
            guard let date = date else { return "" }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date)
        }
        
        private func amountFormatted(_ amount: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "EUR"
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            formatter.positivePrefix = "+"
            return formatter.string(from: NSNumber(value: amount)) ?? "+\(Int(amount))"
        }
    }
}

struct RecettesFixesSheet_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Ensure the month key exists for the preview
        let currentMonthKey = BudgetProjectionManager.monthKey(for: Date())

        // Clear existing occurrences for the current month key to ensure a clean preview state
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BudgetEntryOccurrence.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "monthKey == %@", currentMonthKey)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        try? context.save()

        // Create example fixed income
        let fixedIncome = BudgetEntryOccurrence(context: context)
        fixedIncome.id = UUID() // Assign a unique ID
        fixedIncome.kind = "income"
        fixedIncome.isManual = false
        fixedIncome.monthKey = currentMonthKey
        fixedIncome.date = Date()
        fixedIncome.title = "Salaire (Entreprise XYZ)" // Updated title to include both parts for demonstration
        fixedIncome.amount = 2500
        
        // Create example complementary income
        let complementaryIncome = BudgetEntryOccurrence(context: context)
        complementaryIncome.id = UUID() // Assign a unique ID
        complementaryIncome.kind = "income"
        complementaryIncome.isManual = true
        complementaryIncome.monthKey = currentMonthKey
        complementaryIncome.date = Calendar.current.date(byAdding: .day, value: 5, to: Date())
        complementaryIncome.title = "Vente occasionnelle (vélo)" // Updated title for demonstration
        complementaryIncome.amount = 150
        
        // Save the context to ensure occurrences are available for the sheet
        try? context.save()

        return RecettesFixesSheet()
            .environment(\.managedObjectContext, context)
    }
}

private struct EditOccurrenceSheet: View {
    @ObservedObject var occurrence: BudgetEntryOccurrence
    var onSave: (BudgetEntryOccurrence) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var amount: Double = 0
    @State private var date: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Informations") {
                    TextField("Titre", text: $title)
                    TextField("Montant", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Modifier")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        occurrence.title = title
                        occurrence.amount = amount
                        occurrence.date = date
                        occurrence.isManual = true
                        onSave(occurrence)
                        dismiss()
                    }
                }
            }
            .onAppear {
                title = occurrence.title ?? ""
                amount = occurrence.amount
                date = occurrence.date ?? Date()
            }
        }
    }
}

