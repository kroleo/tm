//
//  EventDeats.swift
//  Events
//
//  Created by Omar Mihilmy on 1/31/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse

class EventDeats: UIViewController{

    @IBOutlet var title1: UILabel!
    
    @IBOutlet var location1: UILabel!
    
    @IBOutlet var time1: UILabel!
    
    @IBOutlet var image1: UIImageView!
    
    @IBOutlet var going1: UIImageView!
    
    @IBOutlet var going2: UIImageView!
    
    @IBOutlet var going3: UIImageView!
    
    @IBOutlet var going4: UIImageView!
    
    @IBOutlet var going: UIButton!
    var userQuery: PFQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userQuery = PFQuery(className: "_User")
       
        
        //You will need to know which view you are coming from
        
        //If coming from Maps
        
        title1.text = SelectedEvent["title"] as? String
        
        location1.text = SelectedEvent["location"] as? String
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MMM d, h:mm a"
        time1.text = dateFormat.stringFromDate(SelectedEvent["startDate"] as! NSDate)
        
        let imageFile =  SelectedEvent["image"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image1.layer.cornerRadius = self.image1.frame.size.width / 2;
                    self.image1.image = UIImage(data:imageData)
                } } }
        
        //Add the goers to the images
        
        //Check to see if the current user has this event as going or not
        
        userQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!){
            (user: PFObject?, error: NSError?) -> Void in
            if error == nil {
               var found = false
                let array = user?.objectForKey("events") as! Array<String>
                for s in array{
                    if(s == SelectedEvent.objectId){
                        found = true
                        break
                    }
                }
                
                if(found){
                    self.going.selected = true
                }else{
                    self.going.selected = false
                }

            }
        }
        
    }
    
    func isNotNSNull(object:AnyObject) -> Bool {
        return object.classForCoder != NSNull.classForCoder()
    }
    
    @IBAction func go(sender: UIButton) {
        
        if(sender.selected){
            sender.selected = false
            //remove the event from the event db
            SelectedEvent.removeObject((PFUser.currentUser()?.objectId)!, forKey: "going")
            //remove the event from the user db
            userQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!){
                (user: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    user?.removeObject(SelectedEvent.objectId!, forKey: "events")
                }
                user?.saveInBackground()
            }
        }else{
            sender.selected = true
            //Coming from Maps: try to make the STRING generic in the decleration depending on the previous view
            //add the user from the event db
            SelectedEvent.addObject((PFUser.currentUser()?.objectId)!, forKey: "going")
            //add the user to the event db
            userQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!){
                (user: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    user?.addObject(SelectedEvent.objectId!, forKey: "events")
                }
                user?.saveInBackground()
            }
        }
        SelectedEvent.saveInBackground()
    }
    
    
}
