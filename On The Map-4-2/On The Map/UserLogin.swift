//
//  UserLogin.swift
//  On The Map
//
//  Created by Jay Patel on 12/18/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import Foundation
import UIKit

extension GetStudentInformations {
    
//    var appDelegate: AppDelegate!


    func userLogin(hostViewController: LoginViewController,didComplete: (success: Bool, error: NSError?) -> Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: GetStudentInformations.Methods.AuthenticationSessionNew)!)
        let userName = hostViewController.userNameTextField.text!
        let password = hostViewController.passwordTextField.text!
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                didComplete(success: false, error: error)
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
//                dispatch_async(dispatch_get_main_queue()) {
////                    self.setUIEnabled(enable: true)
////                    self.debugLabel.text = "Login Failed (Invalid Username/Password)"
//                }
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                didComplete(success: false, error: NSError(domain: "Invalid UserName/Password", code: 101, userInfo: nil))
                return
            }
            guard let data = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) else {
//                dispatch_async(dispatch_get_main_queue()) {
////                    self.setUIEnabled(enable: true)
//                }
                print("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
//                dispatch_async(dispatch_get_main_queue()) {
////                    self.setUIEnabled(enable: true)
//                }
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let account = parsedResult["account"] as? NSDictionary else {
                print("Could not find key 'Accont' in \(parsedResult)")
                return
            }
            
            guard let uniqueKey = account["key"] as? String else {
                print("Could not find key 'key' in \(account)")
                return
            }
            
            
            guard let sessionKey = parsedResult["session"] as? NSDictionary else {
                print("Could not find session Key")
                return
            }
            
            guard let sessionID = sessionKey["id"] as? String else {
                print("Could not find id key")
                return
            }
            
            self.uniqueKey = uniqueKey
            self.sessionID = sessionID
            
            self.getUserDetail(self.uniqueKey!)  { account,errorString in
                if account != nil{
                    
                }
            }
            
            didComplete(success: true, error: nil)
        }
        task.resume()
    }
    
    func userLogout(didComplete: (success: Bool) -> Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: GetStudentInformations.Methods.AuthenticationSessionNew)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            didComplete(success: true)
        }
        task.resume()
    }
    
    func authenticateForNewLocation(hostViewController: UIViewController, completionHandler: (success: [Bool], errorString: String?) -> Void) {
        GetStudentInformations.sharedInstance().queryStudentLocation(GetStudentInformations.sharedInstance().account!.uniqueKey){ result,errorString in
            if let _ = errorString {
                completionHandler(success: [false,false], errorString: "Couldn't query for Student Location")
                
            }else{
                if result != nil{//THen it is an update
                    dispatch_async(dispatch_get_main_queue()){
                        completionHandler(success: [true,true], errorString: nil)
                    }
                }else{//Not an update. New record will be created(update variable remains false)
                    completionHandler(success: [true,false], errorString: nil)
                }
            }
        }
    }
    
    func queryStudentLocation(uniqueKey: String,completionHandler: (result: StudentInfo?, error: String?) -> Void) {
        var parameters:[String:AnyObject] = [String:AnyObject]()
        
        parameters["where"] = "%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D" //Dirty solution to create a json object string for the url.
        
        let method = Methods.StudentLocations + GetStudentInformations().escapedParameters(parameters)
        /* 2. Make the request */
        taskForNewLocationMethod(method,parse: true, parameters: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let _ = error{
                completionHandler(result: nil, error: "Failed to get User Data")
            } else {
                if let results = JSONResult.valueForKey(GetStudentInformations.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    var student:StudentInfo?
                    if(results.count > 0){
                        student = StudentInfo(dictionary: results[0])
                        GetStudentInformations.sharedInstance().account = student
                        
                    }else{
                        student = nil
                    }
                    completionHandler(result: student , error: nil)
                } else {
                    completionHandler(result: nil, error: "Failed to retrieve User Data")
                }
            }
        }
    }
}