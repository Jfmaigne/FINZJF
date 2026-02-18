import SwiftUI
import CoreData

@main
struct MonApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CategoriesView()
                .environment(\.managedObjectContext, persistence.viewContext)
        }
    }
}
