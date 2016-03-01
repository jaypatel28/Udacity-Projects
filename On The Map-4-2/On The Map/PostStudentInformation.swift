//
//  PostStudentInformation.swift
//  On The Map
//
//  Created by Jay Patel on 12/17/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import Foundation
import UIKit

extension GetStudentInformations {
    
    func postInformation (){
//        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        print(self.appDelegate.uniqueKey)
    }
    
    func postNewLocation(latitude: Double, longitude: Double, mediaURL: String, mapString: String, didComplete: (success: Bool) -> Void) {
        
        let key = self.uniqueKey
        let firstName = self.account!.firstName
        let lastName = self.account!.lastName

        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyString = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
//                self.errors.append(error!)
                didComplete(success: false)
                return
            }
            didComplete(success: true)
        }
        task.resume()
    }
}
