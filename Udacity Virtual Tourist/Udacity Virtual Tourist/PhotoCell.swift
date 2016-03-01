//
//  PhotoCell.swift
//  Udacity Virtual Tourist
//
//  Created by Jay Patel on 1/4/16.
//  Copyright © 2016 Jay Patel. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // From iOS Persistance course
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
