//
//  ListViewController.swift
//  On The Map
//
//  Created by Jay Patel on 12/16/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import UIKit

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    var students = StudentInfo.studentsInfo
    var update = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStudentData()
        // Do any additional setup after loading the view.
    }

    @IBAction func PostStudentData(sender: AnyObject) {
        self.newLocation()
    }
    @IBAction func reloadData(sender: AnyObject) {
        getStudentData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.students!.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let locations = self.students

            let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell")!
            let studentInfo = self.students![indexPath.row]
            
            // Set the name and image
            cell.textLabel?.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
            cell.imageView?.image = UIImage(named: "pin")
            
            // If the cell has a detail label, we will put the evil scheme in.
            if let detailTextLabel = cell.detailTextLabel {
                detailTextLabel.text = "\(studentInfo.mediaURL)"
            }
            
            return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = self.students![indexPath.row]
        let app = UIApplication.sharedApplication()
        let toOpen = studentInfo.mediaURL
        if !app.openURL(NSURL(string: toOpen)!){
            let alertController = UIAlertController(title: "Invalid Link", message: toOpen, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }

        
    }
    
    func getStudentData(){
        self.startLoading()
        GetStudentInformations().getStudentDetails { studentsInfo, error in
            if let studentsInfo = studentsInfo {
                self.students = studentsInfo
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopLoading()
                    self.tableView.reloadData()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    self.stopLoading()
                    self.showAlert(message: "ERROR: Could not load locations")
                }
            }
        }
    }
    
    @IBAction func LogoutButtonClick(sender: AnyObject) {
        logout()
    }
    
    func logout() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        GetStudentInformations.sharedInstance().userLogout { success in
            if success {
                GetStudentInformations.sharedInstance().uniqueKey = nil
                GetStudentInformations.sharedInstance().sessionID = nil
                GetStudentInformations.sharedInstance().account = nil
                StudentInfo.studentsInfo = []
            }
        }
        
    }
    
    func overwrite(alert: UIAlertAction!){
        self.update = true //Mark for overwrite(update)
        self.presentEnterLocationViewController()
    }
    
    func newLocation(){
        
        GetStudentInformations.sharedInstance().authenticateForNewLocation(self) {success, error in
            if error != nil {
                self.showAlert(message: error!)
            } else {
                if success == [true,true] {
                    dispatch_async(dispatch_get_main_queue()){
                        let alert = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: self.overwrite))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true,completion:nil)
                    }
                }else if success == [true,false]{
                    dispatch_async(dispatch_get_main_queue()){
                        self.presentEnterLocationViewController()
                    }
                }
                
            }
            
        }
    }
    
    func presentEnterLocationViewController(){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("PostLocationViewController") as! PostLocationViewController
        detailController.update = self.update
        detailController.update = self.update // Mark if it is for update or not
        performSegueWithIdentifier("postLocation", sender: self)
        return()
    }
    

    func startLoading() {
        loadingActivity.startAnimating()
        tableView.alpha = 0.5
    }
    
    func stopLoading() {
        self.loadingActivity.stopAnimating()
        tableView.alpha = 1
    }
    
    func showAlert(message message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }


}
