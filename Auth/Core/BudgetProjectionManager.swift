import Foundation
import CoreData

struct BudgetProjectionManager {
    static func monthKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return ""
        }
        return String(format: "%04d-%02d", year, month)
    }
    
    static func projectIncomes(for date: Date, context: NSManagedObjectContext) throws {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        guard let year = comps.year, let month = comps.month else {
            return
        }
        
        // Compute last day of month
        var lastDay = 31
        if let range = calendar.range(of: .day, in: .month, for: date) {
            lastDay = range.count
        }
        
        let monthKey = Self.monthKey(for: date, calendar: calendar)
        
        // Delete existing BudgetEntryOccurrence objects for this monthKey and kind == "income"
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "monthKey == %@", monthKey),
            NSPredicate(format: "kind == %@", "income"),
            NSPredicate(format: "isManual == NO")
        ])
        
        let existingOccurrences = try context.fetch(fetchRequest)
        for obj in existingOccurrences {
            context.delete(obj)
        }
        
        // Fetch all Income objects
        let incomeFetch = NSFetchRequest<NSManagedObject>(entityName: "Income")
        let incomes = try context.fetch(incomeFetch)
        
        func parseMonths(from complement: String?) -> [Int] {
            guard let complement = complement else { return [] }
            
            // Try to find "mois=" pattern
            if let moisRange = complement.range(of: #"mois=([0-9,]+)"#, options: .regularExpression) {
                let matchedString = String(complement[moisRange])
                if let equalIndex = matchedString.firstIndex(of: "=") {
                    let csvString = matchedString[matchedString.index(after: equalIndex)...]
                    let parts = csvString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                    return parts
                }
            }
            return []
        }
        
        func parseDay(from complement: String?) -> Int? {
            guard let complement = complement else { return nil }
            // Try to find "jour=" pattern
            if let jourRange = complement.range(of: #"jour=([0-9]+)"#, options: .regularExpression) {
                let matchedString = String(complement[jourRange])
                if let equalIndex = matchedString.firstIndex(of: "=") {
                    let dayString = matchedString[matchedString.index(after: equalIndex)...]
                    if let day = Int(dayString.trimmingCharacters(in: .whitespaces)) {
                        return day
                    }
                }
            }
            return nil
        }
        
        func clampDay(_ day: Int, year: Int, month: Int, calendar: Calendar) -> Int {
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            
            if let date = calendar.date(from: comps), let range = calendar.range(of: .day, in: .month, for: date) {
                let maxDay = range.count
                return min(max(day, 1), maxDay)
            }
            return max(day, 1)
        }
        
        // Helper to determine if income applies to the month
        func isIncluded(periodicity: String?, monthsCSV: [Int], targetMonth: Int) -> Bool {
            guard let periodicity = periodicity?.lowercased() else {
                return false
            }
            switch periodicity {
            case "mensuel":
                return true
            case "bimestriel", "trimestriel", "semestriel", "annuel", "ponctuel":
                return monthsCSV.contains(targetMonth)
            default:
                return false
            }
        }
        
        for income in incomes {
            let incomeId = income.value(forKey: "id") as? UUID
            let amount = income.value(forKey: "amount") as? Double ?? 0
            let periodicity = income.value(forKey: "periodicity") as? String
            let complement = income.value(forKey: "complement") as? String
            let monthsAttr = income.value(forKey: "months") as? String
            let dayAttr = income.value(forKey: "day") as? Int16
            let kindString = income.value(forKey: "kind") as? String ?? ""
            
            // Parse months CSV
            var monthsCSV: [Int] = []
            if let monthsAttr = monthsAttr, !monthsAttr.isEmpty {
                monthsCSV = monthsAttr.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            } else {
                monthsCSV = parseMonths(from: complement)
            }
            
            // Parse day
            var day: Int = 1
            if let dayVal = dayAttr, dayVal > 0 {
                day = Int(dayVal)
            } else if let parsedDay = parseDay(from: complement) {
                day = parsedDay
            }
            day = clampDay(day, year: year, month: month, calendar: calendar)
            
            if isIncluded(periodicity: periodicity, monthsCSV: monthsCSV, targetMonth: month) {
                var dateComps = DateComponents()
                dateComps.year = year
                dateComps.month = month
                dateComps.day = day
                
                guard let occurrenceDate = calendar.date(from: dateComps) else {
                    continue
                }
                
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "BudgetEntryOccurrence", in: context) else {
                    continue
                }
                
                let occurrence = NSManagedObject(entity: entityDescription, insertInto: context)
                occurrence.setValue(UUID(), forKey: "id")
                occurrence.setValue(occurrenceDate, forKey: "date")
                occurrence.setValue(amount, forKey: "amount")
                occurrence.setValue("income", forKey: "kind")
                occurrence.setValue(kindString, forKey: "title")
                occurrence.setValue(false, forKey: "isManual")
                occurrence.setValue(monthKey, forKey: "monthKey")
            }
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    static func projectExpenses(for date: Date, context: NSManagedObjectContext) throws {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        guard let year = comps.year, let month = comps.month else {
            return
        }
        
        let monthKey = Self.monthKey(for: date, calendar: calendar)
        
        // Delete existing BudgetEntryOccurrence objects for this monthKey and kind == "expense"
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BudgetEntryOccurrence")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "monthKey == %@", monthKey),
            NSPredicate(format: "kind == %@", "expense"),
            NSPredicate(format: "isManual == NO")
        ])
        
        let existingOccurrences = try context.fetch(fetchRequest)
        for obj in existingOccurrences {
            context.delete(obj)
        }
        
        // Fetch all Expense objects
        let expenseFetch = NSFetchRequest<NSManagedObject>(entityName: "Expense")
        let expenses = try context.fetch(expenseFetch)
        
        func parseMonths(from complement: String?) -> [Int] {
            guard let complement = complement else { return [] }
            
            // Try to find "mois=" pattern
            if let moisRange = complement.range(of: #"mois=([0-9,]+)"#, options: .regularExpression) {
                let matchedString = String(complement[moisRange])
                if let equalIndex = matchedString.firstIndex(of: "=") {
                    let csvString = matchedString[matchedString.index(after: equalIndex)...]
                    let parts = csvString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                    return parts
                }
            }
            return []
        }
        
        func parseDay(from complement: String?) -> Int? {
            guard let complement = complement else { return nil }
            // Try to find "jour=" pattern
            if let jourRange = complement.range(of: #"jour=([0-9]+)"#, options: .regularExpression) {
                let matchedString = String(complement[jourRange])
                if let equalIndex = matchedString.firstIndex(of: "=") {
                    let dayString = matchedString[matchedString.index(after: equalIndex)...]
                    if let day = Int(dayString.trimmingCharacters(in: .whitespaces)) {
                        return day
                    }
                }
            }
            return nil
        }
        
        func clampDay(_ day: Int, year: Int, month: Int, calendar: Calendar) -> Int {
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            
            if let date = calendar.date(from: comps), let range = calendar.range(of: .day, in: .month, for: date) {
                let maxDay = range.count
                return min(max(day, 1), maxDay)
            }
            return max(day, 1)
        }
        
        // Helper to determine if expense applies to the month
        func isIncluded(periodicity: String?, monthsCSV: [Int], targetMonth: Int) -> Bool {
            guard let periodicity = periodicity?.lowercased() else {
                return false
            }
            switch periodicity {
            case "mensuel":
                return true
            case "bimestriel", "trimestriel", "semestriel", "annuel", "ponctuel":
                return monthsCSV.contains(targetMonth)
            default:
                return false
            }
        }
        
        for expense in expenses {
            let expenseId = expense.value(forKey: "id") as? UUID
            let amount = expense.value(forKey: "amount") as? Double ?? 0
            let periodicity = expense.value(forKey: "periodicity") as? String
            let complement = expense.value(forKey: "complement") as? String
            let monthsAttr = expense.value(forKey: "months") as? String
            let dayAttr = expense.value(forKey: "day") as? Int16
            let kindString = expense.value(forKey: "kind") as? String ?? ""
            let provider = expense.value(forKey: "provider") as? String
            let endDate = expense.value(forKey: "endDate") as? Date
            
            // Parse months CSV
            var monthsCSV: [Int] = []
            if let monthsAttr = monthsAttr, !monthsAttr.isEmpty {
                monthsCSV = monthsAttr.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            } else {
                monthsCSV = parseMonths(from: complement)
            }
            
            // Parse day
            var day: Int = 1
            if let dayVal = dayAttr, dayVal > 0 {
                day = Int(dayVal)
            } else if let parsedDay = parseDay(from: complement) {
                day = parsedDay
            }
            day = clampDay(day, year: year, month: month, calendar: calendar)
            
            if isIncluded(periodicity: periodicity, monthsCSV: monthsCSV, targetMonth: month) {
                var dateComps = DateComponents()
                dateComps.year = year
                dateComps.month = month
                dateComps.day = day
                
                guard let occurrenceDate = calendar.date(from: dateComps) else {
                    continue
                }
                
                if let endDate = endDate, occurrenceDate > endDate {
                    continue
                }
                
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "BudgetEntryOccurrence", in: context) else {
                    continue
                }
                
                let occurrence = NSManagedObject(entity: entityDescription, insertInto: context)
                occurrence.setValue(UUID(), forKey: "id")
                occurrence.setValue(occurrenceDate, forKey: "date")
                occurrence.setValue(amount, forKey: "amount")
                occurrence.setValue("expense", forKey: "kind")
                occurrence.setValue(provider ?? kindString, forKey: "title")
                occurrence.setValue(false, forKey: "isManual")
                occurrence.setValue(monthKey, forKey: "monthKey")
            }
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
}
