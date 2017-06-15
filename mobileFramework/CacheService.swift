//
//  CacheService.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreData

class CacheService {
    
    public static let sharedInstance = CacheService()
    
    public let cacheURL : URL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    internal func reset() {
    
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: cacheURL.path)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: cacheURL.appendingPathComponent(filePath).path)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    
    }
    
    func request(url: URL, forceUncached: Bool, completion: @escaping (_ localPath: URL?, _ data: Data?) -> Void) {
        
        // if uncached, we simply make sure to make a new request and return data
        // we're currently not saving the data for the next time
        if forceUncached {
            var returnData : Data?
            
            getUncachedData(url: url, completion: {
                data in
                returnData = data
                completion(nil, returnData)
            })
            
        } else {
            // we want cached data, so let's check if the requested file already exists locally
            if fileExists(url: url, repository: Constants.cache.environment.manual) {
                let path = getLocalPathForURL(url: url, repository: Constants.cache.environment.manual)
                var data : Data?
                do {
                    data = try Data(contentsOf: path)
                } catch {
                    print("Error: Unable to load data: \(error)")
                }
                print("Cache: File exists and will be served locally")
                completion(path, data)
            } else {
                // if the file does not exist, then let's download, store and return it
                var returnData : Data?
                
                getUncachedData(url: url, completion: {
                    data in
                    returnData = data
                    let localPath = self.getLocalPathForURL(url: url, repository: Constants.cache.environment.manual)
                    do {
                        self.prepareDirectories(for: url, in: Constants.cache.environment.manual)
                        try returnData?.write(to: localPath, options: .atomic)
                    } catch {
                       print("Error: Unable to write file \(error)")
                    }
                    print("Cache: File did not exist locally, but has now been downloaded")
                    completion(localPath, returnData)
                })
                
            }
        }
    }
    
    func prepareDirectories(for url: URL, in repository: String) {
        let localPath = self.getLocalPathForURL(url: url, repository: repository)
        do {
            var localPathWithoutFilename = localPath
            localPathWithoutFilename.deleteLastPathComponent()
            try FileManager.default.createDirectory(atPath: localPathWithoutFilename.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error: Unable to create directory: \(error)")
        }
    }
    
    private func getUncachedData(url: URL, completion: @escaping (_ data: Data?) -> Void) {
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("ERROR")
                return
            }
            
            completion(data)
        }
        
        task.resume()
    }
    
    func getLocalPathForURL(url: URL, repository: String) -> URL {
        let filename = url.lastPathComponent
        
        let localPath = url.pathComponents.dropFirst().dropLast().joined(separator: "/")
        
        var returnValue = cacheURL.appendingPathComponent(Bundle(for: type(of: self)).bundleIdentifier!, isDirectory: true).appendingPathComponent(repository, isDirectory: true)
        
        if localPath.characters.count > 0 {
            returnValue = returnValue.appendingPathComponent(localPath)
        }
        
        return returnValue.appendingPathComponent(filename)
    }
    
    func fileExists(url: URL, repository: String) -> Bool {
        return FileManager.default.fileExists(atPath: getLocalPathForURL(url: url, repository: repository).path)
    }
}
