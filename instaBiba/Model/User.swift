//
//  User.swift
//  instaBiba
//
//  Created by    aviv gofer on 06/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Foundation
class User {
    let id:String
    let email:String
    let name:String
    let profileImgUrl:String
    let followingList:User?
    let followersList:User?
    //let phone:String
    
    
    init(_id:String, _name:String,_email:String,_profileImgUrl:String,_followingList:User?,_followersList:User?){
        id = _id
        name = _name
        email = _email
        profileImgUrl = _profileImgUrl
        followingList = _followingList
        followersList = _followersList
    }
    
    init(json:[String:Any]) {
        id = json["id"] as! String
        name = json["name"] as! String
        email = json["email"] as! String
        profileImgUrl = json["profileImgUrl"] as! String
        followingList = json["followingList"] as! User
        followersList = json["followersList"] as! User
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        json["id"] = id
        json["name"] = name
        json["email"] = email
        json["profileImgUrl"] = profileImgUrl
        json["followingList"] = followingList
        json["followersList"] = followersList
        return json
    }
}
