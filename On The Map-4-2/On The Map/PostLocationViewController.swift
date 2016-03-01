//
//  PostLocationViewController.swift
//  udacity-on-the-map
//
//  Created by Russell Austin on 6/12/15.
//  Copyright (c) 2015 Ra Ra Ra. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var locationEntryView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var urlTextContainer: UIView!
    @IBOutlet weak var geocodingIndicator: UIActivityIndicatorView!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var update = false
    
    var appDelegate: AppDelegate!
    var location: CLLocation?
    var mapString: String = ""
    
    @IBAction func didPressCancel(sender: AnyObject) {
        self.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        mapView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapTextContainer:")
        urlTextContainer.addGestureRecognizer(tapGesture)
        locationTextField.delegate = self
        urlTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didTapTextContainer(sender: AnyObject) {
        urlTextField.becomeFirstResponder()
    }
    
    func cancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancel(action:UIAlertAction! ){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressFind(sender: UIButton) {
        
        let text = locationTextField.text!
        if text.isEmpty{
            self.showAlert(message: "Enter Location")
        }
        if !text.isEmpty {
            if self.mapView.annotations.count != 0{
                annotation = self.mapView.annotations[0]
                self.mapView.removeAnnotation(annotation)
            }
            
            startGeoLoading()
            
            localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = text
            localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
                
                if localSearchResponse == nil{
                    self.stopGeoLoading()
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                    
                }
                //3
 
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.title = text
                self.mapString = text
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
                
                
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                
                self.locationEntryView.hidden = true
                self.mapContainerView.hidden = false
                self.stopGeoLoading()
        }
    }
    }
    
    func startGeoLoading() {
        geocodingIndicator.startAnimating()
        locationEntryView.alpha = 0.5
    }
    
    func stopGeoLoading() {
        geocodingIndicator.stopAnimating()
        locationEntryView.alpha = 1
    }

    @IBAction func didPressSubmit(sender: UIButton) {

                if urlTextField.text!.isEmpty{
                    showAlert(message: "Enter a Link")
                } else if locationTextField.text!.isEmpty {
                    showAlert(message: "Enter a Location")
                } else{
                    let coord = pointAnnotation.coordinate
                        //Set the Account's next retrieved fields (First Name,Last Name was already retrieved from loging in)
                        GetStudentInformations.sharedInstance().account?.mapString = mapString
                        GetStudentInformations.sharedInstance().account?.mediaURL = urlTextField.text!
                        GetStudentInformations.sharedInstance().account?.latitude = coord.latitude
                        GetStudentInformations.sharedInstance().account?.longitude = coord.longitude
                        
                        var objectID = GetStudentInformations.sharedInstance().account?.objectId //Get the objectId to update the record
                        if let oid = GetStudentInformations.sharedInstance().account?.objectId {
                            GetStudentInformations.sharedInstance().updateAccountLocation(GetStudentInformations.sharedInstance().account!){ result,error in
                                if error != nil{
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.showAlert(message: "Could not update Location")
                                    })
                                }else if let r = result {
                                    if r {
                                        dispatch_async(dispatch_get_main_queue(),{
                                            var alert = UIAlertController(title: "", message: "Location updated", preferredStyle: UIAlertControllerStyle.Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: self.cancel))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(),{
                                            self.showAlert(message: "Could not save Location")
                                        })
                                    }
                                }
                            }
                        }else{ //If the record was not present create a new record.
                            GetStudentInformations.sharedInstance().saveAccountLocation(GetStudentInformations.sharedInstance().account!){ result,error in
                                if error != nil{
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.showAlert(message: "Could not save Location")
                                    })
                                }else if let r = result {
                                    if r {
                                        dispatch_async(dispatch_get_main_queue(),{
                                            var alert = UIAlertController(title: "", message: "Location Saved", preferredStyle: UIAlertControllerStyle.Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: self.cancel))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(),{
                                            self.showAlert(message: "Could not save Location")
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
    
    
    func showAlert(message message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
