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
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile","email"], block: {(user: PFUser?, error: NSError?) ->Void in
            
            if (error != nil){
                // display an alert message
                let myAlert = UIAlertController(title: "Alert:", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated:true, completion: nil)
                
                return
            }
            
            print(user)
            print("Current User Token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
            
            print("Current User ID = \(FBSDKAccessToken.currentAccessToken().userID)")
            
            
            if (FBSDKAccessToken.currentAccessToken() != nil){
                
                let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("ProtectedPage") as! ProtectedPage
                
                //let protectedPageNav = UINavigationController(rootViewController: protectedPage)
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = protectedPage
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
