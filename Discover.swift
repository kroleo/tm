//
//  Discover.swift
//  Events
//
//  Created by Harsha Cuttari on 1/17/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse
import GoogleMobileAds
import iAd
import AudioToolbox

class Discover: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate,
    GADBannerViewDelegate,
ADBannerViewDelegate {
    
    


    
    /* Views */
    @IBOutlet var eventsCollView: UICollectionView!
    
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTxt: UITextField!
    
    
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    
    
    /* Variables */
    var eventsArray = NSMutableArray()
    var cellSize = CGSize()
    var headerSize = CGSize()
    var searchViewIsVisible = false
    var users = [PFUser]()
    var venues = [PFUser]()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iPhone
        cellSize = CGSizeMake(view.frame.size.width, 85)
        headerSize = CGSizeMake(view.frame.size.width, 139)
        
        // Search View initial setup
        searchView.frame.origin.y = -searchView.frame.size.height
        searchView.layer.cornerRadius = 10
        searchViewIsVisible = false
        searchTxt.resignFirstResponder()
        
        // Set placeholder's color and text for Search text fields
        searchTxt.attributedPlaceholder = NSAttributedString(string: "Type a name", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
        
        // Call a Parse query
        //queryLatestEvents()
        
        loadUsers()
        loadVenues()
        
        
        
        // Do any additional setup after loading the view.
    }

    func loadUsers(){
        
        
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey(IS_VENUE, equalTo: false)
        userQuery.whereKey(USER_OBJECT_ID, notEqualTo: PFUser.currentUser()!.objectId!)
        userQuery.findObjectsInBackgroundWithBlock{(result:[PFObject]?, error:NSError?) -> Void in
            
            if let foundUsers = result as? [PFUser]{
                self.users = foundUsers
                self.eventsCollView.reloadData()
                
            }
        }
    }
    
    func loadVenues(){
        
        
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey(IS_VENUE, equalTo: true)
        userQuery.whereKey(USER_OBJECT_ID, notEqualTo: PFUser.currentUser()!.objectId!)
        userQuery.findObjectsInBackgroundWithBlock{(result:[PFObject]?, error:NSError?) -> Void in
            
            if let foundUsers = result as? [PFUser]{
                self.venues = foundUsers
                self.eventsCollView.reloadData()
                
            }
        }
    }
    

    
    
    
    
    
    
/*
    func queryLatestEvents() {
        view.showHUD(view)
        eventsArray.removeAllObjects()
        
        let query = PFQuery(className: EVENTS_CLASS_NAME)
        query.whereKey(EVENTS_IS_PENDING, equalTo: false)
        query.orderByDescending(EVENTS_START_DATE)
        query.limit = limitForRecentEventsQuery
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
        
    }*/
    
    // MARK: -  COLLECTION VIEW DELEGATES
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //fix the actual number to what is needed
        
        if section == 0{
            return venues.count
        } else {
        return users.count
        }
    }
    
    
    
    

    @IBAction func exploreSeeAllButton(sender: AnyObject) {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("ExploreVenue") as! ExploreVenue, animated: true)
        
    }
    
    @IBAction func exploreSeeAllButton2(sender: AnyObject) {
            navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("ExplorePeople") as! ExplorePeople, animated: true)
        
    }
    
    

    
  
    //NOT NEEDED FOR NOW BUT IS USED FOR TOP PART OF VENUE AND PEOPLE SECTION
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DiscoverHeader", forIndexPath: indexPath) as! DiscoverHeader
        

        if indexPath.section == 0 {

            headerView.exploreDivder.hidden = true
            headerView.exploreHeaderImage.hidden = false
            headerView.exploreHeaderImage.image = UIImage(named: "exploreHeaderImage")
            //headerView.exploreTypeLabel.text = "Venues"
           // headerView.exploreTypeLabel.text = "People"
            headerView.exploreSeeAllButton.hidden = true
            

            headerView.exploreSeeAllButton2.hidden = true


            return headerView
        } else {
// NOT NEEDED FOR NOW
            headerView.exploreHeaderImage.hidden = true
            headerView.exploreDivder.hidden = false
            headerView.exploreTypeLabel.text = "People"
            headerView.exploreSeeAllButton.hidden = true
            headerView.exploreSeeAllButton2.hidden = false
            
            
            
            return headerView
        }

    }
    
    

    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return headerSize
        } else {
            return CGSizeMake(view.frame.size.width, 29)
        }
        
    }
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiscoverCell", forIndexPath: indexPath) as! DiscoverCell
        
        
        if indexPath.section == 0{
            if (indexPath.row == 1){
 
                cell.separatorView.hidden = false
                
                let userObject: PFUser = venues[indexPath.row]
                
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
                
                
                // GET EVENT START AND END DATES & TIME
                let startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "MMM d, h:mm a"
                let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
                cell.timeLabel.text = startDateStr*/
                
                
                return cell
                // NOT NEEDED FOR NOW, to hide the last seprator
           
            } else {
                        cell.separatorView.hidden = false
                
                
                let userObject: PFUser = venues[indexPath.row]
                
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
        
        
        // GET EVENT START AND END DATES & TIME
        let startDateFormatter = NSDateFormatter()
        startDateFormatter.dateFormat = "MMM d, h:mm a"
        let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
        cell.timeLabel.text = startDateStr
        */
        
        
        return cell
            }
            // NOT NEEDED FOR NOW
            
        } else {
            
            cell.separatorView.hidden = false
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
            


            /*var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
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
            
            
            // GET EVENT START AND END DATES & TIME
            let startDateFormatter = NSDateFormatter()
            startDateFormatter.dateFormat = "MMM d, h:mm a"
            let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
            cell.timeLabel.text = startDateStr*/
            
            return cell
            
            
        }
    
}

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    
    
    
    
 /*
    
    // MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
        eventsClass = eventsArray[indexPath.row] as! PFObject
        hideSearchView()
        
        let edVC = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetails
        edVC.eventObj = eventsClass
        navigationController?.pushViewController(edVC, animated: true)
        

        
    }
    
    
    */
    
    
    
    
    // MARK: - SEARCH EVENTS BUTTON
    @IBAction func searchButt(sender: AnyObject) {
        searchViewIsVisible = !searchViewIsVisible
        
        if searchViewIsVisible { showSearchView()
        } else { hideSearchView()  }
        
    }
    
    
    // MARK: - TEXTFIELD DELEGATE (tap Search on the keyboard to launch a search query) */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideSearchView()
        view.showHUD(view)
        
        // Make a new Parse query

        eventsArray.removeAllObjects()
        let keywordsArray = searchTxt.text!.componentsSeparatedByString(" ") as [String]
        // print("\(keywordsArray)")
        
        /**********/
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*********/
        
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
                    self.title = "Will fix with next update"
                    self.view.hideHUD()
                    
                    // EVENT NOT FOUND
                } else {
                    let alert = UIAlertView(title: APP_NAME,
                        message: "Will fix with next update",
                        delegate: nil,
                        cancelButtonTitle: "OK")
                    alert.show()
                    self.view.hideHUD()
                    self.loadUsers()
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
    
    
    
    // MARK: -  REFRESH  BUTTON
    @IBAction func refreshButt(sender: AnyObject) {
        //queryLatestEvents()
        loadUsers()
        loadVenues()
        searchTxt.resignFirstResponder();
        hideSearchView()
        searchViewIsVisible = false
        
        self.title = "Explore"
    }
    
    
    
    
    
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
