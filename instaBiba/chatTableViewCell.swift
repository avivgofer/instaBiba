//
//  chatTableViewCell.swift
//  instaBiba
//
//  Created by    aviv gofer on 27/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//



import UIKit
import Foundation

class chatTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var hisTimeLabel: UILabel!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var hisProfileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
          myProfileImage.layer.masksToBounds = true
        myProfileImage.layer.cornerRadius = myProfileImage.frame.width/2
        hisProfileImage.layer.masksToBounds = true
        hisProfileImage.layer.cornerRadius = hisProfileImage.frame.width/2
    }
    
}

