import SwiftUI
import UIKit
import Foundation
import CoreData

extension Notification.Name {
    static let didResetAllData = Notification.Name("didResetAllData")
    static let switchToProfile = Notification.Name("switchToProfile")
}

private func justified(_ string: String) -> AttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .justified
    let nsAttr = NSAttributedString(
        string: string,
        attributes: [
            .paragraphStyle: paragraphStyle
        ]
    )
    return AttributedString(nsAttr)
}

struct BudgetTabView: View {
    @State private var selectedTab: Tab = .budget
    @EnvironmentObject var vm: QuestionnaireViewModel
    @Environment(\.managedObjectContext) var context

    enum Tab: Hashable {
        case budget, stats, learn, lexicon, account

        var title: String {
            switch self {
            case .budget: return "Budget"
            case .stats: return "Stats"
            case .learn: return "Apprendre"
            case .lexicon: return "Lexique"
            case .account: return "Compte"
            }
        }

        var systemImage: String {
            switch self {
            case .budget: return "chart.pie.fill"
            case .stats: return "chart.bar.fill"
            case .learn: return "book.fill"
            case .lexicon: return "text.book.closed.fill"
            case .account: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            BudgetDashboardView()
                .tabItem {
                    Label(Tab.budget.title, systemImage: Tab.budget.systemImage)
                }
                .tag(Tab.budget)

            NavigationStack {
                StatisticsView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(Tab.stats.title, systemImage: Tab.stats.systemImage)
            }
            .tag(Tab.stats)

            NavigationStack {
                LearnView()
                    .finzHeader()
            }
            .tabItem {
                Label(Tab.learn.title, systemImage: Tab.learn.systemImage)
            }
            .tag(Tab.learn)

            // LexiconView is defined in LexiconModule.swift
            NavigationStack {
                LexiconView()
                    .finzHeader()
            }
            .tabItem {
                Label(Tab.lexicon.title, systemImage: Tab.lexicon.systemImage)
            }
            .tag(Tab.lexicon)

            AccountView()
                .tabItem {
                    Label(Tab.account.title, systemImage: Tab.account.systemImage)
                }
                .tag(Tab.account)
        }
    }
}

struct BudgetProfileSetupView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                Text("Création du profil de budget")
                    .font(.title2).bold()
                Text("Configure ton profil pour une projection plus précise.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .finzHeader()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LearnView: View {
    var body: some View {
        ScrollView {
            HStack {
                Text("Apprendre")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(white: 0.1))
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer(minLength: 20)

            VStack(spacing: 16) {
                NavigationLink {
                    ArticlesListView(assetName: "articles_logement_genz", title: "Logement")
                } label: {
                    LearnRowView(
                        title: "Logement",
                        subtitle: "Tout comprendre sur ton logement : loyer, charges, copro, assurance… selon que tu sois locataire ou propriétaire.",
                        imageName: "Logement"
                    )
                }

                NavigationLink {
                    ArticlesListView(assetName: "articles_impots_tva_genz", title: "Impôts & TVA")
                } label: {
                    LearnRowView(
                        title: "Impôts & TVA",
                        subtitle: "On t’explique simplement les impôts, la TVA et ce que tu ne paies vraiment sans t’en rendre compte.",
                        imageName: "impots"
                    )
                }

                NavigationLink {
                    ArticlesListView(assetName: "articles_investissement_genz", title: "Investissement")
                } label: {
                    LearnRowView(
                        title: "Investissement",
                        subtitle: "Comprends les bases pour faire travailler ton argent, sans prendre de risques inutiles.",
                        imageName: "invest"
                    )
                }

                NavigationLink {
                    ArticlesListView(assetName: "articles_budget_gestion_genz", title: "Budget & gestion") // Corrected: Removed `vm: nil`
                } label: {
                    LearnRowView(
                        title: "Budget & gestion",
                        subtitle: "Apprends à gérer ton argent au quotidien, suivre tes dépenses et éviter les fins de mois compliqués.",
                        imageName: "Budget"
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.06),
                    Color.purple.opacity(0.06),
                    Color.pink.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

private struct LearnRowView: View {
    let title: String
    let subtitle: String
    let imageName: String?

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 0) {
                if let imageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 84)
                        .padding(.trailing, 2)
                } else {
                    Color.clear.frame(width: 84, height: 84)
                }
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity, alignment: .top)

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading, 2)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AccountView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var vm: QuestionnaireViewModel
    @State private var showingResetAlert = false
    @State private var showingSuccessAlert = false
    @State private var isResetting = false
    @State private var resetError: String? = nil
    @State private var showingProfileConfirm = false
    @State private var firstName: String = AppSettings.firstName
    
    @State private var showingExportSheet = false
    @State private var exportURL: URL? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Paramètres")) {
                    TextField("Prénom", text: $firstName)
                        .textInputAutocapitalization(.words)
                        .onChange(of: firstName) { newValue in
                            AppSettings.firstName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                }
                Section(header: Text("Données")) {
                    if let resetError {
                        Text(resetError)
                            .foregroundStyle(.red)
                    }
                    NavigationLink {
                        RecettesView()
                            .environmentObject(vm)
                            .environment(\.managedObjectContext, context)
                    } label: {
                        Label("Modifier les recettes fixes", systemImage: "arrow.up.circle")
                    }
                    NavigationLink {
                        ExpensesView()
                            .environmentObject(vm)
                            .environment(\.managedObjectContext, context)
                    } label: {
                        Label("Modifier les dépenses fixes", systemImage: "arrow.down.circle")
                    }
                    Button {
                        showingProfileConfirm = true
                    } label: {
                        Label("Modifier le profil", systemImage: "person.crop.circle")
                    }
                    Button {
                        Task { await exportOperations() }
                    } label: {
                        Label("Exporter les opérations", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            if isResetting { ProgressView().padding(.trailing, 6) }
                            Text("Réinitialiser les données")
                        }
                    }
                    .disabled(isResetting)
                }

                Section(header: Text("À propos")) {
                    Text("Compte")
                        .foregroundStyle(.secondary)
                }
            }
//            .navigationTitle("Compte")
            .navigationBarTitleDisplayMode(.inline)
            .finzHeader()
            .onAppear {
                firstName = AppSettings.firstName
            }
            .alert("Confirmer la réinitialisation", isPresented: $showingResetAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) { resetAllData() }
            } message: {
                Text("Cette action va supprimer toutes les données des tables Income, Expense et BudgetEntryOccurrence. Cette action est irréversible.")
            }
            .alert("Données réinitialisées", isPresented: $showingSuccessAlert) {
                Button("OK") {}
            } message: {
                Text("Vos données ont été supprimées. Vous pouvez relancer le questionnaire.")
            }
            .alert("Modifier le profil", isPresented: $showingProfileConfirm) {
                Button("Annuler", role: .cancel) {}
                Button("Continuer") {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    NotificationCenter.default.post(name: .switchToProfile, object: nil)
                }
            } message: {
                Text("Tu vas être redirigé vers l’onglet Profil pour modifier ta configuration.")
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ActivityView(activityItems: [url])
            }
        }
    }

    private func resetAllData() {
        isResetting = true
        resetError = nil
        let entityNames = ["Income", "Expense", "BudgetEntryOccurrence"]
        do {
            for name in entityNames {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
                deleteRequest.resultType = .resultTypeObjectIDs
                if let result = try context.execute(deleteRequest) as? NSBatchDeleteResult,
                   let objectIDs = result.result as? [NSManagedObjectID],
                   !objectIDs.isEmpty {
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            }
            if context.hasChanges {
                try context.save()
            }
            // Notify UI and switch to questionnaire tab
            NotificationCenter.default.post(name: .didResetAllData, object: nil)
            showingSuccessAlert = true
        } catch {
            resetError = "Échec de la réinitialisation: \(error.localizedDescription)"
        }
        isResetting = false
    }
    
    private func exportOperations() async {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let operations = try context.fetch(fetch)
            var csv = "date,montant,kind,titre\n"
            let df = ISO8601DateFormatter()
            for op in operations {
                let date = (op.value(forKey: "date") as? Date).map { df.string(from: $0) } ?? ""
                let montant = (op.value(forKey: "amount") as? Double) ?? 0
                let kind = (op.value(forKey: "kind") as? String) ?? ""
                let titre = (op.value(forKey: "title") as? String)?.replacingOccurrences(of: ",", with: " ") ?? ""
                csv += "\(date),\(montant),\(kind),\(titre)\n"
            }
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("operations.csv")
            try csv.write(to: tmp, atomically: true, encoding: .utf8)
            print("Export file path: \(tmp)")
            let exists = FileManager.default.fileExists(atPath: tmp.path)
            let attrs = try? FileManager.default.attributesOfItem(atPath: tmp.path)
            let size = (attrs?[.size] as? NSNumber)?.intValue ?? 0
            if exists && size > 0 {
                // Optional: Short delay to ensure file is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    exportURL = tmp
                    showingExportSheet = true
                }
            } else {
                print("Export failed: file missing or empty")
            }
        } catch {
            print("Erreur export: \(error)")
        }
    }
}

struct LogementView: View {
    var body: some View {
        NavigationStack {
            LogementArticlesView()
                .navigationTitle("Logement")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ImpotsTVAView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Impôts & TVA")
                    .font(.largeTitle.bold())
                Text(justified("Contenu pédagogique sur les impôts et la TVA…"))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Impôts & TVA")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InvestissementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Investissement")
                    .font(.largeTitle.bold())
                Text(justified("Bases de l’investissement, risques, horizons…"))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Investissement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BudgetGestionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Budget & gestion")
                    .font(.largeTitle.bold())
                Text(justified("Suivi, catégories, objectifs, bonnes pratiques…"))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Budget & gestion")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BudgetTabView()
}

import UIKit
import SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
