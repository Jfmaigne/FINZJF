import SwiftUI
import CoreData

enum DebCred: String, CaseIterable, Identifiable {
    case DEBIT, CREDIT
    var id: String { rawValue }
}

extension CategorieOperation {
    var debCredEnum: DebCred {
        get { DebCred(rawValue: debcred ?? "DEBIT") ?? .DEBIT }
        set { debcred = newValue.rawValue }
    }
}

struct CategoriesView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategorieOperation.categorie, ascending: true)],
        animation: .default)
    var categories: FetchedResults<CategorieOperation>

    @State private var showingAdd = false
    @State private var editCategory: CategorieOperation?

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.objectID) { category in
                    NavigationLink(category.categorie ?? "", value: category)
                        .swipeActions {
                            Button(role: .destructive) {
                                delete(category: category)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                Button {
                    showingAdd = true
                } label: {
                    Label("Add Category", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAdd) {
                CategoryEditView(context: context)
            }
            .navigationDestination(for: CategorieOperation.self) { category in
                BudgetsView(category: category)
            }
            .sheet(item: $editCategory) { category in
                CategoryEditView(context: context, category: category)
            }
        }
    }

    func delete(category: CategorieOperation) {
        context.delete(category)
        try? context.save()
    }
}

struct CategoryEditView: View {
    @Environment(\.dismiss) var dismiss
    let context: NSManagedObjectContext
    @State private var categorie: String = ""
    @State private var debCred: DebCred = .DEBIT
    var category: CategorieOperation?

    init(context: NSManagedObjectContext, category: CategorieOperation? = nil) {
        self.context = context
        self.category = category
        _categorie = State(initialValue: category?.categorie ?? "")
        _debCred = State(initialValue: category?.debCredEnum ?? .DEBIT)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Categorie", text: $categorie)
                Picker("DebCred", selection: $debCred) {
                    ForEach(DebCred.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle(category == nil ? "Add Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(categorie.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    func save() {
        let cat = category ?? CategorieOperation(context: context)
        cat.categorie = categorie.trimmingCharacters(in: .whitespaces)
        cat.debCredEnum = debCred
        try? context.save()
    }
}

struct BudgetsView: View {
    let category: CategorieOperation
    var body: some View {
        Text("Budgets for \(category.categorie ?? "")")
            .navigationTitle(category.categorie ?? "")
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var persistenceController: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        for i in 1...5 {
            let cat = CategorieOperation(context: ctx)
            cat.categorie = "Category \(i)"
            cat.debcred = i % 2 == 0 ? "DEBIT" : "CREDIT"
        }
        try? ctx.save()
        return controller
    }()

    static var previews: some View {
        CategoriesView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
