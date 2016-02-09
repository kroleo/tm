/* ----------------------
Added GitHub repository
- Events -

created by FV iMAGINATION ©2015
for CodeCanyon.net

---------------------------*/


import UIKit
import Parse
import GoogleMobileAds
import iAd
import AudioToolbox
import ParseFacebookUtilsV4

//Discover Page Class

class Home: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITextFieldDelegate,
GADBannerViewDelegate,
ADBannerViewDelegate
{

    /* Views */
    @IBOutlet var eventsCollView: UICollectionView!
    
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTxt: UITextField!
    //@IBOutlet var searchCityTxt: UITextField!
    
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    
    //Ad banners properties
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    
    /* Variables */
    var eventsArray = NSMutableArray()
    var cellSize = CGSize()
    var searchViewIsVisible = false
    

    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // PREDEFINED SIZE OF THE EVENT CELLS
  //  if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
        // iPhone
        cellSize = CGSizeMake(view.frame.size.width, 120)
  //  } else  {
        // iPad
   //     cellSize = CGSizeMake(350, 270)
  //  }
    
    // Init ad banners
 //   initiAdBanner()
 //   initAdMobBanner()
    
    
    // Search View initial setup
    searchView.frame.origin.y = -searchView.frame.size.height
    searchView.layer.cornerRadius = 10
    searchViewIsVisible = false
    searchTxt.resignFirstResponder()
//    searchCityTxt.resignFirstResponder()
    
    // Set placeholder's color and text for Search text fields
    searchTxt.attributedPlaceholder = NSAttributedString(string: "Type an event name", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
//    searchCityTxt.attributedPlaceholder = NSAttributedString(string: "Type a city/town name (or leave it blank)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
    
    
    // Call a Parse query
    queryLatestEvents()
    
    
    //Get facebook information and upload to parse
    let requestParameters = ["fields": "id, email, first_name, last_name"]
    
    let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
    
    userDetails.startWithCompletionHandler{(connection, result, error:NSError!) -> Void in
        
        if (error != nil) {
            print("\(error.localizedDescription)")
            return
        }
        if (result != nil){
            
            let userId:String = result["id"] as! String
            let userFirstName:String? = result["first_name"] as? String
            let userLastName:String? = result["last_name"] as? String
            let userEmail:String? = result["email"] as? String
            
            print("\(userEmail)")
            
            let myUser:PFUser = PFUser.currentUser()!
            
            //Save first name
            if (userFirstName != nil) {
                
                myUser.setObject(userFirstName!, forKey: "first_name")
                
                //sets following
                myUser.setObject("[]", forKey: "following")
                
                //sets favorited events
                myUser.setObject("[]", forKey: "events")
                
                //sets profile
                CURRENT_FIRST_NAME = userFirstName!
            }
            //Save last name
            if (userLastName != nil) {
                
                myUser.setObject(userLastName!, forKey: "last_name")
                CURRENT_LAST_NAME = userLastName!
            }
            //Save email
            if (userEmail != nil) {
                
                myUser.setObject(userEmail!, forKey: "email")
            }
            
            
            //Dispatch asyncronous task for speedy UI and background download of proPic
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                
            //Save profile picture
            
            let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
            
            let profilePictureUrl = NSURL(string: userProfile)
            let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
             //current user pic
                CURRENT_PRO_PIC = NSData(contentsOfURL: profilePictureUrl!)!
           
            if (profilePictureData != nil) {
                
                let profileFileObject = PFFile(data:profilePictureData!)
                myUser.setObject(profileFileObject, forKey: "profile_picture")
                }

            
            //Save in parse cloud
            myUser.saveInBackgroundWithBlock({(success:Bool, error:NSError?) -> Void in
                
                if (success){
                    
                    print("User details are now updated")
                }
            })
            }
        }
    
    }
    
}

    
    
// MARK: - QUERY LATEST EVENTS
func queryLatestEvents() {
    view.showHUD(view)
    eventsArray.removeAllObjects()
    
    let query = PFQuery(className: EVENTS_CLASS_NAME)
    query.whereKey(EVENTS_IS_PENDING, equalTo: false)
    query.orderByDescending("Lit")
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
    
}
    
    
    
    

// MARK: -  COLLECTION VIEW DELEGATES
func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
}

func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return eventsArray.count
}

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerCollectionReusableView", forIndexPath: indexPath) as! headerCollectionReusableView
        
        headerView.discHeaderImage.image = UIImage(named: "topHeaderImage")
        
        return headerView
    }
    
    
    
    
    
    
func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
    
    var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    eventsClass = eventsArray[indexPath.row] as! PFObject
    
    
    //Make event image
    
    cell.eventImageBackground.layer.cornerRadius = cell.eventImageBackground.frame.size.width / 2;
    
    let fullTitle = "\(eventsClass[EVENTS_TITLE]!)"
    let firstLetter = fullTitle[fullTitle.startIndex]
    
    cell.eventImageIcon.text = "\(firstLetter)".uppercaseString
    
    
    
    
    
    // GET EVENT'S IMAGE from Parse
    
    let imageFile = eventsClass[EVENTS_IMAGE] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                
                cell.eventImage.layer.cornerRadius = cell.eventImage.frame.size.width / 2;
                //cell.eventImage.clipsToBounds = YES;
                cell.eventImage.image = UIImage(data:imageData)
    } } }
    
    
    // GET EVENT'S START DATE (for the labels on the left side of the event's image)
   // let dayFormatter = NSDateFormatter()
  //  dayFormatter.dateFormat = "dd"
  //  let dayStr = dayFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate)
  //  cell.dayNrLabel.text = dayStr
    
  //  let monthFormatter = NSDateFormatter()
   // monthFormatter.dateFormat = "MMM"
   // let monthStr = monthFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate)
   // cell.monthLabel.text = monthStr
    
  //  let yearFormatter = NSDateFormatter()
  //  yearFormatter.dateFormat = "yyyy"
  //  let yearStr = yearFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate)
  //  cell.yearLabel.text = yearStr
    
    
    // GET EVENT'S TITLE
    cell.titleLbl.text = "\(eventsClass[EVENTS_TITLE]!)"
    //cell.titleLbl.text = "\(eventsClass[EVENTS_TITLE]!)".uppercaseString
    
    // GET EVENT'S LOCATION
    cell.locationLabel.text = "\(eventsClass[EVENTS_LOCATION]!)".uppercaseString
    
    
    // GET EVENT START AND END DATES & TIME
    let startDateFormatter = NSDateFormatter()
    startDateFormatter.dateFormat = "MMM d, h:mm a"
    let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
    cell.timeLabel.text = startDateStr
    
    /*let startDateFormatter = NSDateFormatter()
    startDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
    
    let endDateFormatter = NSDateFormatter()
    endDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let endDateStr = endDateFormatter.stringFromDate(eventsClass[EVENTS_END_DATE] as! NSDate).uppercaseString
    
    if startDateStr == endDateStr {  cell.timeLabel.text = startDateStr
    } else {  cell.timeLabel.text = "\(startDateStr) - \(endDateStr)"
    }
    */
    // GET EVENT'S COST
    cell.costLabel.text = "\(eventsClass[EVENTS_COST]!)".uppercaseString

    
return cell
}

    
func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellSize
}

    
// MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    SelectedEvent = eventsArray[indexPath.row] as! PFObject
    //self.performSegueWithIdentifier("toEventDetails1", sender: self)
    let eventDetailsPage = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDeats
    navigationController?.pushViewController(eventDetailsPage, animated: true)
}
   


    
    
    

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
    searchTxt.text = "";  //searchCityTxt.text = ""
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.searchView.frame.origin.y = 32
    }, completion: { (finished: Bool) in })
}
func hideSearchView() {
    searchTxt.resignFirstResponder(); //searchCityTxt.resignFirstResponder()
    searchViewIsVisible = false
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.searchView.frame.origin.y = -self.searchView.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
    
    
// MARK: -  REFRESH  BUTTON
@IBAction func refreshButt(sender: AnyObject) {
    queryLatestEvents()
    searchTxt.resignFirstResponder();  //searchCityTxt.becomeFirstResponder()
    hideSearchView()
    searchViewIsVisible = false
    
    self.title = "Recent Events"
}
    
    

    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
