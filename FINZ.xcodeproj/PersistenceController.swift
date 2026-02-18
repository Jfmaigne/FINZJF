import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        seedIfNeeded()
    }

    private func seedIfNeeded() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CategorieOperation")
        fetchRequest.fetchLimit = 1
        do {
            let count = try viewContext.count(for: fetchRequest)
            if count == 0 {
                // Insert categories
                let salaire = NSEntityDescription.insertNewObject(forEntityName: "CategorieOperation", into: viewContext)
                salaire.setValue("Salaire", forKey: "categorie")
                salaire.setValue("CREDIT", forKey: "debcred")

                let loyer = NSEntityDescription.insertNewObject(forEntityName: "CategorieOperation", into: viewContext)
                loyer.setValue("Loyer", forKey: "categorie")
                loyer.setValue("DEBIT", forKey: "debcred")

                let courses = NSEntityDescription.insertNewObject(forEntityName: "CategorieOperation", into: viewContext)
                courses.setValue("Courses", forKey: "categorie")
                courses.setValue("DEBIT", forKey: "debcred")

                // Insert budgets linked to categories
                let budgetSalaire = NSEntityDescription.insertNewObject(forEntityName: "Budget", into: viewContext)
                budgetSalaire.setValue("Salaire Mensuel", forKey: "descriptionText")
                budgetSalaire.setValue(Decimal(2500.0) as NSDecimalNumber, forKey: "montant")
                budgetSalaire.setValue("Mensuel", forKey: "periodicite")
                budgetSalaire.setValue(nil, forKey: "complementPeriodicite")
                budgetSalaire.setValue(salaire, forKey: "categorie")

                let budgetLoyer = NSEntityDescription.insertNewObject(forEntityName: "Budget", into: viewContext)
                budgetLoyer.setValue("Loyer Mensuel", forKey: "descriptionText")
                budgetLoyer.setValue(Decimal(800.0) as NSDecimalNumber, forKey: "montant")
                budgetLoyer.setValue("Mensuel", forKey: "periodicite")
                budgetLoyer.setValue(nil, forKey: "complementPeriodicite")
                budgetLoyer.setValue(loyer, forKey: "categorie")

                let budgetCourses = NSEntityDescription.insertNewObject(forEntityName: "Budget", into: viewContext)
                budgetCourses.setValue("Courses Hebdo", forKey: "descriptionText")
                budgetCourses.setValue(Decimal(150.0) as NSDecimalNumber, forKey: "montant")
                budgetCourses.setValue("Hebdomadaire", forKey: "periodicite")
                budgetCourses.setValue(nil, forKey: "complementPeriodicite")
                budgetCourses.setValue(courses, forKey: "categorie")

                try viewContext.save()
            }
        } catch {
            let nsError = error as NSError
            fatalError("Failed to seed data: \(nsError), \(nsError.userInfo)")
        }
    }
}
