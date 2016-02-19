//
//  PrivacyPolicy.swift
//  Events
//
//  Created by Harsha Cuttari on 2/19/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit

class PrivacyPolicy: UIViewController {
    
    @IBOutlet var privacyPolicyView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let localfilePath = NSBundle.mainBundle().URLForResource("ppWebFile", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        privacyPolicyView.loadRequest(myRequest);
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
