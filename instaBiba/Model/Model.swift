//
//  Model.swift
//  instaBiba
//
//  Created by    aviv gofer on 06/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import Foundation

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
    
    func addNewPostToData(post:Post){
        modelFirebase.addNewPostToData(post: post)
    }
    
    func getCurrentUserImages(){
        modelFirebase.getCurrentUserImages()
    }
   
    
//    func getStudent(byId:String)->Student?{
//        return modelFirebase.getStudent(byId:byId)
//        //return Student.get(database: modelSql!.database, byId: byId);
//    }
}
