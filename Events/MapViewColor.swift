//
//  MapViewColor.swift
//  Events
//
//  Created by Harsha Cuttari on 2/14/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import Mapbox


//These Arrays should be in Parse
var SelectedEvent: PFObject!
var visitedEvents = [String]()
var litArray = [Bool]()
var nahArray = [Bool]()
var eventStrings = [String]()
var first_name = PFUser.currentUser()!["first_name"] as! String
var last_name = PFUser.currentUser()!["last_name"] as! String

class MapViewColor: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    
    @IBOutlet var colorMapView: UIView!
    var mapView: MGLMapView!
    var locationManager = CLLocationManager()
    var pinImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "The Move"
        
        let currentHour = NSDate().hour()
        if ((currentHour > 6) && (currentHour < 20 )){
            mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL())
            pinImage = UIImage(named: "mapPinBlack")
        } else {
            mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
            pinImage = UIImage(named: "mapPinColor")
        }
        
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        
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
        
        self.mapView.showsUserLocation = true
        self.mapView.attributionButton.hidden = true
        colorMapView.addSubview(mapView)
        self.mapView.delegate = self

        
    }
    
//    override func viewDidAppear(animated: Bool) {
//        // Wait a bit before setting a new camera.
//        
//        // Create a camera that rotates around the same center point, back to 0°.
//        // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
//        let camera = MGLMapCamera(lookingAtCenterCoordinate: mapView.centerCoordinate, fromDistance: 2000, pitch: 0, heading: 0)
//        
//        // Animate the camera movement over 5 seconds.
//        mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
//    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        queryLatestEvents()

    }
    
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if annotation is CustomPinAnnotation{
            return true
        }else{
            return false
        }
        
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return MGLAnnotationImage(image: pinImage, reuseIdentifier: "pin")
    }
    
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        let detailButton = UIButton(type: UIButtonType.DetailDisclosure)
        detailButton.setImage(UIImage(named: "rightAnnotationButton"), forState: .Normal)
        detailButton.tintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return detailButton
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        mapView.deselectAnnotation(annotation, animated: true)
        let w = annotation as! CustomPinAnnotation
        SelectedEvent = w.EventObject
        let eventDetailsPage = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDeats
        navigationController?.pushViewController(eventDetailsPage, animated: true)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //The greater the Span the greater the zoom out. Change to 0.5 if you want more zoom in feature
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.02, 0.02))
        self.mapView.setCenterCoordinate(center, zoomLevel: 15, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error.localizedDescription)
    }
    
    func queryLatestEvents(){
        
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
                        search.startWithCompletionHandler{(localSearchResponse, error) -> Void in
                            
                            if(localSearchResponse != nil){
                                let point = CustomPinAnnotation()
                                point.title = y
                                
                                point.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                                point.EventObject = object
                                self.mapView.addAnnotation(point)
                            }
                        }
                    }
                }
            }
        }
        
    }

    @IBAction func refreshButt(sender: AnyObject) {
        queryLatestEvents()

    }
    
    
    
}