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
        signUp()
    }
    
    override func viewDidLoad() {
        
    }
    
    func signUp (){
        
        
        var emailAddress = eduEmail.text
        
        emailAddress = emailAddress?.lowercaseString
        
        let user = PFUser.currentUser()!
        
        if (emailAddress != nil) {
            user.setObject(emailAddress!, forKey: "eduEmail")
        }
        
        //save in parse
        
        // BUT Have to send the confirmation
        user.saveInBackgroundWithBlock({(success:Bool, error:NSError?) -> Void in
            
            if (success){
                
                print("User details are now updated")
            }
        })
        
        
        
        
    }
    
    

}
