import SwiftUI
import CoreData
import UIKit

struct AddIncomeQuickSheet: View {
    var defaultDate: Date
    var onSaved: () -> Void
    var onCancel: () -> Void

    @Environment(\.managedObjectContext) private var context

    @State private var amountText: String = ""
    @State private var selectedKind: IncomeKind = .salaire
    @State private var date: Date
    @State private var note: String = ""
    @State private var error: String? = nil
    @FocusState private var amountFocused: Bool
    @State private var pulse: Bool = false

    init(defaultDate: Date = Date(), onSaved: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.defaultDate = defaultDate
        self.onSaved = onSaved
        self.onCancel = onCancel
        _date = State(initialValue: defaultDate)
    }

    enum IncomeKind: String, CaseIterable, Identifiable {
        case salaire = "Salaire"
        case parents = "Parents"
        case bourse = "Bourse"
        case allocation = "Allocation"
        case autre = "Autre"
        case initialBalance = "Solde initial du mois"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Button(action: { onCancel() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                    }
                    Spacer()
                    Image("finz_logo_couleur")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 110)
                        .accessibilityLabel("Finz")
                    Spacer()
                    Button(action: { save() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(
                                LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 0)
                .padding(.bottom, 4)

                VStack(spacing: 2) {
                    HStack { Spacer();
                        Text("Renseigne les infos de ta recette")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .leading, endPoint: .trailing)
                            )
                        ; Spacer() }
                }
                .padding(.bottom, 0)

                VStack(alignment: .center, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Spacer()
                        TextField("0", text: $amountText)
                            .keyboardType(.decimalPad)
                            .focused($amountFocused)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(white: 0.1))
                            .minimumScaleFactor(0.8)
                        Text("€")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack { Spacer()
                        Picker("Type", selection: $selectedKind) {
                            ForEach(IncomeKind.allCases) { k in
                                Text(k.rawValue).tag(k)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 80)
                        .clipped()
                        Spacer() }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack { Spacer()
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        Spacer() }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Commentaire (optionnel)").font(.headline)
                    TextField("Source, note…", text: $note)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                if let error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

            }
            .padding(.horizontal)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .scaleEffect(pulse ? 0.96 : 1.0)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.04),
                    Color.purple.opacity(0.04),
                    Color.pink.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        .onAppear { amountFocused = true }
    }

    private func save() {
        error = nil
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard amount > 0 else {
            error = "Veuillez saisir un montant valide"
            return
        }
        if selectedKind == .initialBalance {
            // Record initial balance as a special occurrence on the first day of the month
            let calendar = Calendar.current
            var comps = calendar.dateComponents([.year, .month], from: date)
            comps.day = 1
            let firstOfMonth = calendar.date(from: comps) ?? date
            let monthKey = BudgetProjectionManager.monthKey(for: firstOfMonth)

            // Ensure uniqueness: update existing balance for this month if present
            let fetchRequest: NSFetchRequest<BudgetEntryOccurrence> = BudgetEntryOccurrence.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "monthKey == %@ AND kind == %@", monthKey, "balance")
            fetchRequest.fetchLimit = 1
            do {
                let existing = try context.fetch(fetchRequest).first
                let entityName = "BudgetEntryOccurrence"
                let occurrence: BudgetEntryOccurrence
                if let existing = existing {
                    occurrence = existing
                } else {
                    occurrence = BudgetEntryOccurrence(context: context)
                    occurrence.id = UUID()
                    occurrence.kind = "balance"
                    occurrence.monthKey = monthKey
                    occurrence.isManual = true
                }
                occurrence.date = firstOfMonth
                occurrence.amount = amount // use the raw positive amount for initial balance
                occurrence.title = "Solde initial du mois" + (note.isEmpty ? "" : " — " + note)

                try context.save()
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                withAnimation(.easeInOut(duration: 0.12)) { pulse = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.easeOut(duration: 0.12)) { pulse = false }
                    onSaved()
                }
            } catch {
                self.error = error.localizedDescription
            }
            return
        }
        // Create a one-off Income occurrence for the selected date
        let entityName = "BudgetEntryOccurrence"
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            error = "Données indisponibles"
            return
        }
        let obj = NSManagedObject(entity: entity, insertInto: context)
        obj.setValue(UUID(), forKey: "id")
        obj.setValue(date, forKey: "date")
        obj.setValue("income", forKey: "kind")
        obj.setValue(amount, forKey: "amount")
        let title = selectedKind.rawValue + (note.isEmpty ? "" : " — " + note)
        obj.setValue(title, forKey: "title")
        // Optional: set monthKey if your model uses it
        let monthKey = BudgetProjectionManager.monthKey(for: date)
        obj.setValue(monthKey, forKey: "monthKey")
        obj.setValue(true, forKey: "isManual")
        do {
            try context.save()
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
            withAnimation(.easeInOut(duration: 0.12)) { pulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.12)) { pulse = false }
                onSaved()
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    AddIncomeQuickSheet(defaultDate: Date(), onSaved: {}, onCancel: {})
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

