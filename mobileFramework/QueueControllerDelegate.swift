//
//  QueueControllerDelegate.swift
//  mobileFramework
//
//  Created by Peter.Alt on 6/14/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public protocol QueueControllerDelegate : NSObjectProtocol {
    func QueueControllerDidFinishDownloading(queueController: QueueController)
    func QueueControllerDownloadInProgress(queueController: QueueController, withProgress progress: Float, tasksTotal: Int, tasksLeft: Int)
}
