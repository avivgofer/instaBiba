//
//  Post.swift
//  instaBiba
//
//  Created by    aviv gofer on 06/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//


import UIKit
import Foundation
class Post {
    let id:String
    let email:String
    let title:String
    let imageUrl:String
    let likes : [User]?
    //let phone:String
    
    
    init(_id:String,_email:String, _title:String,_imageUrl:String){
        id = _id
        email = _email
        title = _title
        imageUrl = _imageUrl
        likes = nil
    }
    
    init(json:[String:Any]) {
        id = json["id"] as! String
        email = json["email"] as! String
        title = json["title"] as! String
        imageUrl = json["imageUrl"] as! String
        likes = json["likes"] as! [User]?
    }
  
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        json["id"] = id
        json["email"] = email
        json["title"] = title
        json["imageUrl"] = imageUrl
        json["likes"] = likes
        return json
    }
}
