import SwiftUI
import CoreData

struct AppEntryView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: QuestionnaireViewModel
    
    @State private var shouldShowDashboard = false
    @State private var checked = false
    
    var body: some View {
        Group {
            if checked {
                if shouldShowDashboard {
                    BudgetDashboardView()
                } else {
                    BudgetFlowView()
                }
            } else {
                ProgressView("Chargement…")
            }
        }
        .task {
            await checkBudgetEntries()
        }
    }
    
    private func checkBudgetEntries() async {
        let monthKey = BudgetProjectionManager.monthKey(for: Date())
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetchRequest.predicate = NSPredicate(format: "monthKey == %@", monthKey)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            shouldShowDashboard = (count > 0)
        } catch {
            shouldShowDashboard = false
        }
        checked = true
    }
}

#Preview {
    AppEntryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(QuestionnaireViewModel())
}
