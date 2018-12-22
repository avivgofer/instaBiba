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
    func getAllPostsByEmail(email: String,completion:@escaping ([Post])->()){
        modelFirebase.getAllPostsByEmail(email:email) { (result) -> () in
            completion(result)
        }
    }
    
    func addCommentToData(comment:String,post:Post){
        modelFirebase.addCommentToData(comment:comment,post:post)
    }
    
   
    
//    func getStudent(byId:String)->Student?{
//        return modelFirebase.getStudent(byId:byId)
//        //return Student.get(database: modelSql!.database, byId: byId);
//    }
}
