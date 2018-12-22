//
//  Comment.swift
//  instaBiba
//
//  Created by    aviv gofer on 18/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//


import UIKit
import Foundation
import FirebaseDatabase

class Comment {
    let comment:String
    let userEmailName:String
    let date :String
    
    
    init(_comment:String,_userEmailName:String){
        comment = _comment
        userEmailName = _userEmailName
        date = DateFormatter.sharedDateFormatter.string(from: Date())
    }
    
    init(json:[String:Any]) {
        comment = json["comment"] as! String
        userEmailName = json["userEmailName"] as! String
        date = DateFormatter.sharedDateFormatter.string(from: Date())
    }
    
    init(snapshot: DataSnapshot) {
        let udic = snapshot.value! as! [String: AnyObject]
        comment = udic["comment"] as! String
        userEmailName = udic["userEmailName"] as! String
        date = udic["date"] as! String
        //        id = ""
        //        name = ""
        //        email = ""
        
    }
    
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        json["comment"] = comment
        json["userEmailName"] = userEmailName
        json["date"] = date
        return json
    }
}

extension DateFormatter {
    
    static var sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
}
