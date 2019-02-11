//
//  UserSql.swift
//  instaBiba
//
//  Created by    aviv gofer on 29/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//
import Foundation
import SQLite3

extension User{
    
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS USERS (USER_ID TEXT PRIMARY KEY, NAME TEXT, EMAIL TEXT, PROFILEIMGURL TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func getAll(database: OpaquePointer?)->[User]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [User]()
        if (sqlite3_prepare_v2(database,"SELECT * from USERS;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let userID = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let userName = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let userEmail = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                let userProfilImgUrl = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
                data.append(User(_id: userID, _name: userName, _email: userEmail, _profileImgUrl: userProfilImgUrl, _followingList: nil, _followersList: nil))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    static func addNew(database: OpaquePointer?, user:User){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO USERS(USER_ID, NAME, EMAIL,PROFILEIMGURL) VALUES (?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let userID = user.id.cString(using: .utf8)
            let userName = user.name.cString(using: .utf8)
            let userEmail = user.email.cString(using: .utf8)
            let userProfileImgUrl = user.profileImgUrl.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, userID,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, userName,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, userEmail,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, userProfileImgUrl,-1,nil);
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func get(database: OpaquePointer?, byId:String)->User?{
        
        return nil;
    }
}

