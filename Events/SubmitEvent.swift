/* ----------------------

- Events -

created by FV iMAGINATION ©2015
for CodeCanyon.net

---------------------------*/

import UIKit
import Parse
import MessageUI
import SwiftRequest
import EPContactsPicker

class SubmitEvent: UIViewController,
UITextFieldDelegate,
UITextViewDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate, EPPickerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
     
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var descriptionTxt: UITextView!
    @IBOutlet var locationTxt: UITextField!
    @IBOutlet var costTxt: UITextField!
    @IBOutlet var websiteTxt: UITextField!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var yourNameTxt: UITextField!
    @IBOutlet var yourEmailTxt: UITextField!
    
    @IBOutlet var startDateOutlet: UIButton!
    @IBOutlet var endDateOutlet: UIButton!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var submitEventOutlet: UIButton!

    
    
    /* Variables */
    var startDateSelected = false
    var startDate = NSDate()
    var endDate = NSDate()
    var selectedContactsArray = [String]()
    var startDateTrigger = false
    var endDateTrigger = false
    
    
    @IBOutlet var addPhoto: UIButton!
    
    
    
// MARK: - VIEW DID LOAD
override func viewDidLoad() {
        super.viewDidLoad()

    //color for placeholder text
    self.nameTxt.attributedPlaceholder = NSAttributedString(string:self.nameTxt.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
    self.locationTxt.attributedPlaceholder = NSAttributedString(string:self.locationTxt.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])

    
    
    // Setup container ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, submitEventOutlet.frame.origin.y + 250)
    
    // Setup datePicker
    datePicker.frame.origin.y = view.frame.size.height
    datePicker.addTarget(self, action: "dateChanged:", forControlEvents: UIControlEvents.ValueChanged)
    datePicker.backgroundColor = UIColor.whiteColor()
    startDateSelected = false
    
    
    
    // Round views corners
    submitEventOutlet.layer.cornerRadius = 5
}
    

// MARK: - CLEAR ALL TEXTS AND IMAGE (In order for you to insert a new Event)
func clearFields(sender:UIButton) {
    nameTxt.text = ""
    descriptionTxt.text = ""
    locationTxt.text = ""
    startDateOutlet.setTitle("Tap to choose", forState: UIControlState.Normal)
    startDateTrigger = false
    endDateOutlet.setTitle("Tap to choose", forState: UIControlState.Normal)
    endDateTrigger = false
    costTxt.text = ""
    websiteTxt.text = ""
    yourNameTxt.text = ""
    yourEmailTxt.text = ""
    eventImage.image = nil
    
    dismissKeyboard()
}

    
    
    
// MARK: - START DATE PICKER CHANGED VALUE
func dateChanged(datePicker: UIDatePicker) {
    // Get current date
    let currentDate = NSDate()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMM dd yyyy @hh:mm a"
    let dateStr = dateFormatter.stringFromDate(datePicker.date)
    
    // SET START DATE
        if startDateSelected {
            if datePicker.date.isLessThanDate(currentDate) {
                let alert = UIAlertView(title: APP_NAME,
                    message: "Start date cannot be less than today",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            } else {
                startDateOutlet.setTitle(dateStr, forState: UIControlState.Normal)
                startDate = datePicker.date
                startDateTrigger = true
            }
            
            
        // SET END DATE
        } else {
            if datePicker.date.isSameAsDate(startDate)   ||
               datePicker.date.isLessThanDate(startDate) {
                let alert = UIAlertView(title: APP_NAME,
                    message: "End date cannot be less than Start Date",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            } else {
                endDateOutlet.setTitle(dateStr, forState: UIControlState.Normal)
                endDate = datePicker.date
                endDateTrigger = true
            }
        }
        
}
    
    
    
// MARK: - SHOW/HIDE DATE PICKERS
func showDatePicker() {
    dismissKeyboard()
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.datePicker.frame.origin.y = self.view.frame.size.height - self.datePicker.frame.size.height - 44
    }, completion: { (finished: Bool) in  })
}
func hideDatePicker() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.datePicker.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  })
}
    

    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func TapToDismissKeyboard(sender: UITapGestureRecognizer) {
        dismissKeyboard()
        hideDatePicker()
}
    
// DISMISS KEYBOARD
func dismissKeyboard() {
    nameTxt.resignFirstResponder()
    descriptionTxt.resignFirstResponder()
    locationTxt.resignFirstResponder()
    costTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
    yourNameTxt.resignFirstResponder()
    yourEmailTxt.resignFirstResponder()
}

    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTxt { descriptionTxt.becomeFirstResponder()  }
    if textField == locationTxt { locationTxt.resignFirstResponder()  }
    if textField == costTxt { websiteTxt.becomeFirstResponder()  }
    if textField == websiteTxt { websiteTxt.resignFirstResponder()  }
    if textField == yourNameTxt { yourEmailTxt.becomeFirstResponder()  }
    if textField == yourEmailTxt { yourEmailTxt.resignFirstResponder()  }
    
return true
}
    
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == nameTxt { hideDatePicker() }
    if textField == locationTxt { hideDatePicker() }
    if textField == descriptionTxt { hideDatePicker() }
    if textField == costTxt { hideDatePicker() }
    if textField == yourNameTxt { hideDatePicker() }
    if textField == yourEmailTxt { hideDatePicker() }
    
return true
}
    
    
// MARK: - CHOOSE IMAGE BUTTON
@IBAction func chooseImageButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Select Source",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles: "Photo Library", "Camera")
    addPhoto.setTitle("", forState: .Normal)
    alert.show()
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Photo Library" {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = false
                dismissKeyboard()
                presentViewController(imagePicker, animated: true, completion: nil)
        }
            
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Camera" {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                dismissKeyboard()
                presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
        
}
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        eventImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
}

    
    
// MARK: - SET START DATE BUTTON
@IBAction func startDateButt(sender: AnyObject) {
    startDateSelected = true
    showDatePicker()
    layoutButtons()
}

    
// MARK: - SET END DATE BUTTON
@IBAction func endDateButt(sender: AnyObject) {
    startDateSelected = false
    showDatePicker()
    layoutButtons()
}

// MARK: - CHANGE BUTTONS BORDER
func layoutButtons() {
    if startDateSelected {
        startDateOutlet.layer.borderColor = mainColor.CGColor
        startDateOutlet.layer.borderWidth = 2
        endDateOutlet.layer.borderWidth = 0
    } else {
        endDateOutlet.layer.borderColor = mainColor.CGColor
        endDateOutlet.layer.borderWidth = 2
        startDateOutlet.layer.borderWidth = 0
    }
}
    
    
    
    
// MARK: - SUBMIT EVENT BUTTON
@IBAction func submitEventButt(sender: AnyObject) {
    view.showHUD(view)
    dismissKeyboard()
    var errors = ""
    // Save event on Parse
    let eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    
    // AN EVENT NEEDS A TITLE!
    if nameTxt.text != "" {
    eventsClass[EVENTS_TITLE] = nameTxt.text
    } else {
        errors += "-You forgot to add the event title"
    }
    

    
    //AN EVENT NEEDS A START DATE
    if startDateTrigger == true  {
        eventsClass[EVENTS_START_DATE] = startDate
    } else {
        if(!errors.isEmpty){
            errors += "\r\n"
        }
        errors += "-You need a start date"
        
    }
    
    //AN EVENT NEEDS AN END DATE
    if endDateTrigger == true {
        eventsClass[EVENTS_END_DATE] = endDate
    } else {
        if(!errors.isEmpty){
            errors += "\r\n"
        }
        errors += "-You need an end date"
    }
    //AN EVENT NEEDS AN IMAGE
    if eventImage.image != nil {
        let imageData = UIImageJPEGRepresentation(eventImage.image!, 0.5)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        eventsClass[EVENTS_IMAGE] = imageFile
    }else{
        if(!errors.isEmpty){
            errors += "\r\n"
        }
        errors += "-You need a photo for your event"
    }
    
    // AN EVENT NEEDS LOCATION
    if locationTxt.text != "" {
            eventsClass[EVENTS_LOCATION] = self.locationTxt.text
        
    } else {
        if(!errors.isEmpty){
            errors += "\r\n"
        }
        errors += "-You forgot to add a location."
 
    }
    
    // Set Event Pending to False
    eventsClass[EVENTS_IS_PENDING] = false
    
    
    // Set Uploading User
    eventsClass["uploadingUser"] = PFUser.currentUser()?.objectId
    eventsClass["Lit"] = 0
    eventsClass["Nah"] = 0
    eventsClass["going"] = []
    
    
    
    if(errors.isEmpty){
        eventsClass.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.view.hideHUD()
                
            } else {
                let alert = UIAlertView(title: APP_NAME,
                    message: "\(error!.localizedDescription)",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
                self.view.hideHUD()
            }
        }
        if(!selectedContactsArray.isEmpty){
            for contact in selectedContactsArray{
                sendSMS(contact)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }else{
        print(errors)
        let alert = UIAlertView(title: APP_NAME,
            message: errors,
            delegate: nil,
            cancelButtonTitle: "OK" )
        alert.show()
        self.view.hideHUD()
    }

    

}

    
    func sendSMS(number: String){
        let code = "\(first_name) \(last_name) is inviting you for their event: \(nameTxt.text!).\nGet The Move for details and other cool events around you.\ngetthemove.com"
        
        let data = [
            "To" : number,
            "From" : "+15713273248",
            "Body" : code
        ]
        
        let swiftRequest = SwiftRequest()
        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts/AC4c5c35fc2cdfff1d9b19aad685528f5d/Messages",
            auth: ["username" : "AC4c5c35fc2cdfff1d9b19aad685528f5d", "password" : "ec4cb4554c0c09467c6bab9043a7c03c"],
            data: data,
            callback: {err, response, body in
                if err == nil {
                    print("Success: \(response)")
                } else {
                    print("Error: (err)")
                }
        })
        
    }
    
    
    
    @IBAction func select_contacts(sender: AnyObject) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.PhoneNumer)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
    {
        print("Failed with error \(error.description)")
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
    {
        print("Contact \(contact.displayName()) has been selected")
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
    {
        print("User canceled the selection");
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        print("The following contacts are selected")
        for contact in contacts {
            let stringArray = contact.phoneNumbers[0].phoneNumber.componentsSeparatedByCharactersInSet(
                NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            var newString = stringArray.joinWithSeparator("")
            newString = "+1" + "\(newString)"
            selectedContactsArray.append(newString)
            
        }
    }
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
