import SwiftUI
import CoreData

enum Periodicite: String, CaseIterable, Identifiable {
    case HEBDOMADAIRE
    case MENSUEL
    case ANNUEL
    
    var id: String { rawValue }
}

struct BudgetsView: View {
    let category: CategorieOperation
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest var budgets: FetchedResults<BudgetStructure>
    
    @State private var showingAddSheet = false
    @State private var editingBudget: BudgetStructure?
    
    init(category: CategorieOperation) {
        self.category = category
        _budgets = FetchRequest<BudgetStructure>(
            entity: BudgetStructure.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \BudgetStructure.descriptionText, ascending: true)],
            predicate: NSPredicate(format: "categorie == %@", category)
        )
    }
    
    var body: some View {
        List {
            ForEach(budgets) { budget in
                Button(action: {
                    editingBudget = budget
                }) {
                    HStack {
                        Text(budget.descriptionText ?? "")
                        Spacer()
                        Text(formatMontant(budget.montant))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: deleteBudgets)
        }
        .navigationTitle("Budgets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Budget")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            BudgetEditView(context: context, category: category)
        }
        .sheet(item: $editingBudget) { budget in
            BudgetEditView(context: context, category: category, budgetToEdit: budget)
        }
    }
    
    private func deleteBudgets(at offsets: IndexSet) {
        offsets.map { budgets[$0] }.forEach(context.delete)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            // Handle the error appropriately in production
            print("Failed to save context: \(error)")
        }
    }
    
    private func formatMontant(_ montant: NSDecimalNumber?) -> String {
        guard let montant = montant else { return "" }
        return NumberFormatter.currencyFormatter.string(from: montant) ?? ""
    }
}

struct BudgetEditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    let category: CategorieOperation
    var budgetToEdit: BudgetStructure?
    
    @State private var descriptionText: String = ""
    @State private var montantString: String = ""
    @State private var periodicite: Periodicite = .MENSUEL
    @State private var complementPeriodicite: String = ""
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    init(context: NSManagedObjectContext, category: CategorieOperation, budgetToEdit: BudgetStructure? = nil) {
        self.context = context
        self.category = category
        self.budgetToEdit = budgetToEdit
        _descriptionText = State(initialValue: budgetToEdit?.descriptionText ?? "")
        if let montant = budgetToEdit?.montant {
            _montantString = State(initialValue: numberFormatter.string(from: montant) ?? "")
        } else {
            _montantString = State(initialValue: "")
        }
        if let periodiciteRaw = budgetToEdit?.periodicite, let p = Periodicite(rawValue: periodiciteRaw) {
            _periodicite = State(initialValue: p)
        } else {
            _periodicite = State(initialValue: .MENSUEL)
        }
        _complementPeriodicite = State(initialValue: budgetToEdit?.complementPeriodicite ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Description")) {
                    TextField("Description", text: $descriptionText)
                }
                Section(header: Text("Montant")) {
                    TextField("Montant", text: $montantString)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Périodicité")) {
                    Picker("Périodicité", selection: $periodicite) {
                        ForEach(Periodicite.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Complément périodicité (optionnel)")) {
                    TextField("Complément périodicité", text: $complementPeriodicite)
                }
            }
            .navigationTitle(budgetToEdit == nil ? "Ajouter Budget" : "Modifier Budget")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveBudget()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        guard !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard parseMontant(montantString) != nil else { return false }
        return true
    }
    
    private func parseMontant(_ string: String) -> NSDecimalNumber? {
        if let number = numberFormatter.number(from: string) as? NSDecimalNumber {
            return number
        }
        return nil
    }
    
    private func saveBudget() {
        let budget = budgetToEdit ?? BudgetStructure(context: context)
        budget.descriptionText = descriptionText.trimmingCharacters(in: .whitespaces)
        budget.montant = parseMontant(montantString)
        budget.periodicite = periodicite.rawValue
        budget.complementPeriodicite = complementPeriodicite.trimmingCharacters(in: .whitespaces)
        budget.categorie = category
        
        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save budget: \(error)")
        }
    }
}

private extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
}

struct BudgetsView_Previews: PreviewProvider {
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    static var sampleCategory: CategorieOperation = {
        let cat = CategorieOperation(context: context)
        cat.id = UUID()
        cat.name = "Sample Category"
        return cat
    }()
    
    static var sampleBudgets: [BudgetStructure] = {
        let b1 = BudgetStructure(context: context)
        b1.id = UUID()
        b1.descriptionText = "Budget 1"
        b1.montant = NSDecimalNumber(string: "100.00")
        b1.periodicite = Periodicite.MENSUEL.rawValue
        b1.complementPeriodicite = ""
        b1.categorie = sampleCategory
        
        let b2 = BudgetStructure(context: context)
        b2.id = UUID()
        b2.descriptionText = "Budget 2"
        b2.montant = NSDecimalNumber(string: "250.50")
        b2.periodicite = Periodicite.ANNUEL.rawValue
        b2.complementPeriodicite = "Complément"
        b2.categorie = sampleCategory
        
        try? context.save()
        
        return [b1, b2]
    }()
    
    static var previews: some View {
        NavigationView {
            BudgetsView(category: sampleCategory)
                .environment(\.managedObjectContext, context)
        }
    }
}
