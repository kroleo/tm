//
//  GoingListView.swift
//  Events
//
//  Created by Omar Mihilmy on 2/6/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse

class GoingListView: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //http://www.codingexplorer.com/getting-started-uitableview-swift/
    
    @IBOutlet var tableView: UITableView!
    let array = (SelectedEvent["going"] as! Array<String>)
    var names = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let query = PFQuery(className: "_User")
        query.selectKeys(["first_name","last_name"])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if(error == nil){
                if let objects = objects{
                    for object in objects{
                        for s in self.array{
                            if(object.objectId == s){
                                
                                let name = (object["first_name"] as! String) + " " + (object["last_name"] as! String)
                                print(name)
                                self.names.append(name)
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = names[row]
        
        return cell
    }
    
    
}
