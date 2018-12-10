//
//  ImageCollectionViewCell.swift
//  instaBiba
//
//  Created by    aviv gofer on 22/11/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}
