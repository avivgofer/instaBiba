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
   
    
    //get's the profile picture url of the user by his email
    func getProfileImageUrlByEmailName(emailName:String,completion:@escaping (String)->()){
        ref?.child("Users").child(emailName).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? NSDictionary{
                let tempUrl = snapshotValue.value(forKey: "profileImgUrl") as! String
                completion(tempUrl)
                }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //get's an array of all the users
    func getAllUsers(completion:@escaping ([User])->()){
        ref.child("Users").observe(.value, with: { (snapshot) in
            var allusers = [User]()
            for user in snapshot.children {
                let newUser = User(snapshot: user as! DataSnapshot)
                allusers.append(newUser)
            }
            completion(allusers)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //get's an array of users that this username follow them
    func getAllFollowing(userName:String,compeltion:@escaping (([User])->())){
        ref.child("Users").child(cutEmailName(email:userName)).child("FollowingList").observe(.value, with: { (snapshot) in
            var tempFollowing = [User]()
            for user in snapshot.children {
                let tempUser = User(snapshot: user as! DataSnapshot)
                tempFollowing.append(tempUser)
            }
            compeltion(tempFollowing)
        }) { (error) in
            print(error)
        }
    }
    
   // get's an array of users that following of that username
    func getAllFollowers(userName:String,compeltion:@escaping (([User])->())){
        ref.child("Users").child(cutEmailName(email:userName)).child("FollowersList").observe(.value, with: { (snapshot) in
            var tempFollowers = [User]()
            for user in snapshot.children {
                let tempUser = User(snapshot: user as! DataSnapshot)
                tempFollowers.append(tempUser)
            }
            compeltion(tempFollowers)
        }) { (error) in
            print(error)
        }
    }
    
    //get's an array of all the likes that this post have(by: postID and email)
    func getAllLikesByEmail(email:String,postId:String,compeltion:@escaping ([Like])->()){
        ref.child("Posts").child(cutEmailName(email: email)).child(postId).child("Likes").observe(.value, with: { (snapshot) in
                    var tempLikes = [Like]()
                    for like in snapshot.children {
                        let tempLike = Like(snapshot: like as! DataSnapshot)
                        tempLikes.append(tempLike)
                    }
                    compeltion(tempLikes)
                }) { (error) in
                    print(error)
                }
    }
    
    func getAllNamesOfConversition(completion:@escaping ([String])->()){
        ref?.child("Users").child(cutEmailName(email:(Auth.auth().currentUser?.email)!)).child("Chat").observe(.value, with: { (snapshot) in
         //   print(snapshot.value(forKey: "userProfileImageUrl")!)
            var temp = [String]()
            if let snapshotValue = snapshot.value as? NSDictionary{
                for (user,x) in snapshotValue{
                    print((x as AnyObject).value(forKey: "userProfileImageUrl") as Any)
                    print(user)
                    temp.append(String(user as! String))
                    }
                completion(temp)
                }
        })
    }
    
    //get's all the message betwin the current user and the send user
    func getAllChat(user:User,completion:@escaping ([Message])->()){
        ref?.child("Users").child(cutEmailName(email:(Auth.auth().currentUser?.email)!)).child("Chat").child(cutEmailName(email: user.email)).observe(.value, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? NSDictionary{
                var allMess = [Message]()
                for (_,eachFetchedRestaurant) in snapshotValue{
                    let y = eachFetchedRestaurant
                    let tempMes = Message(json: y as! [String : Any] )
                    allMess.append(tempMes)
                }
                completion(allMess)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    //get's an array of all the post of the user with that email
    func getAllPostsByEmail(email:String,completion:@escaping ([Post])->()){
        ref?.child("Posts").child(cutEmailName(email: email)).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? NSDictionary{
                var posts = [Post]()
                for (_,eachFetchedRestaurant) in snapshotValue{
                    let y = eachFetchedRestaurant
                    let tempPost = Post(json: y as! [String : Any] )
                    posts.append(tempPost)
                }
                completion(posts)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func  downloadImage(url: URL ,completion:@escaping (UIImage)->()){
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
         //   completion()
            DispatchQueue.main.async() {
                let imageT = UIImage(data: data)!
                completion(imageT)
               // self.appendImage(img: imageT)
                //  self.imageView.image = UIImage(data: data)
             //   self.imageCollection.reloadData()
                
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getCurrentUserImages(){
  
    }
  
    func uploadUserToStorageAndData(image: UIImage,name: String,email: String,completion:@escaping (User)->()) {
        let resizedImage = resizeImage(image: image, targetSize: CGSize.init(width: 300, height: 300))
        let imageData = resizedImage.jpegData(compressionQuality: 10)
        let uploadRef = Storage.storage().reference().child("images/\(getEmailName())/\(getEmailName())profileImg.jpg")
        _ = uploadRef.putData(imageData!, metadata: nil) { (metadata, error) in
            uploadRef.downloadURL { (url, error) in
                guard let downloadURL = url else {  return }// Uh-oh, an error occurred!
                let randomName = self.randomStringWithLength(length: 10)
                let url = downloadURL.absoluteString
                let user = User(_id: randomName as String, _name: name, _email: email, _profileImgUrl: url, _followingList: nil, _followersList: nil)
                self.addNewUserToData(user: user)
                completion(user)
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
    
    func deleteLikeFromData(post:Post){
        getCurrentUser(){(result) in
            self.ref.child("Posts").child(self.cutEmailName(email: post.email)).child(post.id).child("Likes").child(self.cutEmailName(email:  result.email)).removeValue()
        }
    }
    
    func deleteFollowFromData(user:User){
        let currnerUserEmail = Auth.auth().currentUser?.email
        self.ref.child("Users").child(self.cutEmailName(email: user.email)).child("FollowersList").child(self.cutEmailName(email:currnerUserEmail!)).removeValue()
        self.ref.child("Users").child(self.cutEmailName(email:currnerUserEmail!)).child("FollowingList").child(self.cutEmailName(email:  user.email)).removeValue()
    }
    
    func addLikeToData(post:Post){
        getCurrentUser(){(result) in
            let tempLike = Like(_userEmailName: self.cutEmailName(email:  result.email),_userProfileImageUrl:result.profileImgUrl)
            self.ref.child("Posts").child(self.cutEmailName(email: post.email)).child(post.id).child("Likes").child(tempLike.userEmailName).setValue(tempLike.toJson())
        }
    }
    
    func addMessage(message:Message,user:User){
        self.ref.child("Users").child(self.cutEmailName(email: user.email)).child("Chat").child(cutEmailName(email: message.userEmailName)).child(message.date).setValue(message.toJson())
        self.ref.child("Users").child(self.cutEmailName(email: message.userEmailName)).child("Chat").child(cutEmailName(email: user.email)).child(message.date).setValue(message.toJson())
    }
    
    func addFollowToData(user:User){
        getCurrentUser(){(result) in
            self.ref.child("Users").child(self.cutEmailName(email: result.email)).child("FollowingList").child(self.cutEmailName(email: user.email)).setValue(user.toJson())

            self.ref.child("Users").child(self.cutEmailName(email: user.email)).child("FollowersList").child(self.cutEmailName(email: result.email)).setValue(result.toJson())
        }
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
        let usersRef = ref.child("Users/\(getEmailName())")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
         let newUser = User(snapshot: snapshot)
            self.currentUser = newUser
            completion(newUser)
        }) { (error) in
            print(error)
        }
    }
    
    func getAllFollowingPosts(compeltion:@escaping ([Post])->()){
        let myEmailName = cutEmailName(email: (Auth.auth().currentUser?.email)!)
        ref.child("Users").child(myEmailName).child("FollowingList").observeSingleEvent(of:.value, with: { (snapshot) in
            var allUser = [User]()
            for user in snapshot.children {
                let tempUser = User(snapshot: user as! DataSnapshot)
                allUser.append(tempUser)
            }
            var allPosts = [Post]()
            for user in allUser{
                self.getAllPostsByEmail(email: user.email){(posts) in
                    for post in posts{
                        allPosts.append(post)
                    }
                    compeltion(allPosts)
                    allPosts.removeAll()
                }
            }
        }) { (error) in
            print(error)
        }
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        return Model.instance.resizeImage(image:image, targetSize:targetSize)
}
}
