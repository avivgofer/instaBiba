//
//  messageTableViewCell.swift
//  instaBiba
//
//  Created by    aviv gofer on 27/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//


import UIKit
import Foundation

class messageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var allMessages = [User]()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      //  profileImage.layer.masksToBounds = true
      //  profileImage.layer.cornerRadius = profileImage.frame.width/2
    }
    
}
