//
//  Model.swift
//  instaBiba
//
//  Created by    aviv gofer on 06/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import Foundation
import UIKit

class Model {
    static let instance:Model = Model()
    
  //  let studentsListNotification = "com.menachi.studentlist"
    
    //var modelSql:ModelSql?
    var modelFirebase = ModelFirebase();
    
    private init(){
        //modelSql = ModelSql()
    }
    
//
//    func getAllStudents() {
//        modelFirebase.getAllStudents(callback: {(data:[Student]) in
//            NotificationCenter.default.post(name: NSNotification.Name(self.studentsListNotification),
//                                            object: self,
//                                            userInfo: ["data":data])
//
//        })
//    }
    
//    func getAllStudents(callback:@escaping ([Student])->Void){
//        modelFirebase.getAllStudents(callback: callback);
//        //return Student.getAll(database: modelSql!.database);
//    }
    
    func addNewUserToData(user:User){
        modelFirebase.addNewUserToData(user: user);
        //Student.addNew(database: modelSql!.database, student: student)
    }
    
    func getNameFromEmail() -> String{
        return modelFirebase.getEmailName()
    }
    
    func getCurrentUser(completion:@escaping (_ user: User)->())
    {
        modelFirebase.getCurrentUser(completion:{ result in
            completion(result)
        })
        
    }
    
    func uploadPostToStorageAndData(image:UIImage,title:String,completion:@escaping ()->())
    {
        modelFirebase.uploadPostToStorageAndData(image: image, title: title,completion:{
            completion()
        })
    }
    
    func uploadProfileImageToStorageAndData(image:UIImage,name: String,email: String,completion:@escaping ()->())
    {
        modelFirebase.uploadProfileImageToStorageAndData(image: image,name: name,email: email,completion:{
            completion()
        })
    }
    
    func addNewPostToData(post:Post){
        modelFirebase.addNewPostToData(post: post)
    }
    
    func getProfileImageUrlByEmailName(emailName:String,completion:@escaping (String)->()){
        modelFirebase.getProfileImageUrlByEmailName(emailName: emailName){(result) -> () in
            completion(result)
            
        }
    }
    
    func getAllLikesByEmail(email:String,postId:String,completion:@escaping ([Like])->()){
        modelFirebase.getAllLikesByEmail(email:email,postId:postId){(likes) in
            completion(likes)
        }
    }
    func getAllPostsByEmail(email: String,completion:@escaping ([Post])->()){
        modelFirebase.getAllPostsByEmail(email:email) { (result) -> () in
            completion(result)
        }
    }
    
    func getAllFollowers(userName:String,compeltion:@escaping ([User])->()){
        modelFirebase.getAllFollowers(userName:userName){(followers) in
            compeltion(followers)
        }
    }
    
    func getAllFollowing(userName:String,compeltion:@escaping ([User])->()){
        modelFirebase.getAllFollowing(userName:userName){(followers) in
            compeltion(followers)
        }
    }
    
    func addFollowToData(user:User){
        modelFirebase.addFollowToData(user:user)
    }
    
    func getAllUsers(completion:@escaping ([User])->()){
        modelFirebase.getAllUsers(){(allUsers) in
            completion(allUsers)
        }
    }
    
    func addLikeToData(post:Post){
        modelFirebase.addLikeToData(post:post)
    }
    
    func deleteLikeFromData(post:Post){
        modelFirebase.deleteLikeFromData(post:post)
    }
    
    func deleteFollowFromData(user:User){
        modelFirebase.deleteFollowFromData(user:user)
    }
    
    func getAllFollowingPosts(completion:@escaping ([Post])->()){
        modelFirebase.getAllFollowingPosts(){(posts) in
            completion(posts)
        }
    }
    
    
    func  downloadImage(url: URL ,completion:@escaping (UIImage)->()){
        
        //1. try to get the image from local store
        let _url = url
        let localImageName = _url.lastPathComponent
        if let image = self.getImageFromFile(name: localImageName){
            completion(image)
            print("got image from cache \(localImageName)")
        }else{
            //2. get the image from Firebase
            modelFirebase.downloadImage(url:url){(image) in
                completion(image)
                    //3. save the image localy
                self.saveImageToFile(image: image, name: localImageName)
                
                //4. return the image to the user
                print("got image from firebase \(localImageName)")
            }
        }
    }
    
  
    
    /// File handling
    func saveImageToFile(image:UIImage, name:String){
        if let data = image.jpegData(compressionQuality: 0.75) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }

    
    
    
    
    
    
    
    //////////////////////////
    
    func addCommentToData(comment:String,post:Post){
        modelFirebase.addCommentToData(comment:comment,post:post)
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
   
    
//    func getStudent(byId:String)->Student?{
//        return modelFirebase.getStudent(byId:byId)
//        //return Student.get(database: modelSql!.database, byId: byId);
//    }
}
