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
    
    @IBOutlet var time2: UILabel!
    
    @IBOutlet var image1: UIImageView!
    
    @IBOutlet var going1: UIImageView!
    
    @IBOutlet var going2: UIImageView!
    
    @IBOutlet var going3: UIImageView!
    
    @IBOutlet var going4: UIImageView!
    
    @IBOutlet var going: UIButton!
    
    @IBOutlet var otherGoing: UIButton!
    
    @IBOutlet weak var rateProgress: UIProgressView!

    @IBOutlet weak var eventImageBackground: UIView!
    
    @IBOutlet weak var eventImageFirstLetter: UILabel!
    
    @IBOutlet weak var rateProgress2: UIProgressView!
    
    @IBOutlet weak var rateProgress3: UIProgressView!
    
    var eventObj = PFObject(className: EVENTS_CLASS_NAME)

    var ratePercent:Float = 0;
    @IBOutlet var percentageLit: UILabel!
    

    //Force going images to be circular
    @IBOutlet weak var viewGoing1: UIView!
    
    @IBOutlet weak var viewGoing2: UIView!
    
    @IBOutlet weak var viewGoing3: UIView!
    
    @IBOutlet weak var viewGoing4: UIView!    
    
    
    
    
    
    
    //let index = visitedEvents.indexOf(SelectedEvent.objectId!)
    var rateLit = SelectedEvent["Lit"] as! Float
    var rateNah = SelectedEvent["Nah"] as! Float


    
    func progBarUpdate(){
        ratePercent = (rateLit / (rateLit + rateNah));
        //FIX HEIGHT!
        rateProgress.frame.size.height = 8;
        if (rateLit == 0){
            
            rateProgress.setProgress(0, animated: true)
            rateProgress2.setProgress(0, animated: true)
            rateProgress3.setProgress(0, animated: true)
            //rateProgress.frame.size.height = 8;
            percentageLit.hidden = true
            
        } else {
        
            rateProgress.setProgress(ratePercent, animated: true)
            rateProgress2.setProgress(ratePercent, animated: true)
            rateProgress3.setProgress(ratePercent, animated: true)
            //rateProgress.frame.size.height = 8;
            percentageLit.hidden = false
            
            //String(format:"%.2f", ratePercent)
            let actualPercentage = ratePercent * 100
            let twoDigits = String(format:"%.0f", actualPercentage)
            
            percentageLit.text = "\(twoDigits)" + "%"
        }
        
    }
    

    
    
    var userQuery: PFQuery!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        progBarUpdate()
        
        
        //Check for user  or nah for specific event
        if(!visitedEvents.contains(SelectedEvent.objectId!)){
            visitedEvents.append(SelectedEvent.objectId!)
            litArray.append(false)
            nahArray.append(false)
        }
        
        //You will need to know which view you are coming from
        
        //If coming from Maps
        
        title1.text = SelectedEvent["title"] as? String
        
        
        //going event image force circles
        self.viewGoing1.layer.cornerRadius = self.viewGoing1.frame.size.width / 2;
        self.viewGoing2.layer.cornerRadius = self.viewGoing2.frame.size.width / 2;
        self.viewGoing3.layer.cornerRadius = self.viewGoing3.frame.size.width / 2;
        self.viewGoing4.layer.cornerRadius = self.viewGoing4.frame.size.width / 2;
        
        
        
        
        //Make event image
        
        self.eventImageBackground.layer.cornerRadius = self.eventImageBackground.frame.size.width / 2;
        
        let fullTitle = "\(SelectedEvent["title"]!)"
        let firstLetter = fullTitle[fullTitle.startIndex]
        
        self.eventImageFirstLetter.text = "\(firstLetter)".uppercaseString

        location1.text = "\(SelectedEvent["location"]!)".uppercaseString
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MMM d, h:mm a"
        time1.text = dateFormat.stringFromDate(SelectedEvent["startDate"] as! NSDate).uppercaseString
        //time2.text = dateFormat.stringFromDate(SelectedEvent["endDate"] as! NSDate).uppercaseString

        // GET EVENT START AND END DATES & TIME
        //let startDateFormatter = NSDateFormatter()
        //startDateFormatter.dateFormat = "MMM d, h:mm a"
        //let startDateStr = startDateFormatter.stringFromDate(SelectedEvent["startDate"] as! NSDate).uppercaseString
//        let endDateFormatter = NSDateFormatter()
//        endDateFormatter.dateFormat = "MMM d, h:mm a"
//        let endDateStr = endDateFormatter.stringFromDate(SelectedEvent["endDate"] as! NSDate).uppercaseString
//        
//        time1.text = "\(startDateStr)"
//        if endDateStr != "" {  time2.text = " - \(endDateStr)"
//        } else { time2.text = ""  }
        
        let imageFile =  SelectedEvent["image"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image1.layer.cornerRadius = self.image1.frame.size.width / 2;
                    self.image1.image = UIImage(data:imageData)
                } } }
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        userQuery = PFQuery(className: "_User")
        //Add the goers to the images
        fetch_all_going_images()
        progBarUpdate()
        
        //Number of Other
        let n = SelectedEvent["going"] as! Array<String>
        if(n.count > 4){
            let x = n.count - 4
            otherGoing.setTitle("+\(x)", forState: UIControlState.Normal)
        }else{
            otherGoing.setTitle("", forState: UIControlState.Normal)
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
            eventStrings = eventStrings.filter{$0 != SelectedEvent.objectId!}
            
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
            eventStrings.append(SelectedEvent.objectId!)
        }
        SelectedEvent.saveInBackground()
        
        fetch_all_going_images()
        print(eventStrings)
        let n = SelectedEvent["going"] as! Array<String>
        if(n.count > 4){
            let x = n.count - 4
            otherGoing.setTitle("+\(x)", forState: UIControlState.Normal)
        }else{
            otherGoing.setTitle("", forState: UIControlState.Normal)
        }
        
    }
    
    
    @IBAction func otherGoing(sender: UIButton) {
        let listView = storyboard?.instantiateViewControllerWithIdentifier("GoersListView") as! GoingListView
        navigationController?.pushViewController(listView, animated: true)
    }
    
    
    @IBAction func nah(sender: UIButton) {
        let index = visitedEvents.indexOf(SelectedEvent.objectId!)

        
        if(litArray[index!]){
            SelectedEvent["Lit"] = rateLit - 1
            rateLit--
            SelectedEvent["Nah"] = rateNah + 1
            rateNah++
            litArray[index!] = false
            nahArray[index!] = true
        }else if(!nahArray[index!]){
            SelectedEvent["Nah"] = rateNah + 1
            rateNah++
            nahArray[index!] = true
        }
        sender.enabled = false
        progBarUpdate()
        SelectedEvent.saveInBackground()
    }
    
    @IBAction func lit(sender: UIButton) {
        let index = visitedEvents.indexOf(SelectedEvent.objectId!)

        
        if(nahArray[index!]){
            SelectedEvent["Lit"] = rateLit + 1
            rateLit++
            SelectedEvent["Nah"] = rateNah - 1
            rateNah--
            litArray[index!] = true
            nahArray[index!] = false
        }else if(!litArray[index!]){
            SelectedEvent["Lit"] = rateNah + 1
            rateNah++
            litArray[index!] = true
        }
        sender.enabled = false
        
        progBarUpdate()
        SelectedEvent.saveInBackground()
    }
    
    func fetch_going_images(userID: String, image: UIImageView){
        let userQuery2 = PFQuery(className: "_User")
        userQuery2.getObjectInBackgroundWithId(userID) {
            (user: PFObject?, error: NSError?) -> Void in
            if error == nil && user != nil {
                let image_file = user!["profile_picture"] as! PFFile
                image_file.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            print("Image" + userID)
                            image.layer.cornerRadius = image.frame.size.width / 2;
                            image.image = UIImage(data:imageData)
                            
                        }
                    }
                }
            }
        }
    }
    
    func fetch_all_going_images(){

        
        
        let arrayOfGoers = SelectedEvent["going"] as! Array<String>
        let n = arrayOfGoers.count
        if(n >= 1){
            fetch_going_images(arrayOfGoers[n - 1], image: self.going1)
        }else{
            self.going1.image = nil
        }
        if(n >= 2){
            fetch_going_images(arrayOfGoers[n - 2], image: self.going2)
        }else{
            self.going2.image = nil
        }
        if(n >= 3){
            fetch_going_images(arrayOfGoers[n - 3], image: self.going3)
        }else{
            self.going3.image = nil
        }
        if(n >= 4){
            fetch_going_images(arrayOfGoers[n - 4], image: self.going4)
        }else{
            self.going4.image = nil
        }
    }
    
}
