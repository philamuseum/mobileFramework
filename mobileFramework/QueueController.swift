//
//  QueueController.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreData

class QueueController: NSObject {
    
    static let shared = QueueController()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: Constants.cache.dataModel, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: Constants.cache.dataModel, managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error), \(error)")
            }
        })
        return container
    }()
    
//    var managedObjectContext: NSManagedObjectContext
//    
//    init(completionClosure: @escaping () -> ()) {
//        
//        
//        //This resource is the same name as your xcdatamodeld contained in your project
//        let bundle = Bundle(for: type(of: self))
//        guard let modelURL = bundle.url(forResource: Constants.cache.dataModel, withExtension:"momd") else {
//            fatalError("Error loading model from bundle")
//        }
//        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Error initializing mom from: \(modelURL)")
//        }
//        
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//        
//        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = psc
//        
//        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
//        queue.async {
//            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
//                fatalError("Unable to resolve document directory")
//            }
//            let storeURL = docURL.appendingPathComponent("\(Constants.cache.dataModel).sqlite")
//            do {
//                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
//                //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
//                DispatchQueue.main.sync(execute: completionClosure)
//            } catch {
//                fatalError("Error migrating store: \(error)")
//            }
//        }
//    }
    
    func itemAlreadyExists(url: URL) -> Bool {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.cache.entity)
        let predicate = NSPredicate(format: "url == %@", url.absoluteString)
        
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            return result.count > 0
        } catch let error as NSError {
            print("Queue: Error saving download to queue: \(error.localizedDescription) for url \(url.absoluteString)")
        }
        return false
    }
    
    func save(object: NSManagedObject) {
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Queue: Error saving object: \(error)")
        }
    }
    
    func getItems() -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.cache.entity)
        
        do {
            let items = try persistentContainer.viewContext.fetch(fetchRequest)
            return items as? [NSManagedObject]
        } catch {
            return nil
        }
    }
    
    func reset() {
        guard let items = getItems() else { return }
        for item in items {
            persistentContainer.viewContext.delete(item)
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            
        }
    }

    
     
}
