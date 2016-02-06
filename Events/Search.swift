



import UIKit
import Parse

class Search: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate{
    
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var searchButton: UIBarButtonItem!
    
    @IBOutlet var searchView: UIView!
    
    @IBOutlet var searchTxt: UITextField!
    
    var results = [String]()
    var searchVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.frame.origin.y = -searchView.frame.size.height
        searchView.layer.cornerRadius = 10
        searchTxt.resignFirstResponder()
        searchTxt.attributedPlaceholder = NSAttributedString(string: "Type a name", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("usercell", forIndexPath: indexPath) as! UserCell
        cell.username.text = results[indexPath.row]
    
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideSearchView()
        let firstNameQuey = PFQuery(className: "_User")
        firstNameQuey.whereKey("first_name", matchesRegex: "(?i)\(textField.text)")
        let lastNameQuey = PFQuery(className: "_User")
        lastNameQuey.whereKey("last_name", matchesRegex: "(?i)\(textField.text)")
        
        let query = PFQuery.orQueryWithSubqueries([firstNameQuey,lastNameQuey])
        query.findObjectsInBackgroundWithBlock {
            (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = results{
                    self.results.removeAll()
                    for object in objects{
                        let first = object["first_name"] as! String
                        let last = object["last_name"] as! String
                        let full = first + " " + last
                        //later might add images
                        self.results.append(full)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                        self.hideSearchView()
                    }
                }
            }
        }
    
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        hideSearchView()
        let firstNameQuey = PFQuery(className: "_User")
        firstNameQuey.whereKey("first_name", containsString: textField.text!)
        let lastNameQuey = PFQuery(className: "_User")
        lastNameQuey.whereKey("last_name", containsString: textField.text!)
        
        let query = PFQuery.orQueryWithSubqueries([firstNameQuey,lastNameQuey])
        query.findObjectsInBackgroundWithBlock {
            (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = results{
                    self.results.removeAll()
                    for object in objects{
                        let first = object["first_name"] as! String
                        let last = object["last_name"] as! String
                        let full = first + " " + last
                        //later might add images
                        self.results.append(full)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                        self.hideSearchView()
                    }
                }
            }
        }
    }
    
    func showSearchView() {
        searchTxt.becomeFirstResponder()
        searchTxt.text = "";
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.searchView.frame.origin.y = 32
            }, completion: { (finished: Bool) in })
    }
    func hideSearchView() {
        searchTxt.resignFirstResponder();
        searchVisible = false
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.searchView.frame.origin.y = -self.searchView.frame.size.height
            }, completion: { (finished: Bool) in })
    }
    
    @IBAction func search(sender: AnyObject) {
        if !searchVisible {
            showSearchView()
            searchVisible = true
        }else{
            hideSearchView()
            searchVisible = false
        }
    }
}