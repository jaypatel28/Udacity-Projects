//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jay Patel on 12/14/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
  

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    
    @IBOutlet var loginView: UIView!
    let udacityLoginPageUrl = "https://www.udacity.com/account/auth#!/signin"
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginToUdacity(sender: AnyObject) {
        if userNameTextField.text!.isEmpty {
            self.showAlert(message: "User Name Empty")
        } else if passwordTextField.text!.isEmpty {
            self.showAlert(message: "Password Empty")
        } else {
            debugLabel.text = ""
            self.setUIEnabled(enable: false);
            self.sessionID()
        }
    }
    
    @IBAction func signUpToUdacity(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        let udacityLoginPage = NSURL(string: udacityLoginPageUrl)!
        app.openURL(udacityLoginPage)
    }
    
    func sessionID(){
        startLoading()
        let userName = userNameTextField.text!
        let password = passwordTextField.text!
        GetStudentInformations.sharedInstance().userLogin(self) { success, error in
            if error?.code == 101 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.setUIEnabled(enable: true)
                    self.stopLoading()
                    self.showAlert(message: "Invalid Username/Password")
                }

            } else if error != nil {
                dispatch_async(dispatch_get_main_queue()){
                    self.setUIEnabled(enable: true)
                    self.stopLoading()
                    self.showAlert(message: "Connection Failure")
                }
            }
            
            if success {
                dispatch_async(dispatch_get_main_queue()){
                    self.stopLoading()
                    self.completeLogin()
                }
            }
            
            }
    }
    /*
    func getSessionId(){
        self.startLoading()
        
        let userName = userNameTextField.text!
        let password = passwordTextField.text!
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                dispatch_async(dispatch_get_main_queue()) {
                    self.setUIEnabled(enable: true)
                    self.debugLabel.text = "Login Failed (Request Session ID)."
                }
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.setUIEnabled(enable: true)
                    self.debugLabel.text = "Login Failed (Invalid Username/Password)"
                }
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            guard let data = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.setUIEnabled(enable: true)
                }
                print("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self.setUIEnabled(enable: true)
                }
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
            

            self.appDelegate.uniqueKey = uniqueKey
            self.appDelegate.sessionID = sessionID
            self.completeLogin()

            GetStudentInformations().getUserDetail { success in
                if success {
                    
                }
            }
            
        }
        task.resume()
    }
*/
    
    
    func completeLogin() {

        dispatch_async(dispatch_get_main_queue(), {
            self.debugLabel.text = ""
            self.stopLoading()
            self.setUIEnabled(enable: true)
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationsTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func setUIEnabled(enable enable: Bool){
        userNameTextField.enabled = enable
        passwordTextField.enabled = enable
        loginButton.enabled = enable
        signUpButton.enabled = enable
    }
    
    func startLoading() {
        loadingActivity.startAnimating()
        loginView.alpha = 0.5
    }
    
    func stopLoading() {
        loadingActivity.stopAnimating()
        loginView.alpha = 1
    }
    
    func showAlert(message message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
