//
//  Message.swift
//  instaBiba
//
//  Created by    aviv gofer on 27/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class Message {
    let userEmailName:String
    let userProfileImageUrl:String
    let message:String
    let date :String
    
    
    
    init(_userEmailName:String,_userProfileImageUrl:String,_message:String){
        userEmailName = _userEmailName
        userProfileImageUrl = _userProfileImageUrl
        message = _message
        date = DateFormatter.sharedDateFormatter.string(from: Date())
    }
    
    init(json:[String:Any]) {
        userEmailName = json["userEmailName"] as! String
        userProfileImageUrl = json["userProfileImageUrl"] as! String
        message = json["message"] as! String
        date = json["date"] as! String
    }
    
    init(snapshot: DataSnapshot) {
        let udic = snapshot.value! as! [String: AnyObject]
        userEmailName = udic["userEmailName"] as! String
        userProfileImageUrl = udic["userProfileImageUrl"] as! String
        message = udic["message"] as! String
        date = udic["date"] as! String
        //        id = ""
        //        name = ""
        //        email = ""
        
    }
    
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        json["userEmailName"] = userEmailName
        json["userProfileImageUrl"] = userProfileImageUrl
        json["message"] = message
        json["date"] = date
        return json
    }
}
