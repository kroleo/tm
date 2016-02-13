//
//  ConfirmEmail.swift
//  Events
//
//  Created by Harsha Cuttari on 2/9/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse

class ConfirmEmail: UIViewController {
    @IBOutlet var eduEmail: UITextField!
    @IBAction func verify(sender: UIButton) {
        checks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checks(){
        let user = PFUser.currentUser()!
        
        let emailAddress = (eduEmail.text! as String).lowercaseString
        
        var emailExtension = emailAddress
        
        var correct = false
        
        if(validate(emailAddress) && emailAddress.characters.count >= 7){
            let range = emailAddress.startIndex..<emailAddress.endIndex.advancedBy(-7)
            emailExtension.removeRange(range)
            if(emailExtension == "umd.edu"){
                correct = true
            }
        }
        
        if(!correct){
            let alert = UIAlertView()
            alert.title = "Please enter a valid umd.edu email"
            alert.addButtonWithTitle("Okay")
            alert.show()
        }else{
            user["email"] = emailAddress
            user.saveInBackground()
            

        }
        
        user.fetchInBackgroundWithBlock {
            (user: PFObject?, error: NSError?) -> Void in
            print(user!["emailVerified"] as! Bool)
            
            if(user!["emailVerified"] as! Bool == true){
                //Perform Segue
                let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("ProtectedPage") as! ProtectedPage
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = protectedPage
            }else if(correct){
                let alert = UIAlertView()
                alert.title = "An email has been sent please verify!"
                alert.addButtonWithTitle("Okay")
                alert.show()
            }

        }
        
    }
    
    func validate(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    

}
