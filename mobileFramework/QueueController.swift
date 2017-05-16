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
    
    func addItem(url: URL) {
        
        if !QueueController.shared.itemAlreadyExists(url: url) {
            
            print("Queue: Adding new item to download queue: \(url.absoluteString)")
            
            let context = QueueController.shared.persistentContainer.viewContext
            if let entity = NSEntityDescription.entity(forEntityName: Constants.cache.entity, in: context) {
                let queueItem = NSManagedObject(entity: entity, insertInto: context)
                queueItem.setValue(url.absoluteString, forKey: "url")
                queueItem.setValue(NSDate(), forKey: "created_at")
                
                QueueController.shared.save(object: queueItem)
            }
        } else {
            print("Queue: Item already exists in download queue, skipping: \(url.absoluteString)")
        }
    }

    
     
}
