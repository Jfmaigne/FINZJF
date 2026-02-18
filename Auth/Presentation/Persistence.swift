import Foundation
import CoreData

// Core Data stack with CloudKit sync
struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Optionally pre-seed preview data here using controller.container.viewContext
        return controller
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "FINZDataModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        // Enable history tracking and remote change notifications for CloudKit sync
        for desc in container.persistentStoreDescriptions {
            desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

