//
//  QueueController.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreData

public class QueueController: NSObject {
    
    public static let sharedInstance = QueueController()
    
    public var delegate : QueueControllerDelegate?
    
    internal var identifier : String!
    internal var config : URLSessionConfiguration!
    internal var session : URLSession!
    
    private var isDownloading = false
    private var downloadQueueTimer : Timer?
    private var totalItemsToDownload: Int = 0
    
    public override init() {
        super.init()
        self.session?.invalidateAndCancel()
        setupQueue()
    }
    
    internal func setupQueue() {
        
        identifier = Bundle(for: type(of: self)).bundleIdentifier! + ".backgroundDownloadTask"
        config = URLSessionConfiguration.background(withIdentifier: identifier)
        
        let queue = OperationQueue()
        if Constants.queue.maxConcurrentOperations != -1 {
            queue.maxConcurrentOperationCount = Constants.queue.maxConcurrentOperations
            print("Setting max concurrent task limit: \(queue.maxConcurrentOperationCount)")
        }
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: queue)
        
    }
    
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
    
    public func getItems() -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.cache.entity)
        
        do {
            let items = try persistentContainer.viewContext.fetch(fetchRequest)
            return items as? [NSManagedObject]
        } catch {
            return nil
        }
    }
    
    func removeItem(url: URL) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.cache.entity)
        let predicate = NSPredicate(format: "url == %@", url.absoluteString)
        
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            if let item = result.first as? NSManagedObject {
                DispatchQueue.main.async {
                    self.persistentContainer.viewContext.delete(item)
                }
            }
        } catch let error as NSError {
            print("Queue: Error removing download from queue: \(error.localizedDescription) for url \(url.absoluteString)")
        }
    }

    
    public func reset() {
        print("Resetting queue and URL Session")
        guard let items = getItems() else { return }
        for item in items {
            persistentContainer.viewContext.delete(item)
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            
        }
        
        self.session.getAllTasks(completionHandler: { tasks in
            for task in tasks {
                task.cancel()
            }
        })
        
        setupQueue()
    }
    
    public func addItem(url: URL) {
        
        if !QueueController.sharedInstance.itemAlreadyExists(url: url) {
            
            print("Queue: Adding new item to download queue: \(url.absoluteString)")
            
            let context = QueueController.sharedInstance.persistentContainer.viewContext
            if let entity = NSEntityDescription.entity(forEntityName: Constants.cache.entity, in: context) {
                let queueItem = NSManagedObject(entity: entity, insertInto: context)
                queueItem.setValue(url.absoluteString, forKey: "url")
                queueItem.setValue(NSDate(), forKey: "created_at")
                
                QueueController.sharedInstance.save(object: queueItem)
            }
        } else {
            print("Queue: Item already exists in download queue, skipping: \(url.absoluteString)")
        }
    }

    public func startDownloading() {
        
        print("Start downloading queue items...")
        
        if let items = getItems() {
            for item in items {
                let url = item.value(forKey: "url") as! String
                let task = self.session.downloadTask(with: URL(string: url)!)
                print("starting download for \(url)")
                task.resume()
            }
            isDownloading = true
            totalItemsToDownload = items.count
            
            //guard self.downloadQueueTimer == nil else { return }
            self.downloadQueueTimer?.invalidate()
            
            self.downloadQueueTimer = Timer.scheduledTimer(timeInterval: Constants.queue.updateFrequency, target: self, selector: #selector(checkRemainingTasks), userInfo: nil, repeats: true)
        }
    }
    
    @objc func checkRemainingTasks() {
        print("Checking remaining tasks and publishing progress update")
        
        self.session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let bytesReceived = downloads.map{ $0.countOfBytesReceived }.reduce(0, +)
            let bytesExpectedToReceive = downloads.map{ $0.countOfBytesExpectedToReceive }.reduce(0, +)
            let progress = bytesExpectedToReceive > 0 ? Float(bytesReceived) / Float(bytesExpectedToReceive) : 1.0
            
            var itemCount: Int = 0
            if self.getItems() != nil {
                itemCount = self.getItems()!.count
            }
            
            self.delegate?.QueueControllerDownloadInProgress(queueController: self, withProgress: progress, tasksTotal: self.totalItemsToDownload, tasksLeft: itemCount)
        }
        
        self.session.getAllTasks(completionHandler: { tasks in
            if self.isDownloading && tasks.count == 0 {
                // we have been downloading but we are done now
                print("All tasks finished.")
                self.isDownloading = false
                self.downloadQueueTimer?.invalidate()
                self.delegate?.QueueControllerDidFinishDownloading(queueController: self)
            }
        })
    }
}

extension QueueController: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        debugPrint("Task completed: \(task), error: \(error)")
    }
}

extension QueueController: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        if totalBytesExpectedToWrite > 0 {
//            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//            debugPrint("Progress \(downloadTask) \(progress)")
//        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        debugPrint("Download finished: \(location)")
        let originalURL = downloadTask.originalRequest?.url
        CacheService.sharedInstance.prepareDirectories(for: originalURL!, in: Constants.cache.environment.staging)
        let newLocation = CacheService.sharedInstance.getLocalPathForURL(url: originalURL!, repository: Constants.cache.environment.staging)
        
//        print("URL: \(originalURL) \nLocalPath: \(newLocation)")
        
        try? FileManager.default.copyItem(atPath: location.path, toPath: newLocation.path)
        try? FileManager.default.removeItem(at: location)
        self.removeItem(url: originalURL!)
    }
}
