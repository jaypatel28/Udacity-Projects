//
//  FlickrClient.swift
//  Udacity Virtual Tourist
//
//  Created by Jay Patel on 1/4/16.
//  Copyright © 2016 Jay Patel. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FlickrClient {
    struct FlickrConstants {
            static let BaseURL : String = "https://api.flickr.com/services/rest/"
            static let APIKey : String = "f2e649460158aa34393a62b8f0517534"
            static let Extras : String = "url_m"
            static let DataFormat : String = "json"
            static let NoJSONCallbank = "1"
            static let BoundingBoxHalfWidth = 1.0
            static let BoundingBoxHalfHeight = 1.0
            static let Limit = "12"
            static let page = 1
        }
    struct Methods{
        static let Search: String = "flickr.photos.search"
    }
    
    func createBoundingBoxString(coordinates: CLLocationCoordinate2D) -> String {
            let latitude = coordinates.latitude
            let longitude = coordinates.longitude
            
            return "\(longitude - FlickrConstants.BoundingBoxHalfWidth),\(latitude - FlickrConstants.BoundingBoxHalfHeight),\(longitude + FlickrConstants.BoundingBoxHalfWidth),\(latitude + FlickrConstants.BoundingBoxHalfHeight)"
    }

    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}