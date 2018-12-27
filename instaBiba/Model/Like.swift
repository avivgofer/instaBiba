
import UIKit
import Foundation
import FirebaseDatabase

class Like {
    let userEmailName:String
    let userProfileImageUrl:String
    let date :String
    
    
    
    init(_userEmailName:String,_userProfileImageUrl:String){
        userEmailName = _userEmailName
        userProfileImageUrl = _userProfileImageUrl
        date = DateFormatter.sharedDateFormatter.string(from: Date())
    }
    
    init(json:[String:Any]) {
        userEmailName = json["userEmailName"] as! String
        userProfileImageUrl = json["userProfileImageUrl"] as! String
        date = DateFormatter.sharedDateFormatter.string(from: Date())
    }
    
    init(snapshot: DataSnapshot) {
        let udic = snapshot.value! as! [String: AnyObject]
        userEmailName = udic["userEmailName"] as! String
        userProfileImageUrl = udic["userProfileImageUrl"] as! String
        date = udic["date"] as! String
        //        id = ""
        //        name = ""
        //        email = ""
        
    }
    
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        json["userEmailName"] = userEmailName
        json["userProfileImageUrl"] = userProfileImageUrl
        json["date"] = date
        return json
    }
}

//extension DateFormatter {
//
//    static var sharedDateFormatter: DateFormatter = {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return dateFormatter
//    }()
//}
