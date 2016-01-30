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

class MapView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var locations = [String]()
    
    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.map.showsUserLocation = true
        
        let query = PFQuery(className:"Events")
        query.selectKeys(["location","title"])
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
                            
                            let annotation = MKPointAnnotation()
                            annotation.title = y
                            annotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
                            
                            self.map.addAnnotation(annotation)
                    }

                }
            }
        }
        
        
        
        /*
        let annotation = MKPointAnnotation()
        anotation.title
        anotation.subtitle
        anotation.coordinate
        map.addAnotation()
        */
                
        
    }
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
    
    
   
    
}

