import SwiftUI
import CoreData
import UIKit

struct RecettesView: View {
    @EnvironmentObject private var vm: QuestionnaireViewModel
    @Environment(\.managedObjectContext) private var context
    @Environment(\.continueAction) private var continueAction

    enum IncomeCategory: String, CaseIterable, Hashable {
        case travail = "Recettes liées au travail"
        case investissements = "Recettes liées aux investissements"
        case allocations = "Recettes liées aux allocations"
        case autre = "Autre"
    }

    enum IncomeKind: String, CaseIterable, Hashable {
        // Travail
        case salaire = "Salaire"
        case prime = "Prime"
        case interessement = "Intéressement"
        case remboursementFrais = "Remboursement de frais"
        // Investissements
        case loyersPercus = "Loyers perçus"
        case interets = "Intérêts"
        // Allocations
        case allocationLogement = "Allocation Logement"
        case allocationHandicap = "Allocation Handicap"
        case primeActivites = "Prime d’activités"
        case allocationAutre = "Allocation autre"
        // Autre
        case parents = "Parents"
        case venteBien = "Vente d’un bien"
        case gainExceptionnel = "Gain exceptionnel"
        // Backward-compatibility legacy kinds (hidden from UI)
        case bourse = "Bourse"
        case allocation = "Allocation"

        var category: IncomeCategory {
            switch self {
            case .salaire, .prime, .interessement, .remboursementFrais:
                return .travail
            case .loyersPercus, .interets:
                return .investissements
            case .allocationLogement, .allocationHandicap, .primeActivites, .allocationAutre, .allocation, .bourse:
                return .allocations
            case .parents, .venteBien, .gainExceptionnel:
                return .autre
            }
        }

        static var availableKinds: [IncomeKind] {
            return [
                // Travail
                .salaire, .prime, .interessement, .remboursementFrais,
                // Investissements
                .loyersPercus, .interets,
                // Allocations
                .allocationLogement, .allocationHandicap, .primeActivites, .allocationAutre,
                // Autre
                .parents, .venteBien, .gainExceptionnel
            ]
        }
    }

    struct IncomeEntry: Identifiable, Hashable {
        let id: UUID
        var kind: IncomeKind
        var label: String { kind.rawValue }
        var amount: String
        var periodicity: String
        var complement: String
        init(id: UUID = UUID(), kind: IncomeKind, amount: String = "", periodicity: String = "Mensuel", complement: String = "") {
            self.id = id
            self.kind = kind
            self.amount = amount
            self.periodicity = periodicity
            self.complement = complement
        }
    }

    @State private var entries: [IncomeEntry] = []
    @State private var isSaving = false
    @State private var saveError: String? = nil
    @State private var showBudget = false
    @State private var showExpenses = false

    @State private var showingAddSheet = false
    @State private var editingEntry: IncomeEntry? = nil

    private let periodicities = ["Mensuel", "Bimestriel", "Trimestriel", "Semestriel", "Annuel", "Ponctuel"]

    private var groupedEntries: [(category: IncomeCategory, items: [IncomeEntry])] {
        let groups = Dictionary(grouping: entries, by: { $0.kind.category })
        let categoryOrder: [IncomeCategory] = [.travail, .investissements, .allocations, .autre]
        return categoryOrder.compactMap { cat in
            guard let items = groups[cat], !items.isEmpty else { return nil }
            let order = IncomeKind.availableKinds.filter { $0.category == cat }
            let sorted = items.sorted { a, b in
                (order.firstIndex(of: a.kind) ?? Int.max) < (order.firstIndex(of: b.kind) ?? Int.max)
            }
            return (cat, sorted)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        Image("finz_logo_couleur")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .accessibilityLabel("FINZ")
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                if entries.isEmpty {
                    Section {
                        Text("Aucune recette à saisir selon les informations précédentes.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                }
                
                ForEach(groupedEntries, id: \.category) { group in
                    Section(group.category.rawValue) {
                        ForEach(group.items, id: \.id) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(entry.label)
                                        .font(.headline)
                                    Spacer()
                                    Text(entry.amount.isEmpty ? "—" : entry.amount)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                Text(detailText(for: entry))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingEntry = entry
                                showingAddSheet = true
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteEntry(entry)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    deleteEntry(entry)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    editingEntry = entry
                                    showingAddSheet = true
                                } label: {
                                    Label("Modifier", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
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
            .finzHeader()
            .stickyNextButton(enabled: !entries.isEmpty, action: saveAll)
            .navigationTitle("Recettes")
            .navigationBarTitleDisplayMode(.inline)
            // Le bouton "+" est maintenant dans la barre d'outils pour rester fixe
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editingEntry = IncomeEntry(kind: .salaire)
                        showingAddSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 34, height: 34)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .accessibilityLabel("Ajouter une recette")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AddFixedIncomeSheet(entry: $editingEntry) { saved in
                        if let saved = saved {
                            if let idx = entries.firstIndex(where: { $0.id == saved.id }) {
                                entries[idx] = saved
                            } else {
                                entries.append(saved)
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showExpenses) {
                ExpensesView()
                    .environment(\.managedObjectContext, context)
                    .environmentObject(vm)
            }
            .onAppear(perform: setupEntries)
        }
    }

    private func setupEntries() {
        var kinds = Set<IncomeKind>()
        // Personnal situations
        if vm.selectedPersonnalSituation.contains(.Etudiant) {
            kinds.insert(.bourse)
            kinds.insert(.parents)
        }
        if vm.selectedPersonnalSituation.contains(.Salarié) || vm.selectedPersonnalSituation.contains(.Entrepreneur) {
            kinds.insert(.salaire)
        }
        if vm.selectedPersonnalSituation.contains(.Handicap) || vm.selectedPersonnalSituation.contains(.SansEmploi) {
            kinds.insert(.allocation)
        }
        // Housing status
        if vm.housingStatus == .renter {
            kinds.insert(.allocationLogement)
        }
        do {
            let fetch = NSFetchRequest<NSManagedObject>(entityName: "Income")
            let objs = try context.fetch(fetch)
            let existing: [IncomeEntry] = objs.compactMap { obj in
                guard let id = obj.value(forKey: "id") as? UUID,
                      let kindStr = obj.value(forKey: "kind") as? String,
                      let kind = IncomeKind(rawValue: kindStr) else { return nil }
                let amount = (obj.value(forKey: "amount") as? Double).map { String($0) } ?? ""
                let periodicity = obj.value(forKey: "periodicity") as? String ?? "Mensuel"
                let complementStored = obj.value(forKey: "complement") as? String ?? ""
                let monthsCSV = obj.value(forKey: "months") as? String
                let dayVal = obj.value(forKey: "day") as? Int16
                let complement: String = {
                    if !complementStored.isEmpty { return complementStored }
                    return buildComplement(monthsCSV: monthsCSV, day: dayVal)
                }()
                return IncomeEntry(id: id, kind: kind, amount: amount, periodicity: periodicity, complement: complement)
            }
            if !existing.isEmpty {
                entries = existing
            }
        } catch {
            // ignore fetch errors for now
        }
        // Build entries if empty only (idempotent on revisit)
        if entries.isEmpty {
            var defaultKinds: [IncomeKind] = []
            // Travail
            if vm.selectedPersonnalSituation.contains(.Salarié) || vm.selectedPersonnalSituation.contains(.Entrepreneur) {
                defaultKinds += [.salaire, .prime, .interessement, .remboursementFrais]
            }
            // Allocations
            if vm.selectedPersonnalSituation.contains(.Handicap) || vm.selectedPersonnalSituation.contains(.SansEmploi) {
                defaultKinds += [.allocationHandicap, .primeActivites]
            }
            // Étudiant / Aide familiale
            if vm.selectedPersonnalSituation.contains(.Etudiant) {
                defaultKinds += [.parents]
            }
            // Logement
            if vm.housingStatus == .renter {
                defaultKinds += [.allocationLogement]
            }
            // If still empty, propose a minimal set
            if defaultKinds.isEmpty {
                defaultKinds = [.salaire, .parents]
            }
            entries = defaultKinds.map { IncomeEntry(kind: $0) }
        }
    }

    private func saveAll() {
        guard !isSaving else { return }
        isSaving = true
        saveError = nil
        do {
            try persistEntries()
            
            // Project incomes into monthly occurrences for the dashboard
            do {
                try BudgetProjectionManager.projectIncomes(for: Date(), context: context)
            } catch {
                // Non-fatal: record an error message but continue navigation
                saveError = "Projection des recettes échouée: \(error.localizedDescription)"
            }
            
        } catch {
            saveError = "Erreur d’enregistrement: \(error.localizedDescription)"
            isSaving = false
            return
        }
        // Temporary no-op: simulate a save and finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSaving = false
            if let action = continueAction {
                action()
            } else {
                showExpenses = true
            }
        }
    }

    private func parseComplement(_ complement: String) -> (monthsCSV: String?, day: Int16?, comment: String?) {
        // Expected formats: "jour=28", "mois=1,3,6;jour=28", optionally with ";comment=..." (percent-encoded)
        var monthsCSV: String? = nil
        var day: Int16? = nil
        var comment: String? = nil
        let parts = complement.split(separator: ";").map { String($0) }
        for p in parts {
            let kv = p.split(separator: "=", maxSplits: 1)
            if kv.count == 2 {
                let key = kv[0].trimmingCharacters(in: .whitespaces)
                let rawValue = String(kv[1]).trimmingCharacters(in: .whitespaces)
                if key == "mois" {
                    // Normalize CSV to sorted unique 1..12
                    let nums = rawValue.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }.filter { (1...12).contains($0) }
                    let csv = nums.sorted().map(String.init).joined(separator: ",")
                    if !csv.isEmpty { monthsCSV = csv }
                } else if key == "jour" {
                    if let d = Int(rawValue), (1...31).contains(d) { day = Int16(d) }
                } else if key == "comment" {
                    comment = rawValue.removingPercentEncoding ?? rawValue
                }
            }
        }
        return (monthsCSV, day, comment)
    }

    private func buildComplement(monthsCSV: String?, day: Int16?) -> String {
        var parts: [String] = []
        if let monthsCSV, !monthsCSV.isEmpty { parts.append("mois=\(monthsCSV)") }
        if let day, day > 0 { parts.append("jour=\(day)") }
        return parts.joined(separator: ";")
    }
    
    private func monthShortNames(from monthsCSV: String) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        let symbols = df.shortMonthSymbols ?? df.monthSymbols ?? []
        let nums = monthsCSV
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { (1...12).contains($0) }
        if symbols.isEmpty {
            // Fallback to raw CSV if symbols unavailable
            return nums.map(String.init).joined(separator: ", ")
        }
        let names = nums.compactMap { idx in
            let i = idx - 1
            return (i >= 0 && i < symbols.count) ? symbols[i] : nil
        }
        return names.joined(separator: ", ")
    }

    private func detailText(for entry: IncomeEntry) -> String {
        let parsed = parseComplement(entry.complement)
        let dayText: String = {
            if let d = parsed.day, d > 0 { return "jour \(Int(d))" } else { return "" }
        }()
        let monthsText: String = parsed.monthsCSV ?? ""
        var base: String
        if !monthsText.isEmpty {
            base = "mois: \(monthShortNames(from: monthsText))"
        } else if !dayText.isEmpty {
            base = "\(entry.periodicity) • \(dayText)"
        } else {
            base = entry.periodicity
        }
        if let comment = parsed.comment, !comment.isEmpty {
            return base + " • " + comment
        } else {
            return base
        }
    }

    private func persistEntries() throws {
        // Expect a Core Data entity named "Income" with attributes: id(UUID), kind(String), amount(Double), periodicity(String), complement(String), months(Data optional), day(Int16 optional)
        for e in entries {
            let fetch = NSFetchRequest<NSManagedObject>(entityName: "Income")
            fetch.predicate = NSPredicate(format: "id == %@", e.id as CVarArg)
            let existing = try context.fetch(fetch).first
            let obj: NSManagedObject
            if let existing = existing {
                obj = existing
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "Income", in: context)!
                obj = NSManagedObject(entity: entity, insertInto: context)
                obj.setValue(e.id, forKey: "id")
            }
            obj.setValue(e.kind.rawValue, forKey: "kind")
            let amount = Double(e.amount.replacingOccurrences(of: ",", with: ".")) ?? 0
            obj.setValue(amount, forKey: "amount")
            obj.setValue(e.periodicity, forKey: "periodicity")
            obj.setValue(e.complement, forKey: "complement")
            let parsed = parseComplement(e.complement)
            if let monthsCSV = parsed.monthsCSV {
                obj.setValue(monthsCSV, forKey: "months")
            } else {
                obj.setValue(nil, forKey: "months")
            }
            if let d = parsed.day {
                obj.setValue(d, forKey: "day")
            } else {
                obj.setValue(nil, forKey: "day")
            }
        }
        if context.hasChanges {
            try context.save()
        }
    }

    private func deleteEntry(_ entry: IncomeEntry) {
        // Remove from in-memory list
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: idx)
        }
        // Also delete from Core Data if exists
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Income")
        fetch.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
        if let obj = try? context.fetch(fetch).first {
            context.delete(obj)
            try? context.save()
        }
    }
}

#Preview {
    NavigationStack {
        RecettesView()
            .environmentObject(QuestionnaireViewModel())
    }
}

