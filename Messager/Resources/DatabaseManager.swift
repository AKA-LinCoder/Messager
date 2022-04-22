//
//  DatabaseManager.swift
//  Messager
//
//  Created by lsaac on 2022/4/22.
//

import Foundation
import FirebaseDatabase

final class Databasemanager{
    static let shared = Databasemanager()
    
    private let database = Database.database().reference()
    
  
    

}

//MARK:-Account Mgmt
extension Databasemanager{
    
    public func userExists(with email:String,completion:@escaping ((Bool)-> Void)){
        print("here")
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard (snapshot.value as? String) != nil else{
                completion(false)
                return
            }
            completion(true)
            
        }
        print("987")
        completion(false)
        
    }
    
    /// Inserts new user to database
    public func insertUser(with user:ChatAppUser){
        
        
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ])
    }
}


struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var safeEmail : String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
