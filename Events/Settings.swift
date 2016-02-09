//
//  Settings.swift
//  Events
//
//  Created by Harsha Cuttari on 1/20/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse


class Settings: UIViewController {

    @IBAction func logoutFacebookButton(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock{(error:NSError?) -> Void in
            
            let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("FacebookLoginScreen") as! FacebookLoginScreen
            
            //let protectedPageNav = UINavigationController(rootViewController: protectedPage)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = loginPage
            
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        //self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
