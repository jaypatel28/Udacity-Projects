//
//  GetStudentLocations.swift
//  On The Map
//
//  Created by Jay Patel on 12/15/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import Foundation
import UIKit

class GetStudentInformations {
    
    var sessionID: String?
    var uniqueKey: String?
    var account: StudentInfo?
    
    func getStudentInformations(completionHandler: (result: [StudentInfo]?, error: NSError?) -> Void) {
        
        self.getStudentDetails { movies, error in
            if let movies = movies {
                StudentInfo.studentsInfo = movies
                dispatch_async(dispatch_get_main_queue()) {
                    //self.moviesTableView.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    func getStudentDetails(completionHandler: (result: [StudentInfo]?, error: NSError?) -> Void) {
        
        taskForGETMethod() { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                if let results = JSONResult["results"] as? [[String : AnyObject]] {
                    
                    let movies = StudentInfo.informationsFromResults(results)
                    completionHandler(result: movies, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
                }
            }
        }
    }
    
    func taskForGETMethod(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var parameters:[String:AnyObject] = [String:AnyObject]()
        parameters["limit"] = 200
//        parameters["skip"] = 200
        parameters["order"] = "-updatedAt"
        
        let request = NSMutableURLRequest(URL: NSURL(string: GetStudentInformations.Methods.StudentLocations + self.escapedParameters(parameters))!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print("ERROR: Could not get Location of Students")
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
        self.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        task.resume()
        return task
        
    }
    
    func taskForNewLocationMethod(method: String, parse: Bool, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        
        
        /* 2/3. Build the URL and configure the request */
        var urlString:String
        if let mutableParameters = parameters {
            urlString = method + GetStudentInformations().escapedParameters(mutableParameters)
        }else{
            urlString = method
        }
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        if(parse){// Check it if is for the parse application and apply the keys
            request.addValue(GetStudentInformations.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(GetStudentInformations.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        /* 4. Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                var newData = data
                if(!parse){// If it isn't for parse, it is for the Udacity API which it requires to ommit the first 5 characters for security reasons
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                }
                self.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    func getUserDetail(uniqueKey: String, completionHandler: (result: StudentInfo?, error: String?) -> Void) {
//        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(uniqueKey)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print("Could not get User Information")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            if let userData = (try? NSJSONSerialization.JSONObjectWithData(newData, options: .MutableContainers)) as? NSDictionary,
                let user = userData["user"] as? [String: AnyObject],
                let firstName = user["first_name"] as? String,
                let lastName = user["last_name"] as? String
            {
                self.account = StudentInfo(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName)
                completionHandler(result: self.account , error: nil)
            }
        }
        task.resume()
    }
    
    func updateAccountLocation(account:StudentInfo,completionHandler: (result: Bool?, error: NSError?) -> Void) {
        let method = Methods.StudentLocations + "/" + account.objectId
        
        let jsonBody: [String:AnyObject] = [ GetStudentInformations.JSONBody.uniqueKey: account.uniqueKey,GetStudentInformations.JSONBody.firstName:account.firstName,GetStudentInformations.JSONBody.lastName:account.lastName,GetStudentInformations.JSONBody.mapString:GetStudentInformations.JSONBody.mapString,GetStudentInformations.JSONBody.mediaURL:account.mediaURL,GetStudentInformations.JSONBody.latitude:account.latitude,GetStudentInformations.JSONBody.longitude:account.longitude ]
        /* 2. Make the request */
        _ = taskForPUTMethod(method,parameters: nil , jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let _ = JSONResult.valueForKey(GetStudentInformations.JSONResponseKeys.UpdatedAt) as? String {
                    completionHandler(result: true, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "updateAccountLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateAccountLocation"]))
                }
            }
        }
    }
    
    func saveAccountLocation(account:StudentInfo,completionHandler: (result: Bool?, error: NSError?) -> Void) {
        let method = Methods.StudentLocations
        
        let jsonBody: [String:AnyObject] = [ GetStudentInformations.JSONBody.uniqueKey: account.uniqueKey,GetStudentInformations.JSONBody.firstName:account.firstName,GetStudentInformations.JSONBody.lastName:account.lastName,GetStudentInformations.JSONBody.mapString:GetStudentInformations.JSONBody.mapString,GetStudentInformations.JSONBody.mediaURL:account.mediaURL,GetStudentInformations.JSONBody.latitude:account.latitude,GetStudentInformations.JSONBody.longitude:account.longitude ]
        
        /* 2. Make the request */
        taskForNewLocationMethod(method,parse: true, parameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let _ = JSONResult.valueForKey(GetStudentInformations.JSONResponseKeys.ObjectID) as? String {
                    completionHandler(result: true, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "saveAccountLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse saveAccountLocation"]))
                }
            }
        }
    }
    
    func taskForPUTMethod(method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString:String
        if let mutableParameters = parameters {
            urlString = method + GetStudentInformations().escapedParameters(mutableParameters)
        }else{
            urlString = method
        }
        
        /* 2/3. Build the URL and configure the request */
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        //        var jsonifyError: NSError? = nil
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(GetStudentInformations.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(GetStudentInformations.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch _ as NSError {
            //            jsonifyError = error
            request.HTTPBody = nil
        }
        let session = NSURLSession.sharedSession()
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
//                _ = GetStudentInformations.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                self.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            _ = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
 
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> GetStudentInformations {
        
        struct Singleton {
            static var sharedInstance = GetStudentInformations()
        }
        
        return Singleton.sharedInstance
    }

}
