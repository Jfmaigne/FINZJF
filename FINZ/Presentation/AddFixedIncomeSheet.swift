import SwiftUI

struct AddFixedIncomeSheet: View {
    @Binding var entry: RecettesView.IncomeEntry?
    var onSave: (RecettesView.IncomeEntry?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var localKind: RecettesView.IncomeKind = .salaire
    @State private var amountText: String = ""
    @State private var periodicity: String = "Mensuel"
    @State private var selectedMonths: Set<Int> = []
    @State private var day: Int = 1
    @State private var error: String?
    @FocusState private var amountFocused: Bool
    @State private var comment: String = ""
    
    private let kinds = RecettesView.IncomeKind.availableKinds
    
    var isAmountValid: Bool {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0 > 0
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.08), Color.purple.opacity(0.08), Color.pink.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack { Spacer() }
                        Image("finz_logo_couleur")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 88)
                            .accessibilityLabel("FINZ")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Renseigne ta recette fixe")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    amountCard
                    typeCard
                    periodicityCard
                    dayCard
                    commentCard
                }
                .padding()
            }
        }
        // .navigationTitle(entry == nil ? "Recette fixe" : "Modifier la recette fixe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Annuler")
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.purple)
                }
                .disabled(!isAmountValid || (periodicity == "Personnaliser" && selectedMonths.isEmpty))
                .accessibilityLabel("Enregistrer")
            }
        }
        .onAppear(perform: loadFromBinding)
    }
    
    private var amountCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 8)
            HStack(spacing: 8) {
                Spacer()
                TextField("0", text: $amountText)
                    .keyboardType(.decimalPad)
                    .focused($amountFocused)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
                Text("€")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }

    private var typeCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 8) {
                Picker("Type", selection: $localKind) {
                    ForEach(kinds, id: \.self) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 110)
                .clipped()
            }
            .padding()
        }
        .frame(height: 140)
    }

    private var periodicityCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 8) {
                Picker("Périodicité", selection: $periodicity) {
                    Text("Mensuel").tag("Mensuel")
                    Text("Personnaliser").tag("Personnaliser")
                }
                .pickerStyle(.segmented)
            }
            .padding()
        }
    }

    private var dayCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 8) {
                if periodicity == "Personnaliser" {
                    Text("Mois")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    MonthGrid(selectedMonths: $selectedMonths)
                }
                Picker("Jour", selection: $day) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                .clipped()
            }
            .padding()
        }
    }
    
    private var commentCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 6) {
                Text("Commentaire (optionnel)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                TextField("Source, note...", text: $comment)
                    .textInputAutocapitalization(.sentences)
            }
            .padding()
        }
    }
    
    private func loadFromBinding() {
        if let e = entry {
            localKind = e.kind
            periodicity = e.periodicity
            if periodicity == "Mois spécifiques" { periodicity = "Personnaliser" }
            amountText = e.amount
            selectedMonths = []
            day = 1
            comment = ""
            if !e.complement.isEmpty {
                let kv = parseComplementKeyValues(e.complement)
                if let jourStr = kv["jour"], let j = Int(jourStr) {
                    day = j
                }
                if let moisStr = kv["mois"] {
                    let moisList = moisStr.split(separator: ",").compactMap { Int($0) }
                    selectedMonths = Set(moisList)
                }
                if let c = kv["comment"] {
                    comment = c.removingPercentEncoding ?? c
                }
            }
        } else {
            localKind = kinds.first ?? .salaire
            amountText = ""
            periodicity = "Mensuel"
            selectedMonths = []
            day = 1
            comment = ""
            error = nil
        }
    }
    
    private func parseJour(from complement: String) -> Int? {
        // complement format: "jour=xx"
        let comps = complement.split(separator: "=")
        guard comps.count == 2, comps[0] == "jour", let value = Int(comps[1]) else { return nil }
        return value
    }
    
    private func parseMoisAndJour(from complement: String) -> ([Int], Int)? {
        // complement format: "mois=1,2,3;jour=15"
        let parts = complement.split(separator: ";")
        guard parts.count == 2 else { return nil }
        let moisPart = parts[0]
        let jourPart = parts[1]
        
        guard moisPart.starts(with: "mois="), jourPart.starts(with: "jour=") else { return nil }
        
        let moisStr = moisPart.dropFirst("mois=".count)
        let moisList = moisStr.split(separator: ",").compactMap { Int($0) }
        
        let jourStr = jourPart.dropFirst("jour=".count)
        guard let jourValue = Int(jourStr) else { return nil }
        
        return (moisList, jourValue)
    }
    
    private func parseComplementKeyValues(_ complement: String) -> [String: String] {
        var result: [String: String] = [:]
        for part in complement.split(separator: ";") {
            let kv = part.split(separator: "=", maxSplits: 1)
            if kv.count == 2 {
                let key = String(kv[0])
                let value = String(kv[1])
                result[key] = value
            }
        }
        return result
    }

    private func encodeComplementValue(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: ";&=")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
    
    private func save() {
        error = nil
        guard let _ = Double(amountText.replacingOccurrences(of: ",", with: ".")) else {
            error = "Montant invalide"
            return
        }
        
        if periodicity == "Personnaliser" && selectedMonths.isEmpty {
            error = "Sélectionnez au moins un mois"
            return
        }
        
        var complement = ""
        if periodicity == "Mensuel" {
            complement = "jour=\(day)"
        } else if periodicity == "Personnaliser" {
            let moisSorted = selectedMonths.sorted()
            let moisStr = moisSorted.map { String($0) }.joined(separator: ",")
            complement = "mois=\(moisStr);jour=\(day)"
        }

        let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedComment.isEmpty {
            let encoded = encodeComplementValue(trimmedComment)
            if complement.isEmpty {
                complement = "comment=\(encoded)"
            } else {
                complement += ";comment=\(encoded)"
            }
        }
        
        let newEntry = RecettesView.IncomeEntry(
            id: entry?.id ?? UUID(),
            kind: localKind,
            amount: amountText,
            periodicity: periodicity,
            complement: complement
        )
        onSave(newEntry)
        dismiss()
    }
    
    // Reuse MonthGrid from AddIncomeSheet here for independence
    
    private struct MonthGrid: View {
        @Binding var selectedMonths: Set<Int>
        
        private let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        private let monthShorts = ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Aoû", "Sep", "Oct", "Nov", "Déc"]
        
        var body: some View {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...12, id: \.self) { month in
                    Button {
                        if selectedMonths.contains(month) {
                            selectedMonths.remove(month)
                        } else {
                            selectedMonths.insert(month)
                        }
                    } label: {
                        Text(monthShorts[month - 1])
                            .foregroundColor(selectedMonths.contains(month) ? .white : .primary)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedMonths.contains(month) ? Color.green : Color(.systemGray5))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if DEBUG
struct AddFixedIncomeSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddFixedIncomeSheet(entry: .constant(nil)) { _ in }
        }
    }
}
#endif

