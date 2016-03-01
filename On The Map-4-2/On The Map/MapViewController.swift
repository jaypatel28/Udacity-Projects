
import UIKit
import MapKit



class MapViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    var update = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        getStudentData()
    }
    @IBAction func PostStudentData(sender: AnyObject) {
        self.newLocation()
    }
    @IBAction func reloadData(sender: AnyObject) {
        getStudentData()
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Purple
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if !app.openURL(NSURL(string: toOpen)!){
                    let alertController = UIAlertController(title: "Invalid Link", message: toOpen, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getStudentData(){
        self.startLoading()
        GetStudentInformations().getStudentDetails { studentsInfo, error in
            if let studentsInfo = studentsInfo {
                StudentInfo.studentsInfo = studentsInfo
                let students = StudentInfo.studentsInfo
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopLoading()
                    let locations = students
                    var annotations = [MKPointAnnotation]()
                    
                    for dictionary in locations! {
                        
                        
                        // Notice that the float values are being used to create CLLocationDegree values.
                        // This is a version of the Double type.
                        let lat = CLLocationDegrees(dictionary.latitude)
                        let long = CLLocationDegrees(dictionary.longitude)
                        
                        // The lat and long are used to create a CLLocationCoordinates2D instance.
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let first = dictionary.firstName
                        let last = dictionary.lastName
                        let mediaURL = dictionary.mediaURL
                        
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        
                        // Finally we place the annotation in an array of annotations.
                        annotations.append(annotation)
                    }
                    
                    // When the array is complete, we add the annotations to the map.
                    self.mapView.addAnnotations(annotations)

                    
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
//    func presentEnterLocationViewController(){
//        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("PostLocationViewController") as! PostLocationViewController
//        detailController.update = self.update
//        detailController.update = self.update // Mark if it is for update or not
//        let navController = UINavigationController(rootViewController: detailController) // Creating a navigation controller with detailController at the root of the navigation stack.
//        self.navigationController!.presentViewController(navController, animated: true) {
//            self.navigationController?.popViewControllerAnimated(true)
//            return ()
//        }
//    }
    
    func startLoading() {
        loadingActivity.startAnimating()
        mapView.alpha = 0.5
    }
    
    func stopLoading() {
        loadingActivity.stopAnimating()
        mapView.alpha = 1
    }
    
    @IBAction func logoutButtonClick(sender: AnyObject) {
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
    
    func showAlert(message message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}