//
//  MapView.swift
//  Events
//
//  Created by Omar Mihilmy on 1/28/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import Mapbox


var SelectedEvent: PFObject!
//These Arrays should be in Parse
var visitedEvents = [String]()
var litArray = [Bool]()
var nahArray = [Bool]()
var eventStrings = [String]()
var first_name = PFUser.currentUser()!["first_name"] as! String
var last_name = PFUser.currentUser()!["last_name"] as! String

class MapView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query1 = PFQuery(className: "_User")
        query1.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (user : PFObject?, error: NSError?) -> Void in
            if error == nil {
                eventStrings = user!["events"] as! [String]
            }
        }
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.map.showsUserLocation = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let currentDate = NSDate()
        //StartDate is + 15h
        let cutOff = currentDate.dateByAddingTimeInterval(540000)
        
        let query = PFQuery(className:"Events")
        query.whereKey("endDate", greaterThanOrEqualTo: currentDate)
        query.whereKey("startDate", lessThanOrEqualTo: cutOff)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // objects in results will only contain the location
                if let objects = objects{
                    for object in objects{
                        let x = object["location"] as! String
                        let y = object["title"] as! String
                        
                        let request = MKLocalSearchRequest()
                        request.naturalLanguageQuery = x
                        let search = MKLocalSearch(request: request)
                        search.startWithCompletionHandler{ (localSearchResponse, error) -> Void in
                            // Add PointAnnonation text and a Pin to the Map
                            //http://stackoverflow.com/questions/26991473/mkpointannotations-touch-event-in-swift
                            if(localSearchResponse != nil){
                                let annotation = CustomPinAnnotation()
                                annotation.title = y
                                annotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
                                annotation.EventObject = object
                                self.map.addAnnotation(annotation)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is CustomPinAnnotation{
        let v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        v.animatesDrop = true;
        
        v.canShowCallout = true;
        let detailButton = UIButton(type: UIButtonType.DetailDisclosure)
        v.rightCalloutAccessoryView = detailButton
        return v
        }
        
        return nil
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let w = view.annotation as! CustomPinAnnotation
        SelectedEvent = w.EventObject
        self.performSegueWithIdentifier("toEventDetails", sender: self)
    }
    
    
    //Location delegate methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //The greater the Span the greater the zoom out. Change to 0.5 if you want more zoom in feature
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.02, 0.02))
        self.map.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error.localizedDescription)
    }
    
    
    // MARK: -  REFRESH  BUTTON
    @IBAction func refreshButt(sender: AnyObject) {
        viewWillAppear(true)
        
        self.title = "The Move"
    }
    
    
   
    
}

