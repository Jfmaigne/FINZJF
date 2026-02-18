import SwiftUI
import CoreData

private struct ContinueActionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var continueAction: (() -> Void)? {
        get { self[ContinueActionKey.self] }
        set { self[ContinueActionKey.self] = newValue }
    }
}

struct ContinueActionModifier: ViewModifier {
    let action: () -> Void
    func body(content: Content) -> some View {
        content.environment(\.continueAction, action)
    }
}

extension View {
    func onContinue(_ action: @escaping () -> Void) -> some View {
        modifier(ContinueActionModifier(action: action))
    }
}

struct BudgetFlowView: View {
    enum Step: Hashable {
        case recettes, depenses, dashboard
    }

    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var vm: QuestionnaireViewModel
    @State private var path: [Step] = []

    var body: some View {
        NavigationStack(path: $path) {
            RecettesView()
                .environmentObject(vm)
                .onContinue { path.append(.depenses) }
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .depenses:
                        ExpensesView()
                            .environmentObject(vm)
                            .onContinue { path.append(.dashboard) }
                    case .dashboard:
                        BudgetDashboardView()
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

#Preview {
    PersistenceController.preview.container.viewContext
    let vm = QuestionnaireViewModel()
    return BudgetFlowView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(vm)
}
