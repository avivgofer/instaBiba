//
//  TestTableViewCell.swift
//  instaBiba
//
//  Created by    aviv gofer on 12/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var watcherName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        memberImage.layer.masksToBounds = true
        memberImage.layer.cornerRadius = memberImage.frame.width/2
    }
    


}
