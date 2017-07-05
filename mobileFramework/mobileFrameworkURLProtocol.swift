//
//  mobileFrameworkURLProtocol.swift
//  mobileFramework
//
//  Created by Peter.Alt on 6/15/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import UIKit

// Updated for iOS 9: https://stackoverflow.com/questions/36297813/custom-nsurlprotocol-with-nsurlsession
public class mobileFrameworkURLProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    private var dataTask: URLSessionDataTask?
    private var urlResponse: URLResponse?
    private var receivedData: NSMutableData?
    
    var connection: NSURLConnection!
    
    // we determine if we need a custom URL protocol or not, so return true means YES and false means NO
    override public class func canInit(with request: URLRequest) -> Bool {
        //print("Request #\(requestCount++): URL = \(request.URL!.absoluteString)")
        
        // this is a shortcut in case we already processed the request, we can skip out right away!
        if URLProtocol.property(forKey: Constants.cache.urlProtocolKey, in: request) != nil {
            return false
        }
        
        if request.httpMethod == "POST" {
            return false
        }
        
        if request.url?.scheme == "customProtocol" {
            return false
        }
        
        return true
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public class func requestIsCacheEquivalent(_ aRequest: URLRequest,
                                                 to bRequest: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(aRequest, to:bRequest)
    }
    
    override public func startLoading() {
        
        let localPath = CacheService.sharedInstance.getLocalPathForURL(url: self.request.url!, repository: Constants.cache.environment.live)
        
        // we can set a custom key if we need a request to go through uncached, otherwise we'll leave it up to the protocol to repond
        if URLProtocol.property(forKey: Constants.cache.urlProtocolForceUncachedRequestKey, in: request) != nil {
            processRemoteRequest()
        } else {
        
            do {
            
                let data = try Data(contentsOf: localPath)
                    
                let response = URLResponse(url: self.request.url!, mimeType: "", expectedContentLength: data.count, textEncodingName: nil)
                
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
                
                self.client?.urlProtocol(self, didLoad: data)
                
                self.client?.urlProtocolDidFinishLoading(self)
                
                print("LOCAL: \(request.url!.absoluteString)")
                
            } catch {
                processRemoteRequest()
                
            }
        }
    }
    
    internal func processRemoteRequest() {
        
        print("REMOTE: \(request.url!.absoluteString)")
        
        let mutableRequest =  NSMutableURLRequest.init(url: self.request.url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 240.0)//self.request as! NSMutableURLRequest
        
        let defaultConfigObj = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)
        self.dataTask = defaultSession.dataTask(with: mutableRequest as URLRequest)
        self.dataTask!.resume()
        
        URLProtocol.setProperty(true, forKey: Constants.cache.urlProtocolKey, in: mutableRequest)
    }

    override public func stopLoading() {
        
        self.dataTask?.cancel()
        self.dataTask       = nil
        self.receivedData   = nil
        self.urlResponse    = nil
        
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        self.client!.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: Data!) {
        self.client!.urlProtocol(self, didLoad: data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.client!.urlProtocolDidFinishLoading(self)
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.client!.urlProtocol(self, didFailWithError: error)
    }
    
    // MARK: NSURLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        self.urlResponse = response
        self.receivedData = NSMutableData()
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data as Data)
        
        self.receivedData?.append(data as Data)
    }
    
    // MARK: NSURLSessionTaskDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil { //&& error.code != NSURLErrorCancelled {
            self.client?.urlProtocol(self, didFailWithError: error!)
        } else {
            //saveCachedResponse()
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
}
