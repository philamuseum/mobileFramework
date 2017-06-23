//
//  QueueControllerDelegateSpy.swift
//  mobileFramework
//
//  Created by Peter.Alt on 6/14/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class QueueControllerDelegateSpy : NSObject, QueueControllerDelegate {
    
    func QueueControllerDownloadInProgress(queueController: QueueController, withProgress progress: Float, tasksTotal: Int, tasksLeft: Int) {
        
    }

    var didFinishDownloading = false
    var progress : Float = -1
    
    func QueueControllerDidFinishDownloading(queueController: QueueController) {
        self.didFinishDownloading = true
    }
    
    func QueueControllerDownloadInProgress(queueController: QueueController, withProgress progress: Float) {
        self.progress = progress
    }
}
