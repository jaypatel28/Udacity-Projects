//
//  ViewController.swift
//  Udacity Virtual Tourist
//
//  Created by Russell Austin on 6/16/15.
//  Copyright (c) 2015 Russell Austin. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController, MKMapViewDelegate {
    
    struct Keys {
        static let region = "region"
    }
    
    /// Shows where the pin would be dropped once the touch ends
    var floatingPin: MKPointAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        
        restoreLastMapRegion()
        
        let pins = fetchAllPins()
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Touch event handling
    
    @IBAction func didLongPress(recognizer: UIGestureRecognizer) {
       
        let viewLocation = recognizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(viewLocation, toCoordinateFromView: mapView)
        var annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        switch recognizer.state {
        case .Ended:
            mapView.removeAnnotation(floatingPin!)
            let dictionary = ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
            let pin = Pin(dictionary: dictionary, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            mapView.addAnnotation(pin)
            pin.loadPhotos() { success in }
        case .Changed:
            mapView.removeAnnotation(floatingPin!)
            fallthrough
        default:
            floatingPin = annotation
            mapView.addAnnotation(annotation)
        }
    }
 
    // MARK: MapView delegate implementation
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
   
    // MARK: Fetch all
    func fetchAllPins()  -> [Pin] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        if error != nil {
            print("Error in fetchAllPins(): \(error)")
        }
        return results! as! [Pin]
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let pin = view.annotation as! Pin
        performSegueWithIdentifier("showAlbum", sender: view.annotation)
    }
    
    // MARK: Segue to Album
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController.childViewControllers[0] as! AlbumViewController
        vc.pin = sender as! Pin
    }
   
    // MARK: - Map region save and retrieve
    
    /**
    Use UserDefaults to restore the region
    */
    func restoreLastMapRegion() {
        if let regionDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(Keys.region) {
            
            let region = MKCoordinateRegionMake(
                CLLocationCoordinate2DMake(
                    regionDictionary["latitude"] as! Double,
                    regionDictionary["longitude"] as! Double
                ),
                MKCoordinateSpanMake(
                    regionDictionary["spanLatitude"] as! Double,
                    regionDictionary["spanLongitude"]as! Double
                )
            )
            mapView.setRegion(region, animated: true)
        }       
    }
    
    /**
    Use UserDefaults to save the region
    */
    func saveMapRegion() {
        let region = mapView.region
        let regionDictionary = [
            "latitude": region.center.latitude,
            "longitude": region.center.longitude,
            "spanLatitude":   region.span.latitudeDelta,
            "spanLongitude":   region.span.longitudeDelta
        ]
        
        NSUserDefaults.standardUserDefaults().setObject(regionDictionary, forKey: Keys.region)
    }
    
    // MARK: Core Data convenience method
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

}

