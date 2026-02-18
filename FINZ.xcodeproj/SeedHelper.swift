import Foundation
import CoreData

public enum SeedHelper {
    public static func ensureSeed(on context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CategorieOperation")
        fetchRequest.fetchLimit = 1
        
        let count = try context.count(for: fetchRequest)
        if count > 0 {
            return
        }
        
        // Insert seed data here if needed
        // Example:
        // let entity = NSEntityDescription.entity(forEntityName: "CategorieOperation", in: context)!
        // let newObject = NSManagedObject(entity: entity, insertInto: context)
        // newObject.setValue("Example", forKey: "name")
        
        try context.save()
    }
}
