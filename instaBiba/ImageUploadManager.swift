//
//  ImageUploadManager.swift
//  instaBiba
//
//  Created by    aviv gofer on 01/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import FirebaseStorage

class ImageUploadManager: NSObject {
    func UploadIamge(_ image: UIImage,progressBlock: @escaping (_ precentage: Double)-> Void,completionBlock: @escaping(_ url:URL?,_ errorMessage: String?)-> Void){
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imageReference = storageReference.child("instaImages").child(imageName)
        
        
        
    }
}
