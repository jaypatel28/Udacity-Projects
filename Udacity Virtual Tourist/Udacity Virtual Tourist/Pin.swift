//
//  Pin.swift
//  Udacity Virtual Tourist
//
//  Created by Jay Patel on 6/16/15.
//  Copyright (c) 2015 Jay Patel. All rights reserved.
//

import Foundation
import CoreData
import MapKit


@objc(Pin)
class Pin: NSManagedObject, MKAnnotation {

    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    struct Config {
        static let Radius = 5 /* kilometers */
        static let AllPhotosLoadedForPinNotification = "AllPhotosLoadedForPinNotification"
    }
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    /// What page of the results to load
    @NSManaged var page: Int
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
        }
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
        
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        page = 1
    }
    
    /// Loads the photos associated with the pin
    func loadPhotos(getNextPage: Bool = false, didCompleteSearch: (numberFound: Int) -> Void) {
        if getNextPage {
            page++
        }
        searchFlickr() { count in
            didCompleteSearch(numberFound: count)
            if count > 0 {
                self.preloadPhotos()
            }
        }
    }
    
    /// Deletes the current photo set
    func deletePhotos() {
        for photo in photos {
            photo.delete()
        }
    }

    
    func searchFlickr(didComplete: (numberFound: Int) -> Void) {
        var methodArguments = [
            "method": FlickrClient.Methods.Search,
            "api_key": FlickrClient.FlickrConstants.APIKey,
            "bbox": FlickrClient.sharedInstance().createBoundingBoxString(coordinate),
            "extras": FlickrClient.FlickrConstants.Extras,
            "format": FlickrClient.FlickrConstants.DataFormat,
            "nojsoncallback": FlickrClient.FlickrConstants.NoJSONCallbank,
            "per_page": FlickrClient.FlickrConstants.Limit,
            "page": "\(page)"
        ]
        
        let url = FlickrClient.FlickrConstants.BaseURL + NetworkHelper.escapedParameters(methodArguments)
        let request = NSURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print("Error searching Flickr \(error)")
                didComplete(numberFound: 0)
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                let count = self.savePhotosForPin(data!)
                didComplete(numberFound: count)
            }
        }
        task.resume()
    }

    func savePhotosForPin(data: NSData) -> Int {
        var count = 0
        if let search = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as? NSDictionary {
            if let photoData = search["photos"] as? [String: AnyObject],
                let photos = photoData["photo"] as? [AnyObject]
            {
                for photo in photos {
                    let file = photo["id"] as! String
                    let photoUrl = Photo.buildFlickrUrl(photo as! [String : AnyObject])
                    let dict = ["url": photoUrl, "file": file]
                    let photo = Photo(dictionary: dict, context: self.managedObjectContext!)
                    photo.pin = self
                    
                    let error = NSErrorPointer()
                    do {
                        try self.managedObjectContext?.save()
                    } catch let error1 as NSError {
                        error.memory = error1
                    }
                    
                    if error != nil {
                        print("Error saving photo \(error)")
                        break
                    }
                    count++
                }
            }
        }
        return count
    }
    
    /// Downloads the photos associated with the pin
    func preloadPhotos() {
        var unloadedPhotos = photos.count
        for photo in photos {
            photo.downloadStatus = .Loading
            let task = ImageCache.Static.instance.downloadImage(photo.url) { imageData, error in                
                // keep track of the loaded photos
                unloadedPhotos--
                
                if imageData == nil {
                    return
                }
                let image = UIImage(data: imageData!)
                photo.saveImage(image!)
                if unloadedPhotos == 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName(Config.AllPhotosLoadedForPinNotification, object: self)
                }
            }
        }
    }
}
