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
var visitedEvents1 = [String]()
var litArray1 = [Bool]()
var nahArray1 = [Bool]()
var eventStrings1 = [String]()
var first_name1 = PFUser.currentUser()!["first_name"] as! String
var last_name1 = PFUser.currentUser()!["last_name"] as! String





class MapViewColor: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var locationManager = CLLocationManager()
    var eventsArray1 = NSMutableArray()
    
    
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
        
        //self.mapView.showsUserLocation = true
     
        
        
        //query for events
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
                                let point = MGLPointAnnotation()
                                point.title = y
                                point.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                                //point.EventObject = object
                                self.eventsArray1.addObject(object)
                                self.mapView.addAnnotation(point)
                            }
                        }
                    }
                }
            }
        }
    
    
        
        
        
        
        
        
        // initialize the map view
        //mapView = MGLMapView(frame: view.bounds)
        let components = NSDateComponents()
        let currentHour = components.hour
        if ((currentHour > 6) && (currentHour < 8 )){
        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        } else {
            mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        }
        
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 38.894368,
            longitude: -77.036487),
            zoomLevel: 15, animated: false)
        view.addSubview(mapView)
        
        // Declare the annotation `point` and set its coordinates, title, and subtitle
        //let point = MGLPointAnnotation()
        //point.coordinate = CLLocationCoordinate2D(latitude: 38.894368, longitude: -77.036487)
        //point.title = "Hello world!"
        //point.subtitle = "Welcome to The Ellipse."
        
        // Add annotation `point` to the map
        //mapView.addAnnotation(point)
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
    }
    
    /* Tapping the marker */
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        
        return true
        
    }
    
 
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .DetailDisclosure)
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        mapView.deselectAnnotation(annotation, animated: false)
        
        //UIAlertView(title: annotation.title!!, message: "A lovely (if touristy) place.", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
        
        
        
        SelectedEvent = eventsArray1[0] as! PFObject
        let eventDetailsPage = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDeats
        navigationController?.pushViewController(eventDetailsPage, animated: true)
    }
    
    
}