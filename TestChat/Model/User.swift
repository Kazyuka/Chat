//
//  User.swift
//  TestChat
//
//  Created by Руслан Казюка on 14.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class User: NSObject {
    
    var name: String  = " "
    var email: String = " "
    var imageProfile: String?
    var userId: String?
    var lastName: String?
    var aboutMe: String?
    var uid: String?
    
    init(dic: [String: AnyObject]) {
        self.name = dic["name"] as! String
        self.email = dic["email"] as! String
        if let image = dic["profileImageUrl"] as? String {
            self.imageProfile = image
        } 
        self.lastName = dic["lastName"] as? String
        self.aboutMe = dic["aboutMe"] as? String
        if let id = dic["uid"] as? String {
            self.uid = id
        }
    }
    
    static func getCurrentUserFromFirebase(user: @escaping (User)->())  {

        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snap) in
                
                if let u = snap.value as? [String: AnyObject] {
                    let use = User(dic: u)
                    user(use)
                }
            })
        }
    }
}

