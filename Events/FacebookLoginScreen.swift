//
//  FacebookLoginScreen.swift
//  Events
//
//  Created by Harsha Cuttari on 1/21/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class FacebookLoginScreen: UIViewController/*, FBSDKLoginButtonDelegate*/ {

    override func viewDidLoad() {
        super.viewDidLoad()
        /*let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.readPermissions = ["email"]
        self.view.addSubview(loginButton)
        loginButton.delegate = self*/

        // Do any additional setup after loading the view.
    }
    @available(iOS 8.0, *) /*might not need this, but for now I need to test alert */
    @IBAction func facebookSignInButton(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile"], block: {(user: PFUser?, error: NSError?) ->Void in
            
            if (error != nil){
                // display an alert message
                let myAlert = UIAlertController(title: "Alert:", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated:true, completion: nil)
                
                return
            }
            
            
            
            if (FBSDKAccessToken.currentAccessToken() != nil){
                
                //https://www.youtube.com/watch?v=SBvtDR31Z5Q
                let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,picture"])
                graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
                    if error != nil {
                        print(error)
                    }else {
                        if(user!.isNew){
                        let id = result["id"] as! String
                        user!["first_name"] = result["first_name"] as! String
                        user!["last_name"] = result["last_name"] as! String
                        user!["events"] = []
                        user!["email"] = user!.objectId! + "@foo.com"
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                            //Get Profile Picture
                            let userProfile = "https://graph.facebook.com/" + id + "/picture?type=normal"
                            let picUrl = NSURL(string: userProfile)
                            let data = NSData(contentsOfURL: picUrl!)
                            if(data != nil){
                                let pfobj = PFFile(data: data!)
                                print(pfobj)
                                user!["profile_picture"] = pfobj
                            }
                            
                            user!.saveInBackground()
                            
                        }
                        
                        
                        }
                    }
                }
                
                if(user!.isNew){
                    self.performSegueWithIdentifier("toConfirm", sender: self)
                }else{
                    let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("ProtectedPage") as! ProtectedPage
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = protectedPage
                }
                
               
            }
            
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
/*    override func viewWillAppear(animated: Bool) {
        self.logUserData()
    }
    
    
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("logged in")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    func logUserData() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                print(error)
            }else {
                print(result.grantedPermissions)
            
            }
        }
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

}
