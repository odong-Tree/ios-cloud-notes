
import UIKit
import CoreData

class CoreDataSingleton {
    static let shared = CoreDataSingleton()
    
    private init() { }
    
    lazy var memoData: [NSManagedObject] = {
        return self.fetch()
    }()
    
    func fetch() -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return [NSManagedObject]()
            // 에러 핸들링 필요
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        let sort = NSSortDescriptor(key: "lastModified", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        let result = try! managedContext.fetch(fetchRequest)
        return result
    }
    
    func save(title: String, body: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: managedContext)
        object.setValue(title, forKey: "title")
        object.setValue(body, forKey: "body")
        object.setValue(Date(), forKey: "lastModified")
        
        do {
            try managedContext.save()
            self.memoData.insert(object, at: 0)
            return true
        } catch {
            managedContext.rollback()
            return false
        }
    }
    
    func delete(object: NSManagedObject) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        managedContext.delete(object)
        
        do {
            try managedContext.save()
            return true
        } catch {
            managedContext.rollback()
            return false
        }
    }
    
    func update(object: NSManagedObject, title: String, body: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        object.setValue(title, forKey: "title")
        object.setValue(body, forKey: "body")
        object.setValue(Date(), forKey: "lastModified")
        
        do {
            try managedContext.save()
            return true
        } catch {
            managedContext.rollback()
            return false
        }
    }
}
