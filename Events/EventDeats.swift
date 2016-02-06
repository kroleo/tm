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
        //Check for user  or nah for specific event
        if(!visitedEvents.contains(SelectedEvent.objectId!)){
            visitedEvents.append(SelectedEvent.objectId!)
            litArray.append(false)
            nahArray.append(false)
        }
        
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
        
        let ArrayOfGoers = SelectedEvent["going"] as! Array<String>
        var numberOfGoing = ArrayOfGoers.count
        if(numberOfGoing > 4){
            numberOfGoing = 4;
        }
        
        var lastIndex = ArrayOfGoers.count - 1
        var i = 1
        while(i <= numberOfGoing){
            //User Query to find the User at the End of the Going Array. End of the Array as he is the most recent
            var image_file = PFFile()
            let userQuery2 = PFQuery(className: "_User")
            
            userQuery2.getObjectInBackgroundWithId(ArrayOfGoers[lastIndex]) {
                    (user: PFObject?, error: NSError?) -> Void in
                    if error == nil && user != nil {
                        image_file = user!["profile_picture"] as! PFFile
                        image_file.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                            if error == nil {
                                print("error == nil")
                                if let imageData = imageData {
                                    if (i == 1){
                                        print("Image 1")
                                        self.going1.layer.cornerRadius = self.going1.frame.size.width / 2;
                                        self.going1.image = UIImage(data:imageData)
                                    }else if (i == 2){
                                        print("Image 2")
                                        self.going2.layer.cornerRadius = self.going2.frame.size.width / 2;
                                        self.going2.image = UIImage(data:imageData)
                                    }else if(i == 3){
                                        print("Image 3")
                                        self.going3.layer.cornerRadius = self.going3.frame.size.width / 2;
                                        self.going3.image = UIImage(data:imageData)
                                    }else{
                                        print("Image 4")
                                        self.going4.layer.cornerRadius = self.going4.frame.size.width / 2;
                                        self.going4.image = UIImage(data:imageData)
                                    }
                                    
                                }
                            }
                        }
                }
            }
            i++
            lastIndex--

        }
        
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
    @IBAction func nah(sender: AnyObject) {
        let index = visitedEvents.indexOf(SelectedEvent.objectId!)
        let lits = SelectedEvent["Lit"] as! Int
        let nahs = SelectedEvent["Nah"] as! Int
        if(litArray[index!]){
            SelectedEvent["Lit"] = lits - 1
            SelectedEvent["Nah"] = nahs + 1
            litArray[index!] = false
            nahArray[index!] = true
        }else if(!nahArray[index!]){
            SelectedEvent["Nah"] = nahs + 1
            nahArray[index!] = true
        }else{
            let alert = UIAlertView()
            alert.title = "You can't Nah an Event more than once"
            alert.addButtonWithTitle("Okay")
            alert.show()
        }
        
        SelectedEvent.saveInBackground()
    }
    
    @IBAction func lit(sender: AnyObject) {
        let index = visitedEvents.indexOf(SelectedEvent.objectId!)
        let lits = SelectedEvent["Lit"] as! Int
        let nahs = SelectedEvent["Nah"] as! Int
        
        if(nahArray[index!]){
            SelectedEvent["Lit"] = lits + 1
            SelectedEvent["Nah"] = nahs - 1
            litArray[index!] = true
            nahArray[index!] = false
        }else if(!litArray[index!]){
            SelectedEvent["Lit"] = nahs + 1
            litArray[index!] = true
        }else{
            let alert = UIAlertView()
            alert.title = "You can't Lit an Event more than once"
            alert.addButtonWithTitle("Okay")
            alert.show()
        }
        
        SelectedEvent.saveInBackground()
    }
    
}
