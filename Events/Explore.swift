//
//  Explore.swift
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

class Explore: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate {
    
    
    
    
    
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
    var users = [PFObject]()
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
        searchTxt.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
        
        // Call a Parse query
        //queryLatestEvents()
        
        //loadUsers()
    
        // Do any additional setup after loading the view.
    }
    
    func loadUsers(){
        
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey(USER_OBJECT_ID, notEqualTo: PFUser.currentUser()!.objectId!)
        userQuery.findObjectsInBackgroundWithBlock{(result:[PFObject]?, error:NSError?) -> Void in
            
            if let foundUsers = result as? [PFUser]{
                self.users = foundUsers
                self.eventsCollView.reloadData()
                
            }
        }
    }

    
    // MARK: -  COLLECTION VIEW DELEGATES
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //fix the actual number to what is needed
        return users.count
    }
    
    
    
    
    
    @IBAction func exploreSeeAllButton(sender: AnyObject) {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("ExploreVenue") as! ExploreVenue, animated: true)
        
    }
    
    @IBAction func exploreSeeAllButton2(sender: AnyObject) {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("ExplorePeople") as! ExplorePeople, animated: true)
        
    }
    
    
    
    
    
    //NOT NEEDED FOR NOW BUT IS USED FOR TOP PART OF VENUE AND PEOPLE SECTION
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ExploreHeader", forIndexPath: indexPath) as! ExploreHeader
        
        
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreCell", forIndexPath: indexPath) as! ExploreCell
        
        
        if indexPath.section == 0{
            if (indexPath.row == 1){
                print("First If")
                cell.separatorView.hidden = false
                
                let userObject = users[indexPath.row]
                
                let firstName = userObject.objectForKey("first_name") as? String

                let lastName = userObject.objectForKey("last_name") as? String
            
                cell.titleLbl.text = "\(firstName!)" + " \(lastName!)"
                
                
                let imageFile = userObject.objectForKey("profile_picture") as? PFFile
                imageFile?.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2
                            cell.eventImage.image = UIImage(data:imageData)
                        }
                    }
                }
            
                
                
                return cell
                
            } else {
                cell.separatorView.hidden = false
                
                print("Second If")
                let userObject = users[indexPath.row]
                
                let firstName = userObject.objectForKey("first_name") as? String
                
                let lastName = userObject.objectForKey("last_name") as? String
                
                cell.titleLbl.text = "\(firstName!)" + " \(lastName!)"

                
                let imageFile = userObject.objectForKey("profile_picture") as? PFFile
                imageFile?.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2
                            cell.eventImage.image = UIImage(data:imageData)
                        }
                    }
                }
                
                
                
                return cell
            }
            // NOT NEEDED FOR NOW
            
        } else {
            
            print("Third If")
            
            cell.separatorView.hidden = false
            
            let userObject = users[indexPath.row]
            
            let firstName = userObject.objectForKey("first_name") as? String
            
            let lastName = userObject.objectForKey("last_name") as? String
            
            cell.titleLbl.text = "\(firstName!)" + " \(lastName!)"
            
            let imageFile = userObject.objectForKey("profile_picture") as? PFFile
            imageFile?.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2
                        cell.eventImage.image = UIImage(data:imageData)
                    }
                }
            }
            
            
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
        
        if searchViewIsVisible {
            showSearchView()
            
        } else {
            hideSearchView()
        }
        
    }
    
    
    // MARK: - TEXTFIELD DELEGATE (tap Search on the keyboard to launch a search query) */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideSearchView()
        view.showHUD(view)
        self.users.removeAll()
        let firstNameQuey = PFQuery(className: "_User")
        firstNameQuey.whereKey("first_name", matchesRegex:"(?i)\(textField.text!)")
        let lastNameQuey = PFQuery(className: "_User")
        lastNameQuey.whereKey("last_name", matchesRegex:"(?i)\(textField.text!)")
        
        let query = PFQuery.orQueryWithSubqueries([firstNameQuey,lastNameQuey])
        // Query block
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error)-> Void in
            if error == nil {
                if let objects = results  {
                    for object in objects {
                        if(PFUser.currentUser()?.objectId != object.objectId){
                            self.users.append(object)
                        }
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.eventsCollView.reloadData()
                        self.hideSearchView()
                        self.view.hideHUD()
                    }
                }
                // error found
            } else {
                
                let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
                self.view.hideHUD()
            }
        
        }
        
        
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
        //loadUsers()
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
