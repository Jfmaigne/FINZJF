import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            // Allow portrait and both landscapes on iPad
            return [.portrait, .landscapeLeft, .landscapeRight]
        default:
            // Force portrait on iPhone and other idioms
            return [.portrait]
        }
    }
}
