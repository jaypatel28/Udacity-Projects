//
//  StudentInformation.swift
//  On The Map
//
//  Created by Jay Patel on 12/15/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import Foundation
struct StudentInfo {
    // MARK: Properties
    static var studentsInfo: [StudentInfo]? = [StudentInfo]()
    var createdAt = ""
    var firstName = ""
    var lastName = ""
    var latitude = 0.0
    var longitude = 0.0
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    var updatedAt = ""
    
    init(uniqueKey:String, firstName: String, lastName:String){ //Initialize the required fields
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init(dictionary: [String : AnyObject]) {
        
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        uniqueKey = dictionary["uniqueKey"] as! String
        mapString = dictionary["mapString"] as! String
        objectId = dictionary["objectId"] as! String
    }
    
    
    static func informationsFromResults(results: [[String : AnyObject]]) -> [StudentInfo] {
        var movies = [StudentInfo]()
        
        for result in results {
            movies.append(StudentInfo(dictionary: result))
        }
        
        return movies
    }
}

