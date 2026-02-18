import Foundation

enum AppSettings {
    private static let firstNameKey = "userFirstName"

    static var firstName: String {
        get { UserDefaults.standard.string(forKey: firstNameKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: firstNameKey) }
    }
}
