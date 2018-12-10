//
//  ModelFirebase.swift
//  instaBiba
//
//  Created by    aviv gofer on 06/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class ModelFirebase {
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var imageUrlFromData : String
    
    init(){
        ref = Database.database().reference()
        imageUrlFromData = ""
    }

    func getEmailName() -> String {
        let emailName = Auth.auth().currentUser?.email?.split(separator: "@")[0]
        return emailName != nil ? (String(emailName!)) : "noNameEmail"
    }
    
    func addNewPostToData(post:Post){
        //ref.child("posts").child(post.id).setValue(post.toJson())
          ref.child("Posts").child(getEmailName()).child(post.id).setValue(post.toJson())
    }
    
    
    func getCurrentUserImages(){
  
    }
  
  

    
    
    func addNewUserToData(user:User){
 
        ref.child("Users").child(user.name).setValue(user.toJson())
    }
}
