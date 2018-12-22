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
    var currentUser : User?
    
    init(){
        ref = Database.database().reference()
        imageUrlFromData = ""
        
    }
   
    
    func getEmailName() -> String {
        let emailName = Auth.auth().currentUser?.email?.split(separator: "@")[0].split(separator: ".")[0]
        
        return emailName != nil ? (String(emailName!)) : "noNameEmail"
    }
    
    func cutEmailName(email:String) -> String{
        let emailName = email.split(separator: "@")[0].split(separator: ".")[0]
        return emailName != "" ? (String(emailName)) : "noNameEmail"
    }
    
    func addNewPostToData(post:Post){
          ref.child("Posts").child(getEmailName()).child(post.id).setValue(post.toJson())
    }
   
    func getProfileImageUrlByEmailName(emailName:String,completion:@escaping (String)->()){
        ref?.child("Users").child(emailName).observeSingleEvent(of: .value, with: { (snapshot) in
            //in my case the answer is of type array so I can cast it like this, should also work with NSDictionary or NSNumber
            if let snapshotValue = snapshot.value as? NSDictionary{
                //then I iterate over the values
                var tempUrl = snapshotValue.value(forKey: "profileImgUrl") as! String
//                for (_,eachFetchedRestaurant) in snapshotValue{
//                    //  let x = eachFetchedRestaurant as? NSDictionary
//                    //  let imageUrlData = (x!.value(forKey: "imageUrl"))!
//                    let y = eachFetchedRestaurant
//                    let tempPost = Post(json: y as! [String : Any] )
//                    posts.append(tempPost)
                    //                    print(imageUrlData)
                    //                    self.downloadImage(from: URL(string: imageUrlData as! String)!){ () -> () in
                    //                        //Callback
                    //                        self.imageCollection.reloadData()
                    //                    }
                    
                completion(tempUrl)
                }
            
                
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getAllPostsByEmail(email:String,completion:@escaping ([Post])->()){
        
        ref?.child("Posts").child(cutEmailName(email: email)).observeSingleEvent(of: .value, with: { (snapshot) in
            //in my case the answer is of type array so I can cast it like this, should also work with NSDictionary or NSNumber
            if let snapshotValue = snapshot.value as? NSDictionary{
                //then I iterate over the values
                var posts = [Post]()
                for (_,eachFetchedRestaurant) in snapshotValue{
                  //  let x = eachFetchedRestaurant as? NSDictionary
                  //  let imageUrlData = (x!.value(forKey: "imageUrl"))!
                    let y = eachFetchedRestaurant
                    let tempPost = Post(json: y as! [String : Any] )
                    posts.append(tempPost)
//                    print(imageUrlData)
//                    self.downloadImage(from: URL(string: imageUrlData as! String)!){ () -> () in
//                        //Callback
//                        self.imageCollection.reloadData()
//                    }
                    
                }
                completion(posts)

                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    func getCurrentUserImages(){
  
    }
  
    func uploadProfileImageToStorageAndData(image: UIImage,name: String,email: String,completion:@escaping ()->()) {
        let resizedImage = resizeImage(image: image, targetSize: CGSize.init(width: 300, height: 300))
        let imageData = resizedImage.jpegData(compressionQuality: 10)
        let uploadRef = Storage.storage().reference().child("images/\(getEmailName())/profileImg.jpg")
        _ = uploadRef.putData(imageData!, metadata: nil) { (metadata, error) in
            uploadRef.downloadURL { (url, error) in
                guard let downloadURL = url else {  return }// Uh-oh, an error occurred!
                let randomName = self.randomStringWithLength(length: 10)
                let url = downloadURL.absoluteString
                let user = User(_id: randomName as String, _name: name, _email: email, _profileImgUrl: url, _followingList: nil, _followersList: nil)
                self.addNewUserToData(user: user)
                completion()
            }
        }
    }
    
  
    func uploadPostToStorageAndData(image: UIImage,title : String,completion:@escaping ()->()){
        let resizedImage = resizeImage(image: image, targetSize: CGSize.init(width: 300, height: 300))
        let randomName = randomStringWithLength(length: 10)
        let imageData = resizedImage.jpegData(compressionQuality: 10)
        let uploadRef = Storage.storage().reference().child("images/\(getEmailName())/\(randomName).jpg")
        _ = uploadRef.putData(imageData!, metadata: nil) { (metadata, error) in
            uploadRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                let userEmail = Auth.auth().currentUser?.email
                let url = downloadURL.absoluteString
                let post = Post(_id: randomName as String,_email : userEmail!, _title: title, _imageUrl: url)
                self.addNewPostToData(post:post)
                completion()
            }
        }
    }
    
    
    func addNewUserToData(user:User){
 
        ref.child("Users").child(getEmailName()).setValue(user.toJson())
    }
    
    func addCommentToData(comment:String,post:Post){
        getCurrentUser(){(result) in
            let tempComment = Comment(_comment: comment, _userEmailName: self.cutEmailName(email:  result.email))
            self.ref.child("Posts").child(self.cutEmailName(email: post.email)).child(post.id).child("Comments").child(tempComment.date).setValue(tempComment.toJson())
        }
    }
    
    //random name for image
    func randomStringWithLength(length: Int) -> NSString {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: length)
        
        for _ in 0..<length {
            let len = UInt32(characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        return randomString
    }
    
    
    func getCurrentUser(completion:@escaping (_ user: User)->())
    {
        let usersRef = ref.child("Users/\(getEmailName())") // As you see on my Firebase screenshot
        usersRef.observe(.value, with: { (snapshot) in
         let newUser = User(snapshot: snapshot)
            self.currentUser = newUser
            completion(newUser)
        }) { (error) in
            print(error)
        }
       // completion = self.currentUser
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
}
