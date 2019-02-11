//
//  ModelSql.swift
//  instaBiba
//
//  Created by    aviv gofer on 29/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//
import Foundation
import SQLite3
import SQLite

class ModelSql {
    var database: OpaquePointer? = nil
    
    init() {
        // initialize the DB
        let dbFileName = "database2.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            print(path)
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return
            }
            //dropTables()
            createTables()
        }
        
    }
    
    func createTables() {
        User.createTable(database: database);
    }
    
    func dropTables(){
        
    }
    
    
}
