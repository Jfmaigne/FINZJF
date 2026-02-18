import SwiftUI
import CoreData

private enum OverlayOperationKind: String, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .income: return "arrow.up.right.circle.fill"
        case .expense: return "arrow.down.right.circle.fill"
        }
    }
    var displayName: String {
        switch self {
        case .income: return "Recette"
        case .expense: return "Dépense"
        }
    }
}

struct AddOperationOverlay: View {
    let defaultDate: Date
    let onSaved: () -> Void
    let onCancel: () -> Void

    @Environment(\.managedObjectContext) private var context

    @State private var kind: OverlayOperationKind = .income
    @State private var amountText: String = ""
    @State private var selectedMonth: Int
    @State private var selectedDay: Int
    @State private var selectedYear: Int
    @State private var category: String = ""
    @State private var descriptionText: String = ""
    @State private var error: String?

    private let incomeCategories = ["Salaire", "Vente", "Prime", "Bourse", "Autres"]
    private let expenseCategories = ["Nourriture", "Logement", "Transport", "Divertissement", "Abonnement", "Autres"]

    init(defaultDate: Date, onSaved: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.defaultDate = defaultDate
        self.onSaved = onSaved
        self.onCancel = onCancel
        let cal = Calendar.current
        _selectedMonth = State(initialValue: cal.component(.month, from: defaultDate))
        _selectedDay = State(initialValue: cal.component(.day, from: defaultDate))
        _selectedYear = State(initialValue: cal.component(.year, from: defaultDate))
    }

    var body: some View {
        VStack(spacing: 14) {
            Text("Nouvelle opération")
                .font(.title3).bold()
                .padding(.top, 12)

            // Kind segmented buttons
            HStack(spacing: 10) {
                kindButton(.income)
                kindButton(.expense)
            }
            .padding(.horizontal)

            // Amount
            HStack(spacing: 8) {
                TextField("Montant", text: $amountText)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .frame(maxWidth: 120)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                Text("€")
                    .font(.title3).bold()
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            // Date row
            HStack(spacing: 10) {
                Picker("Mois", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { m in
                        Text(String(m)).tag(m)
                    }
                }
                .pickerStyle(.menu)
                Stepper("Jour \(selectedDay)", value: $selectedDay, in: 1...maxDay(in: selectedMonth, year: selectedYear))
                Text("\(selectedYear)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Category
            HStack {
                Text("Catégorie")
                Spacer()
                Picker("Catégorie", selection: $category) {
                    ForEach(currentCategories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 180)
            }
            .padding(.horizontal)

            // Description (optional)
            TextField("Description (optionnel)", text: $descriptionText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }

            HStack(spacing: 16) {
                Button { onCancel() } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                Spacer()
                Button {
                    save()
                } label: {
                    Text("Enregistrer").bold()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding([.horizontal, .bottom], 16)
        }
        .frame(maxWidth: 360)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
        .onAppear { if category.isEmpty { category = currentCategories.first ?? "" } }
    }

    private func kindButton(_ k: OverlayOperationKind) -> some View {
        let selected = (kind == k)
        return Button { kind = k } label: {
            HStack(spacing: 6) {
                Image(systemName: k.icon).font(.system(size: 18, weight: .semibold))
                Text(k.displayName).font(.headline)
            }
            .foregroundStyle(selected ? Color.white : (k == .income ? Color.green : Color.red))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10).fill(selected ? (k == .income ? Color.green : Color.red) : Color.gray.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }

    private var currentCategories: [String] {
        switch kind {
        case .income: return incomeCategories
        case .expense: return expenseCategories
        }
    }

    private func maxDay(in month: Int, year: Int) -> Int {
        var comps = DateComponents(); comps.year = year; comps.month = month; comps.day = 1
        let cal = Calendar.current
        if let date = cal.date(from: comps), let range = cal.range(of: .day, in: .month, for: date) { return range.count }
        return 31
    }

    private func save() {
        error = nil
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard amount > 0 else { error = "Montant invalide"; return }
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { error = "Catégorie requise"; return }
        let clampedDay = min(max(1, selectedDay), maxDay(in: selectedMonth, year: selectedYear))

        var comps = DateComponents(); comps.year = selectedYear; comps.month = selectedMonth; comps.day = clampedDay
        guard let date = Calendar.current.date(from: comps) else { error = "Date invalide"; return }

        let occurrence = BudgetEntryOccurrence(context: context)
        occurrence.id = UUID()
        occurrence.date = date
        occurrence.amount = (kind == .income ? amount : -amount)
        occurrence.kind = kind.rawValue
        let titleBase = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        occurrence.title = desc.isEmpty ? titleBase : "\(titleBase) — \(desc)"
        occurrence.isManual = true
        occurrence.monthKey = BudgetProjectionManager.monthKey(for: date)

        do {
            try context.save()
            onSaved()
        } catch {
            self.error = "Erreur lors de la sauvegarde : \(error.localizedDescription)"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            AddOperationOverlay(defaultDate: Date()) { } onCancel: { }
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .padding()
                .background(Color.gray.opacity(0.2))
        }
    }
    return PreviewWrapper()
}
