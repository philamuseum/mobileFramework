//
//  CacheService.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreData

public class CacheService {
    
    public static let sharedInstance = CacheService()
    
    public let cacheURL : URL = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
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
    
    public func makePostRequest(url: URL, data: Data, completion: @escaping (_ statusCode: Int?, _ error: Error?) -> ()) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30) // self.makeRequest(url: url, forceUncached: true)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let _ = data else {
                return
            }

            let statusCode = (response as! HTTPURLResponse).statusCode
            completion(statusCode, nil)
        }
        task.resume()
    }
    
    public func makeRequest(url: URL, forceUncached: Bool = false) -> URLRequest {
        if forceUncached {
            let mutableRequest = NSMutableURLRequest.init(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 240.0)
            URLProtocol.setProperty(true, forKey: Constants.cache.urlProtocolForceUncachedRequestKey, in: mutableRequest)
            return mutableRequest as URLRequest
        } else {
            return URLRequest(url: url)
        }
    }
    
    public func requestData(url: URL, forceUncached: Bool, saveToEnvironment: String = Constants.cache.environment.manual, completion: @escaping (_ localPath: URL?, _ data: Data?) -> Void) {
        
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
            if fileExists(url: url, repository: saveToEnvironment) {
                let path = getLocalPathForURL(url: url, repository: saveToEnvironment)
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
                    let localPath = self.getLocalPathForURL(url: url, repository: saveToEnvironment)
                    do {
                        self.prepareDirectories(for: url, in: saveToEnvironment)
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
    
    public func publishStagingEnvironment(completion: @escaping (_ success: Bool) -> Void) {
        self.purgeEnvironment(environment: Constants.cache.environment.live)
        
        // this is a seperate block because we don't care if this fails
        // (i.e. folder does not exist yet)
        do {
            // delete the current live folder
            try FileManager.default.removeItem(atPath: getCacheRootFolder(forEnvironment: Constants.cache.environment.live).path)
        } catch {}
        
        do {
            // duplicate the staging folder into live
            try FileManager.default.copyItem(atPath: getCacheRootFolder(forEnvironment: Constants.cache.environment.staging).path, toPath: getCacheRootFolder(forEnvironment: Constants.cache.environment.live).path)
            completion(true)
        } catch {
            print("Error publishing staging: \(error)")
            completion(false)
        }
    }
    
    public func purgeEnvironment(environment: String, completion: @escaping (_ success: Bool) -> Void) {
        self.purgeEnvironment(environment: environment)
        completion(true)
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
    
    public func getLocalPathForURL(url: URL, repository: String) -> URL {
        let filename = url.lastPathComponent
        
        let localPath = url.pathComponents.dropFirst().dropLast().joined(separator: "/")
        
        var returnValue = getCacheRootFolder(forEnvironment: repository)
        
        if localPath.count > 0 {
            returnValue = returnValue.appendingPathComponent(localPath)
        }
        
        return returnValue.appendingPathComponent(filename)
    }
    
    func getCacheRootFolder(forEnvironment environment: String) -> URL {
        return cacheURL.appendingPathComponent(Bundle(for: type(of: self)).bundleIdentifier!, isDirectory: true).appendingPathComponent(environment, isDirectory: true)
    }
    
    func fileExists(url: URL, repository: String) -> Bool {
        return FileManager.default.fileExists(atPath: getLocalPathForURL(url: url, repository: repository).path)
    }
    
    func removeFile(for url: URL, repository: String) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing file: \(error)")
        }
    }
    
    // http://stackoverflow.com/questions/27721418/ios-swift-getting-list-of-files-in-documents-folder
    internal func listFilesFromDirectory(path: String) -> [String] {
        
        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: path)
            return fileList as [String]
        }catch {
            
        }
            
        let fileList = [""]
        return fileList
    }
    
    func purgeEnvironment(environment: String) {
        
        let folder = getCacheRootFolder(forEnvironment: environment)
        
        var fileList = self.listFilesFromDirectory(path: folder.path)
        
        for i:Int in 0 ..< fileList.count
        {
            let path = folder.path + "/" + fileList[i]
            
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("error deleting file: \(error)")
            }
            print("deleted file: \(fileList[i])")
        }
        
    }
}
