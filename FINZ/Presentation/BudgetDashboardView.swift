import SwiftUI
import CoreData
import UIKit

struct BudgetDashboardView: View {
    @Environment(\.managedObjectContext) private var context

    @State private var currentBalance: Decimal = 0
    @State private var daysLeftInMonth: Int = 0
    @State private var fixedIncomes: Decimal = 0
    @State private var fixedExpenses: Decimal = 0
    @State private var forecast: Decimal = 0
    @State private var showingAddOperationSheet: Bool = false
    @State private var showingFixedIncomesSheet: Bool = false
    @State private var showingFixedExpensesSheet: Bool = false
    @State private var showingAddOperationFullScreen: Bool = false
    @State private var showingAddIncomeFullScreen: Bool = false
    @State private var showingProfileCreation: Bool = false
    @State private var firstName: String = AppSettings.firstName

    @State private var pulseExpense: Bool = false
    @State private var pulseIncome: Bool = false

    @State private var showingAddOperationTopOverlay: Bool = false
    @State private var showingAddExpenseFullScreen: Bool = false

    @State private var showingForecastOverlay: Bool = false
    @State private var forecastSeries: [(date: Date, balance: Decimal)] = []

    @State private var initialBalance: Decimal = 0
    @State private var actualCurrentBalance: Decimal = 0 // solde réel du mois en cours
    @State private var appDataResetObserver: NSObjectProtocol?

    // Projection navigation
    @State private var projections: [MonthProjection] = []
    @State private var selectedMonthIndex: Int = 0
    @State private var selectedMonthDate: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 8) {
                        HStack {
                            Text(firstName.isEmpty ? "Hello !" : "Hello \(firstName) !")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        HStack {
                            Text("Mon budget")
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color(white: 0.1))
                                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                            Spacer()
                        }
                    }
                    .padding(.top, -15)
                    
                    // Solde actuel
                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(spacing: 6) {
                                Text(selectedMonthIndex == 0 ? "Mon solde actuel" : "Mon solde (\(monthTitle(for: selectedMonthDate)))")
                                    .font(.headline)
                                    .foregroundStyle(Color.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Text("(Solde début de mois : \(formatCurrency(initialBalance)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack(spacing: 18) {
                                Button { changeSelectedMonth(by: -1) } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .buttonStyle(.plain)
                                .disabled(selectedMonthIndex <= 0)
                                .opacity(selectedMonthIndex <= 0 ? 0.35 : 1)
                                
                                VStack(spacing: 8) {
                                    Text(formatCurrency(currentBalance))
                                        .font(.system(size: 56, weight: .bold, design: .rounded))

                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.subheadline)
                                        let dayLabel = daysLeftInMonth == 1 ? "1 jour" : "\(daysLeftInMonth) jours"
                                        Text(dayLabel)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Capsule())
                                }
                                .frame(maxWidth: .infinity)
                                
                                Button { changeSelectedMonth(by: 1) } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .buttonStyle(.plain)
                                .disabled(selectedMonthIndex >= projections.count - 1)
                                .opacity(selectedMonthIndex >= projections.count - 1 ? 0.35 : 1)
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack { Spacer()
                                Text("Tu gères ce mois-ci 😎")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer() }
                            .padding(.top, 2)
                            
                            HStack(spacing: 12) {
                                Button {
                                    let gen = UIImpactFeedbackGenerator(style: .light)
                                    gen.impactOccurred()
                                    showingAddIncomeFullScreen = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text("Recette")
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    let gen = UIImpactFeedbackGenerator(style: .light)
                                    gen.impactOccurred()
                                    showingAddExpenseFullScreen = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text("Dépense")
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 6)
                        }
                        .frame(minHeight: 200)
                    }
                    
                    // Recettes / Dépenses
                    HStack(spacing: 12) {
                        DashboardCard {
                            Button { showingFixedIncomesSheet = true } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.up.right.circle.fill")
                                        .font(.system(size: 22, weight: .heavy))
                                        .foregroundStyle(.green)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Recettes du mois")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("+\(formatCurrency(fixedIncomes))")
                                            .font(.headline)
                                            .foregroundStyle(.green)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        DashboardCard {
                            Button { showingFixedExpensesSheet = true } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.down.right.circle.fill")
                                        .font(.system(size: 22, weight: .heavy))
                                        .foregroundStyle(.red)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dépenses du mois")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text(formatCurrency(fixedExpenses))
                                            .font(.headline)
                                            .foregroundStyle(.red)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Prévisionnel
                    DashboardCard {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                showingForecastOverlay.toggle()
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack { Spacer()
                                    Text("Mon prévisionnel")
                                        .font(.headline)
                                        .foregroundStyle(Color.secondary)
                                    Spacer() }
                                
                                HStack { Spacer()
                                    Text(formatCurrency(forecast))
                                        .font(.system(size: 52, weight: .bold, design: .rounded))
                                    Spacer() }
                                
                                HStack { Spacer()
                                    Text("Profite pour mettre de côté !")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(red: 0.52, green: 0.21, blue: 0.93))
                                    Spacer() }
                                .padding(.top, 2)
                            }
                        }
                        .buttonStyle(.plain)
                        .overlay(
                            Group {
                                if showingForecastOverlay {
                                    ForecastOverlay(series: forecastSeries)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
                .safeAreaPadding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.04),
                        Color.purple.opacity(0.04),
                        Color.pink.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .finzHeader()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                firstName = AppSettings.firstName
                refreshDashboard()
                appDataResetObserver = NotificationCenter.default.addObserver(forName: Notification.Name("AppDataDidReset"), object: nil, queue: .main) { _ in
                    startProfileCreationFlow()
                }
            }
            .onDisappear {
                if let token = appDataResetObserver {
                    NotificationCenter.default.removeObserver(token)
                    appDataResetObserver = nil
                }
            }
            .onChange(of: firstName) { _, _ in
                refreshDashboard()
            }
            .sheet(isPresented: $showingFixedIncomesSheet) {
                RecettesFixesSheet(monthDate: selectedMonthDate)
                    .environment(\.managedObjectContext, context)
            }
            .sheet(isPresented: $showingFixedExpensesSheet) {
                DepensesFixesSheet(monthKey: BudgetProjectionManager.monthKey(for: selectedMonthDate))
                    .environment(\.managedObjectContext, context)
            }
            .sheet(isPresented: $showingProfileCreation) {
                ProfileCreationView()
                    .onDisappear {
                        firstName = AppSettings.firstName
                        refreshDashboard()
                    }
            }
            .fullScreenCover(isPresented: $showingAddOperationFullScreen) {
                AddOperationQuickSheet(
                    defaultDate: Date(),
                    onSaved: {
                        let success = UINotificationFeedbackGenerator()
                        success.notificationOccurred(.success)
                        refreshDashboard()
                        showingAddOperationFullScreen = false
                    },
                    onCancel: {
                        showingAddOperationFullScreen = false
                    }
                )
                .environment(\.managedObjectContext, context)
            }
            .fullScreenCover(isPresented: $showingAddIncomeFullScreen) {
                AddIncomeQuickSheet(
                    defaultDate: Date(),
                    onSaved: {
                        let success = UINotificationFeedbackGenerator()
                        success.notificationOccurred(.success)
                        refreshDashboard()
                        showingAddIncomeFullScreen = false
                    },
                    onCancel: {
                        showingAddIncomeFullScreen = false
                    }
                )
                .environment(\.managedObjectContext, context)
            }
            .fullScreenCover(isPresented: $showingAddExpenseFullScreen) {
                AddExpenseQuickSheet(
                    defaultDate: Date(),
                    onSaved: {
                        let success = UINotificationFeedbackGenerator()
                        success.notificationOccurred(.success)
                        refreshDashboard()
                        showingAddExpenseFullScreen = false
                    },
                    onCancel: {
                        showingAddExpenseFullScreen = false
                    }
                )
                .environment(\.managedObjectContext, context)
            }
        }
        
}
    // MARK: - Projection helpers
    private struct MonthProjection {
        let monthIndex: Int
        let monthDate: Date
        let monthKey: String
        let startBalance: Decimal
        let incomes: Decimal
        let expenses: Decimal
        let endBalance: Decimal
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    private func changeSelectedMonth(by delta: Int) {
        let newIndex = max(0, min((projections.count - 1), selectedMonthIndex + delta))
        guard newIndex != selectedMonthIndex else { return }
        selectedMonthIndex = newIndex
        if newIndex < projections.count {
            selectedMonthDate = projections[newIndex].monthDate
            applyProjection(at: newIndex)
        }
    }

    private func startOfMonth(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? date
    }

    private func daysInMonth(for date: Date) -> Int {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: date)
        return range?.count ?? 30
    }

    private func fetchOccurrences(monthKey: String, kind: String) throws -> [NSManagedObject] {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetch.predicate = NSPredicate(format: "monthKey == %@ AND kind == %@", monthKey, kind)
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(fetch)
    }

    private func upsertAutoBalance(monthKey: String, date: Date, amount: Decimal) throws {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "monthKey == %@", monthKey),
            NSPredicate(format: "kind == %@", "balance"),
            NSPredicate(format: "isManual == NO")
        ])
        fetch.fetchLimit = 1
        let existing = try context.fetch(fetch).first
        let obj: NSManagedObject
        if let existing = existing { obj = existing }
        else {
            guard let entity = NSEntityDescription.entity(forEntityName: "BudgetEntryOccurrence", in: context) else { return }
            obj = NSManagedObject(entity: entity, insertInto: context)
            obj.setValue(UUID(), forKey: "id")
            obj.setValue(false, forKey: "isManual")
            obj.setValue("balance", forKey: "kind")
            obj.setValue(monthKey, forKey: "monthKey")
            obj.setValue("Solde initial prévisionnel", forKey: "title")
        }
        obj.setValue((amount as NSDecimalNumber).doubleValue, forKey: "amount")
        obj.setValue(date, forKey: "date")
    }

    private func buildProjections(horizon: Int = 12, baseInitialBalance: Decimal) {
        let cal = Calendar.current
        let startMonth = startOfMonth(for: Date())
        var runningStart = baseInitialBalance
        var result: [MonthProjection] = []

        for offset in 0..<horizon {
            guard let monthDate = cal.date(byAdding: .month, value: offset, to: startMonth) else { break }
            let monthKey = BudgetProjectionManager.monthKey(for: monthDate)

            if offset > 0 {
                try? BudgetProjectionManager.projectIncomes(for: monthDate, context: context)
                try? BudgetProjectionManager.projectExpenses(for: monthDate, context: context)
                try? upsertAutoBalance(monthKey: monthKey, date: monthDate, amount: runningStart)
            }

            let incomes = (try? fetchOccurrences(monthKey: monthKey, kind: "income")) ?? []
            let expenses = (try? fetchOccurrences(monthKey: monthKey, kind: "expense")) ?? []

            let incomesTotal = incomes.reduce(Decimal.zero) { partial, obj in
                let amount = obj.value(forKey: "amount") as? Double ?? 0
                return partial + Decimal(amount)
            }
            let expensesTotal = expenses.reduce(Decimal.zero) { partial, obj in
                let amount = obj.value(forKey: "amount") as? Double ?? 0
                return partial + Decimal(abs(amount))
            }
            let endBalance = runningStart + incomesTotal - expensesTotal
            result.append(.init(monthIndex: offset, monthDate: monthDate, monthKey: monthKey, startBalance: runningStart, incomes: incomesTotal, expenses: expensesTotal, endBalance: endBalance))
            runningStart = endBalance
        }
        projections = result
        if selectedMonthIndex >= projections.count { selectedMonthIndex = max(0, projections.count - 1) }
        if let current = projections.first(where: { $0.monthIndex == selectedMonthIndex }) {
            selectedMonthDate = current.monthDate
        }
    }

    private func applyProjection(at index: Int) {
        guard index < projections.count else { return }
        let proj = projections[index]
        fixedIncomes = proj.incomes
        fixedExpenses = proj.expenses
        initialBalance = proj.startBalance
        forecast = proj.endBalance
        // Pour le mois courant, on affiche le solde réel actuel ; pour les mois futurs on affiche le solde initial prévisionnel
        currentBalance = (index == 0) ? actualCurrentBalance : proj.startBalance

        let incomes = (try? fetchOccurrences(monthKey: proj.monthKey, kind: "income")) ?? []
        let expenses = (try? fetchOccurrences(monthKey: proj.monthKey, kind: "expense")) ?? []
        forecastSeries = computeForecastSeries(for: proj.monthDate, incomes: incomes, expenses: expenses, startBalance: proj.startBalance)

        daysLeftInMonth = (index == 0) ? computeDaysLeftInMonth() : daysInMonth(for: proj.monthDate)
    }

    private func computeForecastSeries(for monthDate: Date, incomes: [NSManagedObject], expenses: [NSManagedObject], startBalance: Decimal) -> [(date: Date, balance: Decimal)] {
        let cal = Calendar.current
        let start = startOfMonth(for: monthDate)
        guard let end = cal.date(byAdding: .month, value: 1, to: start) else { return [] }

        var deltas: [Date: Decimal] = [:]
        func dayKey(_ d: Date) -> Date { cal.date(from: cal.dateComponents([.year, .month, .day], from: d)) ?? d }

        for obj in incomes {
            guard let d = obj.value(forKey: "date") as? Date else { continue }
            deltas[dayKey(d), default: 0] += Decimal(obj.value(forKey: "amount") as? Double ?? 0)
        }
        for obj in expenses {
            guard let d = obj.value(forKey: "date") as? Date else { continue }
            deltas[dayKey(d), default: 0] -= Decimal(abs(obj.value(forKey: "amount") as? Double ?? 0))
        }

        var balance = startBalance
        var day = start
        var result: [(Date, Decimal)] = []
        while day < end {
            if let delta = deltas[day] { balance += delta }
            result.append((day, balance))
            guard let next = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    private func startProfileCreationFlow() { showingProfileCreation = true }

    private func formatCurrency(_ value: Decimal, code: String = Locale.current.currency?.identifier ?? "EUR") -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 0
        return formatter.string(from: number) ?? "\(value) €"
    }

    private func computeDaysLeftInMonth(now: Date = Date(), calendar: Calendar = .current) -> Int {
        let comps = calendar.dateComponents([.year, .month, .day], from: now)
        guard let year = comps.year, let month = comps.month, let day = comps.day else { return 0 }
        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = month + 1
        endComponents.day = 0
        let endOfMonth = calendar.date(from: endComponents) ?? now
        let diff = calendar.dateComponents([.day], from: now, to: endOfMonth)
        return max(0, (diff.day ?? 0))
    }

    private func fetchIncomeOccurrencesForCurrentMonth() throws -> [NSManagedObject] {
        let monthKey = BudgetProjectionManager.monthKey(for: Date())
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetch.predicate = NSPredicate(format: "monthKey == %@ AND kind == %@", monthKey, "income")
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(fetch)
    }

    private func fetchExpenseOccurrencesForCurrentMonth() throws -> [NSManagedObject] {
        let monthKey = BudgetProjectionManager.monthKey(for: Date())
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetch.predicate = NSPredicate(format: "monthKey == %@ AND kind == %@", monthKey, "expense")
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(fetch)
    }
    
    private func fetchBalanceOccurrencesForCurrentMonth() throws -> [NSManagedObject] {
        let monthKey = BudgetProjectionManager.monthKey(for: Date())
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetch.predicate = NSPredicate(format: "monthKey == %@ AND kind == %@", monthKey, "balance")
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(fetch)
    }

    private func computeRecettesFixesDuMois(from occurrences: [NSManagedObject]) -> Decimal {
        occurrences.reduce(0) { partial, obj in
            let amount = obj.value(forKey: "amount") as? Double ?? 0
            return partial + Decimal(amount)
        }
    }

    private func computeDepensesFixesDuMois(from occurrences: [NSManagedObject]) -> Decimal {
        occurrences.reduce(0) { partial, obj in
            let amount = obj.value(forKey: "amount") as? Double ?? 0
            return partial + Decimal(abs(amount))
        }
    }

    private func computeRecettesPassees(from occurrences: [NSManagedObject]) -> Decimal {
        let now = Date()
        return occurrences.reduce(0) { partial, obj in
            let amount = obj.value(forKey: "amount") as? Double ?? 0
            if let date = obj.value(forKey: "date") as? Date, date <= now {
                return partial + Decimal(amount)
            }
            return partial
        }
    }

    private func computeDepensesPassees(from occurrences: [NSManagedObject]) -> Decimal {
        let now = Date()
        return occurrences.reduce(0) { partial, obj in
            let amount = obj.value(forKey: "amount") as? Double ?? 0
            if let date = obj.value(forKey: "date") as? Date, date <= now {
                return partial + Decimal(abs(amount))
            }
            return partial
        }
    }

    private func refreshDashboard() {
        do {
            let incomes = try fetchIncomeOccurrencesForCurrentMonth()
            let expenses = try fetchExpenseOccurrencesForCurrentMonth()
            let balances = try fetchBalanceOccurrencesForCurrentMonth()
            fixedIncomes = computeRecettesFixesDuMois(from: incomes)
            fixedExpenses = computeDepensesFixesDuMois(from: expenses)

            let recettesPassees = computeRecettesPassees(from: incomes)
            let depensesPassees = computeDepensesPassees(from: expenses)
            let initialBalance = balances.reduce(Decimal.zero) { partial, obj in
                let amount = obj.value(forKey: "amount") as? Double ?? 0
                return partial + Decimal(amount)
            }
            currentBalance = initialBalance + recettesPassees - depensesPassees
            actualCurrentBalance = currentBalance
            self.initialBalance = initialBalance

            buildProjections(horizon: 12, baseInitialBalance: initialBalance)
            applyProjection(at: selectedMonthIndex)
        } catch {
            print("Fetch occurrences error: \(error)")
        }
    }
}

private struct ForecastOverlay: View {
    let series: [(date: Date, balance: Decimal)]

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let padding: CGFloat = 12
            let plotRect = CGRect(x: padding, y: padding, width: width - 2*padding, height: height - 2*padding)
            ZStack {
                // Zero line
                if let minMax = minMax(), plotRect.width > 0, plotRect.height > 0 {
                    let yZero = yFor(value: 0, lo: minMax.lo, hi: minMax.hi, rect: plotRect)
                    Path { p in
                        p.move(to: CGPoint(x: plotRect.minX, y: yZero))
                        p.addLine(to: CGPoint(x: plotRect.maxX, y: yZero))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.5))
                }

                // Balance curve
                if let minMax = minMax(), series.count > 1 {
                    Path { p in
                        for (idx, point) in series.enumerated() {
                            let x = xFor(index: idx, count: series.count, rect: plotRect)
                            let y = yFor(value: (point.balance as NSDecimalNumber).doubleValue, lo: minMax.lo, hi: minMax.hi, rect: plotRect)
                            if idx == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(
                        LinearGradient(colors: [Color(red: 0.52, green: 0.21, blue: 0.93), Color(red: 1.00, green: 0.29, blue: 0.63)], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.96)
    }

    private func minMax() -> (lo: Double, hi: Double)? {
        guard !series.isEmpty else { return nil }
        let values = series.map { ($0.balance as NSDecimalNumber).doubleValue }
        guard let lo = values.min(), let hi = values.max(), lo.isFinite, hi.isFinite else { return nil }
        if lo == hi { return (lo - 1, hi + 1) } // avoid flat line scaling
        return (lo, hi)
    }

    private func xFor(index: Int, count: Int, rect: CGRect) -> CGFloat {
        guard count > 1 else { return rect.minX }
        let t = CGFloat(index) / CGFloat(count - 1)
        return rect.minX + t * rect.width
    }

    private func yFor(value: Double, lo: Double, hi: Double, rect: CGRect) -> CGFloat {
        let clamped = Swift.max(lo, Swift.min(value, hi))
        let t = (clamped - lo) / (hi - lo)
        return rect.maxY - CGFloat(t) * rect.height
    }
}

private struct StatPill: View {
    let title: String
    let value: Decimal
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(formattedValue)
                    .font(.headline)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var formattedValue: String {
        let isNegative = (value as NSDecimalNumber).compare(0) == .orderedAscending
        let number = NSDecimalNumber(decimal: value.magnitude)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        formatter.maximumFractionDigits = 0
        let base = formatter.string(from: number) ?? "\(value)"
        return isNegative ? "-\(base)" : "+\(base)"
    }
}

private struct GenZStyledContainer<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            // Header style
            VStack(spacing: 8) {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 44, height: 5)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .background(.clear)

            // Original content
            content
                .padding(12)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .scaleEffect(appear ? 1 : 0.96)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { appear = true }
        }
    }
}

private struct ProfileCreationView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Création de profil")
                .font(.title2.bold())
            Text("Remplacez cette vue par votre onboarding réel.")
                .foregroundStyle(.secondary)
            Button("Terminer") { }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
