//
//  CacheService.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class CacheService {
    
    let manualRequestRepository = "manual"
    
    let cacheURL : URL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    // define two cache repositories: live and temp (temp will have subfolders based on queue names)
    
    // service.request(url: url, cached: false) { localPath, data in

    func request(url: URL, uncached: Bool, completion: @escaping (_ localPath: URL?, _ data: Data?) -> Void) {
        
        // if uncached, we simply make sure to make a new request and return data
        // we're currently not saving the data for the next time
        if uncached {
            var returnData : Data?
            
            getUncachedData(url: url, completion: {
                data in
                returnData = data
                completion(nil, returnData)
            })
            
        } else {
            // we want cached data, so let's check if the requested file already exists locally
            if fileExists(url: url, repository: manualRequestRepository) {
                let path = getLocalPathForURL(url: url, repository: manualRequestRepository)
                var data : Data?
                do {
                    data = try Data(contentsOf: path)
                } catch {
                    print("Error: Unable to load data: \(error)")
                }
                completion(path, data)
            } else {
                // if the file does not exist, then let's download, store and return it
                var returnData : Data?
                
                getUncachedData(url: url, completion: {
                    data in
                    returnData = data
                    let localPath = self.getLocalPathForURL(url: url, repository: self.manualRequestRepository)
                    do {
                        do {
                            var localPathWithoutFilename = localPath
                            localPathWithoutFilename.deleteLastPathComponent()
                            try FileManager.default.createDirectory(atPath: localPathWithoutFilename.path, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print("Error: Unable to create directory: \(error)")
                        }
                        try returnData?.write(to: localPath, options: .atomic)
                    } catch {
                       print("Error: Unable to write file \(error)")
                    }
                    completion(localPath, returnData)
                })
                
            }
        }
    }
    
    func getUncachedData(url: URL, completion: @escaping (_ data: Data?) -> Void) {
        
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
        
        return cacheURL.appendingPathComponent(repository, isDirectory: true).appendingPathComponent(localPath, isDirectory: true).appendingPathComponent(filename)
    }
    
    func fileExists(url: URL, repository: String) -> Bool {
        return FileManager.default.fileExists(atPath: getLocalPathForURL(url: url, repository: repository).absoluteString)
    }
}
