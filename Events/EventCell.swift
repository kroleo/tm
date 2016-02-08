/* ----------------------

- Events -

created by FV iMAGINATION ©2015
for CodeCanyon.net

---------------------------*/


import UIKit

class EventCell: UICollectionViewCell {
    
    /* Views */
    @IBOutlet var eventImage: UIImageView!
    
    //@IBOutlet var dayNrLabel: UILabel!
    //@IBOutlet var monthLabel: UILabel!
    //@IBOutlet var yearLabel: UILabel!
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var costLabel: UILabel!
    
    @IBOutlet weak var eventImageBackground: UIView!
    
    @IBOutlet weak var eventImageIcon: UILabel!

    @IBOutlet weak var eventProfileImageBackground: UIView!
    
    @IBOutlet weak var eventProfileImageIcon: UILabel!
}
