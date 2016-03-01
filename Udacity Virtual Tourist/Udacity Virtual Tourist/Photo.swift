//
//  Photo.swift
//  Udacity Virtual Tourist
//
//  Created by Jay Patel on 6/16/15.
//  Copyright (c) 2015 Jay Patel. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

enum DownloadStatus {
    case NotLoaded, Loading, Loaded
}

@objc(Photo)
class Photo: NSManagedObject {
   
    struct Keys {
        static let URL = "url"
        static let File = "file"
    }
   
    struct Config {
        static let flickrURLTemplate = ["https://farm", "{farm-id}", ".staticflickr.com/", "{server-id}", "/", "{id}", "_", "{secret}", "_z.jpg"]
        static let PhotoLoadedNotification = "PhotoLoadedNotification"
    }
    
    /// Whether all the photo has been downloaded
    var downloadStatus: DownloadStatus = .NotLoaded
   
    /// The Flickr URL
    @NSManaged var url: String
    
    /// The file name in the documents directory
    @NSManaged var file: String
    
    /// The associated pin
    @NSManaged var pin: Pin?
   
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let image = ImageCache.Static.instance.imageWithIdentifier(file) {
            downloadStatus = .Loaded
        }
    }
 
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        url = dictionary[Keys.URL] as! String
        file = dictionary[Keys.File] as! String
    }
   
    /**
    Builds the URL from the Flickr data

    :photo: The photo information
    - returns: The URL
    */
    class func buildFlickrUrl(photo: [String: AnyObject]) -> String {
        var photoUrlParts = Config.flickrURLTemplate
        photoUrlParts[1] = String(photo["farm"] as! Int)
        photoUrlParts[3] = photo["server"] as! String
        photoUrlParts[5] = photo["id"] as! String
        photoUrlParts[7] = photo["secret"] as! String

        return photoUrlParts.joinWithSeparator("")
    }
    
    /**
    Saves the image and marks the status as downloaded

    - parameter image: The image to save
    */
    func saveImage(image: UIImage) {
        dispatch_async(dispatch_get_main_queue()) {
            ImageCache.Static.instance.storeImage(image, withIdentifier: self.file)
            self.downloadStatus = .Loaded
            NSNotificationCenter.defaultCenter().postNotificationName(Config.PhotoLoadedNotification, object: self)
        }
    }
    
    func delete() {
        ImageCache.Static.instance.deleteImage(self.file)
        managedObjectContext?.deleteObject(self)
        
        let error = NSErrorPointer()
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error.memory = error1
        }
        if error != nil {
            print("Error deleting \(error)")
        }
    }
}