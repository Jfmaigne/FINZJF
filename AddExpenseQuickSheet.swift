import SwiftUI
import CoreData

struct AddExpenseQuickSheet: View {
    var defaultDate: Date
    var onSaved: () -> Void
    var onCancel: () -> Void
    
    @State private var amountText: String = ""
    @State private var selectedCategory: String = ""
    @State private var date: Date
    @State private var note: String = ""
    @State private var error: String?
    @FocusState private var amountFocused: Bool
    @State private var pulse: Bool = false
    
    private let categories = ["Solde initial du mois", "Courses", "Essence", "Sortie", "Abonnement", "Loyer", "Électricité"]
    @Environment(\.managedObjectContext) private var moc
    
    init(defaultDate: Date, onSaved: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.defaultDate = defaultDate
        self.onSaved = onSaved
        self.onCancel = onCancel
        _date = State(initialValue: defaultDate)
        _selectedCategory = State(initialValue: "")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with buttons and centered FINZ logo
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
                HStack { Spacer()
                    Text("Renseigne les infos de ta dépense")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .leading, endPoint: .trailing)
                        )
                    Spacer() }
            }
            .padding(.bottom, 0)
            
            // Amount field in white rounded card with stroke and shadow
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
            .padding(.horizontal, 20)
            
            // Category picker inside white rounded card with stroke and shadow, height 80, no label
            VStack(alignment: .leading, spacing: 8) {
                HStack { Spacer()
                    Picker("Catégorie", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
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
            .padding(.horizontal, 20)
            
            // DatePicker centered compact with reduced padding inside white rounded card with stroke and shadow
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
            .padding(.horizontal, 20)
            
            // Comment field as TextField inside white rounded card with stroke and shadow
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
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 4)
            .padding(.horizontal, 20)
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 4)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            amountFocused = false
        }
        .onAppear {
            if selectedCategory.isEmpty {
                selectedCategory = categories.first ?? ""
            }
        }
    }
    
    private func save() {
        error = nil
        
        let cleanAmountText = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amountDouble = Double(cleanAmountText), amountDouble > 0 else {
            error = "Veuillez entrer un montant valide supérieur à zéro."
            pulseAmountField()
            return
        }
        
        guard !selectedCategory.isEmpty else {
            error = "Veuillez sélectionner une catégorie."
            pulseAmountField()
            return
        }
        
        let amount = -abs(amountDouble) // negative for expense
        
        if selectedCategory == "Solde initial du mois" {
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
                let existing = try moc.fetch(fetchRequest).first
                let occurrence = existing ?? BudgetEntryOccurrence(context: moc)
                if existing == nil {
                    occurrence.id = UUID()
                    occurrence.kind = "balance"
                    occurrence.monthKey = monthKey
                    occurrence.isManual = true
                }
                occurrence.date = firstOfMonth
                occurrence.amount = amountDouble // store the raw positive amount for initial balance
                occurrence.title = "Solde initial du mois" + (note.isEmpty ? "" : " - \(note)")

                try moc.save()
                onSaved()
            } catch {
                self.error = "Erreur lors de la sauvegarde."
                pulseAmountField()
            }
            return
        }
        
        let title = note.isEmpty ? selectedCategory : "\(selectedCategory) - \(note)"
        
        let occurrence = BudgetEntryOccurrence(context: moc)
        occurrence.id = UUID()
        occurrence.date = date
        occurrence.kind = "expense"
        occurrence.amount = amount
        occurrence.title = title
        occurrence.monthKey = BudgetProjectionManager.monthKey(for: date)
        occurrence.isManual = true
        
        do {
            try moc.save()
            onSaved()
        } catch {
            self.error = "Erreur lors de la sauvegarde."
            pulseAmountField()
        }
    }
    
    private func pulseAmountField() {
        withAnimation(.easeInOut(duration: 0.25)) {
            pulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.25)) {
                pulse = false
            }
        }
    }
}

// MARK: - Preview

struct AddExpenseQuickSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseQuickSheet(defaultDate: Date(), onSaved: {}, onCancel: {})
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.sizeThatFits)
    }
}

