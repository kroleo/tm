//
//  Profile.swift
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

class OtherProfile: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
UITextFieldDelegate{
    
    /* Views */
    @IBOutlet var eventsCollView: UICollectionView!
    
    /*  @IBOutlet var searchView: UIView!
    @IBOutlet var searchTxt: UITextField!
    
    
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    */
    
    /* Variables */
    var eventsArray = NSMutableArray()
    var cellSize = CGSize()
    var whichColToUse = 0
    // var searchViewIsVisible = false
    var user = PFUser.currentUser()
    var selectedUser:PFUser?
    
    
    
    @IBAction func currentPastToggle(sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex){
        case 0:
            
            whichColToUse = 0
            queryLatestEvents()
            
        case 1:
            //whichColToUse = 1
            whichColToUse = 0
            queryLatestEvents()
            
            
            
        default:
            break;
        }
        
    }
    
    /* following and followers button and setting button functions */
    
    
    @IBAction func openFollowing(sender: AnyObject) {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("ProfileFollowing") as! ProfileFollowing, animated: true)
        
    }
    
    
    @IBAction func openFollowers(sender: AnyObject) {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("ProfileFollowers") as! ProfileFollowers, animated: true)
        
    }
    
    @IBAction func settingsButton(sender: AnyObject) {
        
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("Settings") as! Settings, animated: true)
        
    }
    
    
    @IBAction func hostButton(sender: AnyObject) {
        
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("SubmitEvent") as! SubmitEvent, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        
        cellSize = CGSizeMake(view.frame.size.width, 120)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        queryLatestEvents()
    }
    
    
    
    
    
    func queryLatestEvents() {
        //
        view.showHUD(view)
        eventsArray.removeAllObjects()
        
        
        let query = PFQuery(className: EVENTS_CLASS_NAME)
        query.orderByDescending(EVENTS_START_DATE)
        query.limit = limitForRecentEventsQuery
        query.whereKey("objectId", containedIn: eventStrings)
        // Query bloxk
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                print(objects)
                if let objects = objects  {
                    for object in objects {
                        print(object)
                        self.eventsArray.addObject(object)
                    }
                }
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
    
    // MARK: -  COLLECTION VIEW DELEGATES
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileHeader", forIndexPath: indexPath) as! ProfileHeader
        
        
        
        
        //let userObject: PFUser = PFUser.currentUser()!
        
        
        let firstName = selectedUser!.objectForKey("first_name")
        print(selectedUser)
        print(firstName)
        //let lastName = userObj["last_name"]
        //print(lastName)
        
        
        let imageFile = selectedUser!.objectForKey("profile_picture") as? PFFile
        imageFile?.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    headerView.profileImage.layer.cornerRadius = headerView.profileImage.frame.size.width / 2
                    headerView.profileImage.image = UIImage(data:imageData)
                }
            }
        }
        
        
        return headerView
    }
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (whichColToUse == 0){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
            
            var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
            eventsClass = eventsArray[indexPath.row] as! PFObject
            
            
            //Make event image
            
            cell.eventProfileImageBackground.layer.cornerRadius = cell.eventProfileImageBackground.frame.size.width / 2;
            
            let fullTitle = "\(eventsClass[EVENTS_TITLE]!)"
            let firstLetter = fullTitle[fullTitle.startIndex]
            
            cell.eventProfileImageIcon.text = "\(firstLetter)".uppercaseString
            
            
            
            // GET EVENT'S IMAGE
            
            let imageFile = eventsClass[EVENTS_IMAGE] as? PFFile
            imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        
                        cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2;
                        //cell.eventImage.clipsToBounds = YES;
                        cell.eventImage.image = UIImage(data:imageData)
                    } } }
            
            // GET EVENT'S TITLE
            cell.titleLbl.text = "\(eventsClass[EVENTS_TITLE]!)"
            
            // GET EVENT'S LOCATION
            cell.locationLabel.text = "\(eventsClass[EVENTS_LOCATION]!)".uppercaseString
            
            // GET EVENT START AND END DATES & TIME
            let startDateFormatter = NSDateFormatter()
            startDateFormatter.dateFormat = "MMM d, h:mm a"
            let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
            cell.timeLabel.text = startDateStr
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell1", forIndexPath: indexPath) as! EventCell
            
            var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
            eventsClass = eventsArray[indexPath.row] as! PFObject
            
            
            
            
            //Make event image
            
            cell.eventProfileImageBackground.layer.cornerRadius = cell.eventProfileImageBackground.frame.size.width / 2;
            
            let fullTitle = "\(eventsClass[EVENTS_TITLE]!)"
            let firstLetter = fullTitle[fullTitle.startIndex]
            
            cell.eventProfileImageIcon.text = "\(firstLetter)".uppercaseString
            
         // GET EVENT'S IMAGE
            
            let imageFile = eventsClass[EVENTS_IMAGE] as? PFFile
            imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        
                        //cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2;
                        //cell.eventImage.clipsToBounds = YES;
                        cell.eventImage.image = UIImage(data:imageData)
                    } } }
            
            // GET EVENT'S TITLE
            cell.titleLbl.text = "\(eventsClass[EVENTS_TITLE]!)"

            return cell

        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    
    
    // MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        SelectedEvent = eventsArray[indexPath.row] as! PFObject
        let edVC = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDeats
        navigationController?.pushViewController(edVC, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
