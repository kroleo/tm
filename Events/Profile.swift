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

class Profile: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate,
    GADBannerViewDelegate,
ADBannerViewDelegate {
    
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
   

    
    
    @IBAction func currentPastToggle(sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex){
        case 0:

            whichColToUse = 0
            queryLatestEvents()
            
        case 1:

            whichColToUse = 1
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

        
        // iPhone
        cellSize = CGSizeMake(view.frame.size.width, 120)
        
   /*     // Search View initial setup
        searchView.frame.origin.y = -searchView.frame.size.height
        searchView.layer.cornerRadius = 10
        searchViewIsVisible = false
        searchTxt.resignFirstResponder()
        
        // Set placeholder's color and text for Search text fields
        searchTxt.attributedPlaceholder = NSAttributedString(string: "Type an event name", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
    */
        // Call a Parse query
        queryLatestEvents()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func queryLatestEvents() {
        view.showHUD(view)
        eventsArray.removeAllObjects()
        
        let query1 = PFQuery(className: "_User")
        query1.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (user : PFObject?, error: NSError?) -> Void in
            if error == nil {
               let eventsIDS = user!["events"] as! Array<String>
                let query = PFQuery(className: EVENTS_CLASS_NAME)
                query.orderByDescending(EVENTS_START_DATE)
                query.limit = limitForRecentEventsQuery
                for event in eventsIDS{
                    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
                        if error == nil {
                            if let objects = objects  {
                                for object in objects {
                                    if(object.objectId == event){
                                        self.eventsArray.addObject(object)
                                    }
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
            }
        }

    
        
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
        
        //headerView.profileImage.image = UIImage(named: "favHeaderImage")
        headerView.profileImage.layer.cornerRadius = headerView.profileImage.frame.size.width / 2;
        headerView.profileImage.image = UIImage(data: CURRENT_PRO_PIC)
        headerView.profileName.text = "\(CURRENT_FIRST_NAME)"
        
        return headerView
    }
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (whichColToUse == 0){
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        
        var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
        eventsClass = eventsArray[indexPath.row] as! PFObject
        
        
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
        
        
        // GET EVENT'S COST
        cell.costLabel.text = "\(eventsClass[EVENTS_COST]!)".uppercaseString
        
        
        return cell
            
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell1", forIndexPath: indexPath) as! EventCell
            
            var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
            eventsClass = eventsArray[indexPath.row] as! PFObject
            
            
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
            
            // GET EVENT'S LOCATION
            //cell.locationLabel.text = "\(eventsClass[EVENTS_LOCATION]!)".uppercaseString
       /*
            // GET EVENT START AND END DATES & TIME
            let startDateFormatter = NSDateFormatter()
            startDateFormatter.dateFormat = "MMM d, h:mm a"
            let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
            cell.timeLabel.text = startDateStr
            
            
            // GET EVENT'S COST
            cell.costLabel.text = "\(eventsClass[EVENTS_COST]!)".uppercaseString
   */
            
            return cell
            
            
            
            
            
            
        }
        
            
            
            
            
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
        
    }
    
    
    
    
    
    
    
    // MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
        eventsClass = eventsArray[indexPath.row] as! PFObject
 //       hideSearchView()
        
        let edVC = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetails
        edVC.eventObj = eventsClass
        navigationController?.pushViewController(edVC, animated: true)
    }
    
    
    
    
  /*
    
    
    // MARK: - SEARCH EVENTS BUTTON
    @IBAction func searchButt(sender: AnyObject) {
        searchViewIsVisible = !searchViewIsVisible
        
        if searchViewIsVisible { showSearchView()
        } else { hideSearchView()  }
        
    }
  */
    
    // MARK: - TEXTFIELD DELEGATE (tap Search on the keyboard to launch a search query) */
 /*   func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideSearchView()
        view.showHUD(view)
        
        // Make a new Parse query
        eventsArray.removeAllObjects()
        let keywordsArray = searchTxt.text!.componentsSeparatedByString(" ") as [String]
        // print("\(keywordsArray)")
        
        let query = PFQuery(className: EVENTS_CLASS_NAME)
        if searchTxt.text != ""   { query.whereKey(EVENTS_KEYWORDS, containsString: "\(keywordsArray[0])".lowercaseString) }
        //    if searchCityTxt.text != "" { query.whereKey(EVENTS_KEYWORDS, containsString: searchCityTxt.text!.lowercaseString) }
        query.whereKey(EVENTS_IS_PENDING, equalTo: false)
        
        
        // Query block
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects  {
                    for object in objects {
                        self.eventsArray.addObject(object)
                    } }
                
                // EVENT FOUND
                if self.eventsArray.count > 0 {
                    self.eventsCollView.reloadData()
                    self.title = "Events Found"
                    self.view.hideHUD()
                    
                    // EVENT NOT FOUND
                } else {
                    let alert = UIAlertView(title: APP_NAME,
                        message: "No results. Please try a different search",
                        delegate: nil,
                        cancelButtonTitle: "OK")
                    alert.show()
                    self.view.hideHUD()
                    self.queryLatestEvents()
                }
                
                // error found
            } else { let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
                self.view.hideHUD()
            } }
        
        
        return true
    }
    
    // MARK: - SHOW/HIDE SEARCH VIEW
    func showSearchView() {
        searchTxt.becomeFirstResponder()
        searchTxt.text = "";
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.searchView.frame.origin.y = 32
            }, completion: { (finished: Bool) in })
    }
    func hideSearchView() {
        searchTxt.resignFirstResponder();
        searchViewIsVisible = false
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.searchView.frame.origin.y = -self.searchView.frame.size.height
            }, completion: { (finished: Bool) in })
    }
    */
    
    
    // MARK: -  REFRESH  BUTTON
/*    @IBAction func refreshButt(sender: AnyObject) {
        queryLatestEvents()
        searchTxt.resignFirstResponder();
        hideSearchView()
        searchViewIsVisible = false
        
        self.title = "Following"
    }
    
   */
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
