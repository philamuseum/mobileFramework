//
//  BackendService.swift
//  mobileFramework
//
//  Created by Peter.Alt on 7/5/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

public enum BackendServiceError: Error {
    case insufficientPermissions
    case notRegisteredForRemoteNotifications
    case backendConfigurationMissing
}

public class BackendService : NSObject {
    
    public static var shared = BackendService()
    
    public private(set) var sufficientNotificationPermissions = false
    public private(set) var registeredOnBackend = false
    
    internal var healthTimer : Timer?
    public var deviceTokenData : Data?
    internal var deviceToken : String? {
        get {
            if deviceTokenData == nil { return nil }
            
            var token = ""
            for i in 0..<deviceTokenData!.count {
                token = token + String(format: "%02.2hhx", arguments: [deviceTokenData![i]])
            }
            return token
        }
    }
    
    public func requestPermissions(completion: @escaping () -> ()) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.alert]) { (granted, error) in
            print("BackendService: Notification authorization: \(granted)")
            // Enable or disable features based on authorization.
            if granted {
                self.sufficientNotificationPermissions = true
            }
            completion()
        }
    }
    
    public func registerForRemoteNotifications() throws {
        if self.sufficientNotificationPermissions {
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            throw BackendServiceError.insufficientPermissions
        }
    }
    
    public func retrieveGeolocationData(completion: @escaping () -> Void) throws {
        
        if Constants.backend.apiKey != nil && Constants.backend.host != nil {
        } else { throw BackendServiceError.backendConfigurationMissing }
        
        let locationsUrl = URL(string: "\(Constants.backend.host!)/api/v0/collection/locations?api_token=\(Constants.backend.apiKey!)")
        
        CacheService.sharedInstance.requestData(url: locationsUrl!, forceUncached: true, completion: { localPath, data in
            if data != nil {
                do {
                    try FeatureStore.sharedInstance.load(fromData: data!, type: .location, completion: {
                        if let asset = FeatureStore.sharedInstance.getAsset(for: .location) as? LocationAsset {
                            LocationStore.sharedInstance.load(fromAsset: asset)
                            
                            let geoJSONUrl = URL(string: "\(Constants.backend.host!)/api/v0/collection/geojson?api_token=\(Constants.backend.apiKey!)")
                            
                            CacheService.sharedInstance.requestData(url: geoJSONUrl!, forceUncached: true, completion: { localPath, data in
                                if data != nil {
                                    do {
                                        try FeatureStore.sharedInstance.load(fromData: data!, type: .geojson, completion: {
                                            if let asset = FeatureStore.sharedInstance.getAsset(for: .geojson) as? GeoJSONAsset {
                                                LocationStore.sharedInstance.load(fromAsset: asset)
                                                completion()
                                            } else {
                                                print("Error retrieving GeoJSON asset from FeatureStore")
                                            }
                                        })
                                    } catch {
                                        print("Error parsing geojson data from backend")
                                    }
                                }
                            })
                        }
                    })
                } catch {
                    print("Error parsing locations data from backend")
                }
            }
        })
    }
    
    public func registerDevice() throws {
        
        if Constants.backend.apiKey != nil && Constants.backend.host != nil && Constants.backend.registerEndpoint != nil {
        } else { throw BackendServiceError.backendConfigurationMissing }
        
        if !self.sufficientNotificationPermissions {
            throw BackendServiceError.insufficientPermissions
        }
        
        if self.deviceToken != nil {
            
            let data = [
                "name" : Constants.device.deviceName,
                "identifier" : Constants.device.deviceUUID,
                "push_token" : self.deviceToken!,
                "system_version" : Constants.device.systemVersion,
                "api_token" : Constants.backend.apiKey!
            ]
            var throwError : BackendServiceError?
            
            
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let url = URL(string: Constants.backend.host!)!.appendingPathComponent(Constants.backend.registerEndpoint!)
                
                
                CacheService.sharedInstance.makePostRequest(url: url, data: jsonData, completion: { statusCode, error in
                    if error != nil {
                        throwError = BackendServiceError.notRegisteredForRemoteNotifications
                    } else {
                        if statusCode != 200 {
                            throwError = BackendServiceError.notRegisteredForRemoteNotifications
                        } else {
                            self.registeredOnBackend = true
                            print("BackendService: Successfully registered to backend. (StatusCode \(String(describing: statusCode)))")
                        }
                    }
                })
            } catch {
                throw BackendServiceError.notRegisteredForRemoteNotifications
            }
            
            if throwError != nil {
                throw throwError!
            }
            
        } else {
            throw BackendServiceError.notRegisteredForRemoteNotifications
        }
    }
    
    func beginHealthReporting() throws {
        if Constants.backend.apiKey != nil && Constants.backend.host != nil && Constants.backend.healthCheckEndpoint != nil {
        } else { throw BackendServiceError.backendConfigurationMissing }
        
        print("BackendService: Beginning health reporting")
        self.healthTimer?.invalidate()
        self.healthTimer = Timer.scheduledTimer(timeInterval: Constants.backend.healthCheckInterval, target: self, selector: #selector(updateHealthStatus), userInfo: nil, repeats: true)
    }
    
    func pauseHealthReporting() {
        print("BackendService: Pausing health reporting")
        healthTimer?.invalidate()
    }
    
    @objc func updateHealthStatus() {
        print("BackendService: Updating Health Status...")
        if self.registeredOnBackend {
            
            let data = [
                "app_version" : Constants.device.appVersion,
                "log_type" : "info",
                "message" : "Battery Level: \(Constants.device.batteryLevel), WIFI: \(Constants.device.hasNetworkConnection), charging: \(Constants.device.isCharging)",
                "api_token" : Constants.backend.apiKey!,
                "device_identifier" : Constants.device.deviceUUID,
                "system_version" : Constants.device.systemVersion,
                "device_name" : Constants.device.deviceName
            ]
            
            do {
            
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let url = URL(string: Constants.backend.host!)!.appendingPathComponent(Constants.backend.healthCheckEndpoint!)
                
                CacheService.sharedInstance.makePostRequest(url: url, data: jsonData, completion: { statusCode, error in
                    if error != nil {
                        print("BackendService: Unable to update HealthStatus: \(String(describing: error))")
                    } else {
                        if statusCode != 200 {
                            print("BackendService: Unable to update HealthStatus")
                        } else {
                            print("BackendService: HealthStatus successfully updated")
                        }
                    }
                })
            } catch {
                print("BackendService: Unable to update HealthStatus")
            }
        }
    }
    
}

extension BackendService : UNUserNotificationCenterDelegate {
    
}
