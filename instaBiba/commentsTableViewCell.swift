//
//  commentsTableViewCell.swift
//  instaBiba
//
//  Created by    aviv gofer on 20/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit

class commentsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
  //  @IBOutlet weak var userImage: UIImageView!
   // @IBOutlet weak var userNameLabel: UILabel!
 //   @IBOutlet weak var commentLabel: UILabel!
  //  @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width/2
    }
    
}
