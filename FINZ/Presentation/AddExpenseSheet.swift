import SwiftUI

struct AddExpenseSheet: View {
    @State private var entry: ExpensesView.ExpenseEntry
    var onSave: (ExpensesView.ExpenseEntry) -> Void
    @Environment(\.dismiss) private var dismiss

    // Local editable states
    @State private var localKind: ExpensesView.ExpenseKind = .assuranceHabitation
    @State private var amountText: String = ""
    @State private var periodicity: String = "Mensuel" // "Mensuel" or "Mois spécifiques"
    @State private var selectedMonths: Set<Int> = []
    @State private var day: Int = 1
    @State private var hasEndDate: Bool = false
    @State private var endDate: Date = Date()
    @State private var error: String? = nil

    @FocusState private var amountFieldFocused: Bool
    @State private var comment: String = ""

    init(entry: ExpensesView.ExpenseEntry, onSave: @escaping (ExpensesView.ExpenseEntry) -> Void) {
        _entry = State(initialValue: entry)
        self.onSave = onSave
    }

    var body: some View {
        // Réintégration de la NavigationStack interne.
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack { Spacer() }
                        Image("finz_logo_couleur")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 88)
                            .accessibilityLabel("FINZ")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Renseigne ta dépense fixe")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Amount card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Spacer()
                            TextField("0", text: $amountText)
                                .keyboardType(.decimalPad)
                                .focused($amountFieldFocused)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: true, vertical: false)
                            Text("€")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Type card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Spacer()
                            Picker("Type de dépense", selection: $localKind) {
                                ForEach(ExpensesView.ExpenseKind.availableKinds, id: \.self) { kind in
                                    Text(kind.rawValue).tag(kind)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 110)
                            .clipped()
                            Spacer() }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Periodicity card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Périodicité").font(.headline)
                        Picker("Périodicité", selection: $periodicity) {
                            Text("Mensuel").tag("Mensuel")
                            Text("Mois spécifiques").tag("Mois spécifiques")
                        }
                        .pickerStyle(.segmented)

                        if periodicity == "Mois spécifiques" {
                            // Month grid
                            let monthSymbols = Calendar.current.monthSymbols
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(1...12, id: \.self) { m in
                                    let isOn = selectedMonths.contains(m)
                                    Button(action: {
                                        if isOn { selectedMonths.remove(m) } else { selectedMonths.insert(m) }
                                    }) {
                                        Text(String(monthSymbols[m - 1].prefix(3)))
                                            .font(.footnote)
                                            .padding(8)
                                            .frame(maxWidth: .infinity)
                                            .background(isOn ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Day card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Picker("Jour", selection: $day) {
                                ForEach(1...31, id: \.self) { d in
                                    Text("\(d)").tag(d)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 110)
                            .clipped()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Comment card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Commentaire (optionnel)").font(.headline)
                        TextField("Source, note…", text: $comment)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Optional details
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Date de fin", isOn: $hasEndDate)
                        if hasEndDate {
                            DatePicker("Date de fin", selection: $endDate, displayedComponents: .date)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.08),
                        Color.purple.opacity(0.08),
                        Color.pink.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Dépense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Suppression de ce ToolbarItem pour éviter les conflits avec le système.
                // Le système devrait fournir un moyen de fermer la feuille ou le glissement vers le bas fonctionnera.
                // ToolbarItem(placement: .navigationBarLeading) {
                //     Button { dismiss() } label: { Image(systemName: "xmark") }
                //     .accessibilityLabel("Annuler")
                // }
                ToolbarItem(placement: .confirmationAction) {
                    Button { save() } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.purple)
                    }
                    .disabled((Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0 || (periodicity == "Mois spécifiques" && selectedMonths.isEmpty))
                }
            }
            .onAppear { loadFromEntry() }
        }
    }

    private func loadFromEntry() {
        localKind = entry.kind
        amountText = entry.amount
        if let end = entry.endDate {
            endDate = end
            hasEndDate = true
        } else {
            hasEndDate = false
            endDate = Date()
        }

        // Parse complement to init months/day and periodicity
        selectedMonths = []
        day = 1
        if let parsed = parse(entry.complement) {
            if let monthsCSV = parsed.monthsCSV, !monthsCSV.isEmpty {
                let months = monthsCSV.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                selectedMonths = Set(months)
            }
            if let d = parsed.day { day = Int(d) }
        }
        periodicity = selectedMonths.isEmpty ? "Mensuel" : "Mois spécifiques"

        // Parse comment from complement
        if let parsed = parse(entry.complement), let c = parsed.comment, !c.isEmpty {
            comment = c
        } else {
            comment = ""
        }
        if let provider = entry.provider, !provider.isEmpty {
            if comment.isEmpty {
                comment = provider
            } else if !comment.localizedCaseInsensitiveContains(provider) {
                comment += " — " + provider
            }
        }
    }

    private func save() {
        error = nil
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard amount > 0 else {
            error = "Veuillez saisir un montant valide"
            return
        }
        if periodicity == "Mois spécifiques" && selectedMonths.isEmpty {
            error = "Sélectionnez au moins un mois"
            return
        }

        var updated = entry
        updated.kind = localKind
        updated.amount = amountText
        updated.periodicity = periodicity
        if periodicity == "Mensuel" {
            updated.complement = "jour=\(day)"
        } else {
            let monthsStr = selectedMonths.sorted().map(String.init).joined(separator: ",")
            updated.complement = "mois=\(monthsStr);jour=\(day)"
        }

        let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let encoded = encodeComplementValue(trimmed)
            if updated.complement.isEmpty {
                updated.complement = "comment=\(encoded)"
            } else {
                updated.complement += ";comment=\(encoded)"
            }
        }

        updated.provider = nil
        updated.endDate = hasEndDate ? endDate : nil

        onSave(updated)
        dismiss()
    }

    // Local parser mirroring ExpensesView.parseComplement signature
    private func parse(_ complement: String) -> (monthsCSV: String?, day: Int16?, comment: String?)? {
        let parts = complement.split(separator: ";")
        var monthsCSV: String?
        var dayInt: Int16?
        var comment: String?
        for part in parts {
            let keyVal = part.split(separator: "=", maxSplits: 1)
            if keyVal.count == 2 {
                let key = keyVal[0].trimmingCharacters(in: .whitespaces).lowercased()
                let val = String(keyVal[1]).trimmingCharacters(in: .whitespaces)
                if key == "mois" || key == "months" {
                    monthsCSV = val
                } else if key == "jour" || key == "day" {
                    dayInt = Int16(val) ?? nil
                } else if key == "comment" {
                    comment = val.removingPercentEncoding ?? val
                }
            }
        }
        if monthsCSV != nil || dayInt != nil || comment != nil {
            return (monthsCSV, dayInt, comment)
        }
        return nil
    }

    private func encodeComplementValue(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: ";&=")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
