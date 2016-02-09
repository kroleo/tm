//
//  ExploreVenue.swift
//  Events
//
//  Created by Harsha Cuttari on 1/19/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//


import UIKit
import Parse
import GoogleMobileAds
import iAd
import AudioToolbox

class ExploreVenue: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate{
    
    /* Views */
    @IBOutlet var eventsCollView: UICollectionView!
    
    /* Variables */
    var eventsArray = NSMutableArray()
    var cellSize = CGSize()
    var users = [PFUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // iPhone
        cellSize = CGSizeMake(view.frame.size.width, 85)
        
        //queryLatestEvents()
        
        loadUsers()
        
        self.title = "People"
        
        
    }
    
    
    
    func loadUsers(){
        
        
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey(IS_VENUE, equalTo: true)
        userQuery.findObjectsInBackgroundWithBlock{(result:[PFObject]?, error:NSError?) -> Void in
            
            if let foundUsers = result as? [PFUser]{
                self.users = foundUsers
                self.eventsCollView.reloadData()
                
            }
        }
    }
    
    
    /*
    
    func queryLatestEvents() {
    view.showHUD(view)
    eventsArray.removeAllObjects()
    
    
    let query = PFQuery(className: "_User")
    //query.whereKey(EVENTS_IS_PENDING, equalTo: false)
    //query.orderByDescending(EVENTS_START_DATE)
    query.limit = limitForExplorePeopleQuery
    // Query bloxk
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
    if error == nil {
    if let objects = objects  {
    for object in objects {
    self.eventsArray.addObject(object)
    } }
    // Reload CollView
    self.eventsCollView.reloadData()
    self.view.hideHUD()
    
    } else {
    let alert = UIAlertView(title: APP_NAME,
    message: "\(error!.localizedDescription)",
    delegate: nil,
    cancelButtonTitle: "OK" )
    alert.show()
    self.view.hideHUD()
    } }
    
    }
    
    */
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //fix the actual number to what is needed
        
        return users.count
    }
    
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreCell", forIndexPath: indexPath) as! ExploreCell
        
        let userObject: PFUser = users[indexPath.row]
        
        cell.titleLbl.text = userObject.objectForKey("first_name") as? String
        
        let imageFile = userObject.objectForKey("profile_picture") as? PFFile
        imageFile?.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2
                    cell.eventImage.image = UIImage(data:imageData)
                }
            }
        }
        
        
        
        
        /*
        var eventsClass = PFObject(className: USER_CLASS_NAME)
        eventsClass = eventsArray[indexPath.row] as! PFObject
        
        
        // GET EVENT'S IMAGE
        
        let imageFile = eventsClass[PRO_PIC] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
        if let imageData = imageData {
        
        cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2;
        //cell.eventImage.clipsToBounds = YES;
        cell.eventImage.image = UIImage(data:imageData)
        } } }
        
        // GET EVENT'S TITLE
        cell.titleLbl.text = "\(eventsClass[FIRST_NAME]!)"
        
        
        // GET EVENT START AND END DATES & TIME
        //    let startDateFormatter = NSDateFormatter()
        //    startDateFormatter.dateFormat = "MMM d, h:mm a"
        //    let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
        //    cell.timeLabel.text = startDateStr
        
        */
        
        return cell
        
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    
    
    
    
    
    
    // MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
    //   func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    //       var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    //       eventsClass = eventsArray[indexPath.row] as! PFObject
    //hideSearchView()
    
    //     let edVC = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetails
    //     edVC.eventObj = eventsClass
    //     navigationController?.pushViewController(edVC, animated: true)
    //  }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}