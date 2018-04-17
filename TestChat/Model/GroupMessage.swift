//
//  GroupMessage.swift
//  TestChat
//
//  Created by Руслан Казюка on 12.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class GroupMessage: Message {

    var toIdUsers = [String]()
    var usersWhuGetMessage = [User]()
    var currentUser = " "
    
    override init(dic: [String : AnyObject]) {
        super.init(dic: dic)
        
        self.fromIdUser = dic["fromId"] as? String
        let toId = dic["toId"] as? String
        let arrayId = toId?.components(separatedBy: " ")
        for id in arrayId! {
            toIdUsers.append(id)
        }
        if let textMessage = dic["text"] as? String {
            self.text = textMessage
        }
        if let imageMessage = dic["imageUrl"] as? String {
            self.imageUrl = imageMessage
        }
        self.time = dic["time"] as? NSNumber
    
    }
    
    func getCurrentUserGroupChat() {
        
         if fromIdUser == Auth.auth().currentUser?.uid {
            
            for userId in toIdUsers {
                
                let ref = Database.database().reference().child("users").child(userId)
                ref.observeSingleEvent(of: .value) { (snap) in
                    
                    if let data = snap.value as? [String: AnyObject] {
                        
                        let user = User(dic: data)
                        user.userId = userId
                        self.usersWhuGetMessage.append(user)
                        
                    }
                }
            }
         } else {
            
            toIdUsers.append(fromIdUser!)
            for userId in toIdUsers {
                if userId == Auth.auth().currentUser?.uid {
                    self.fromIdUser = userId
                } else {
                    let ref = Database.database().reference().child("users").child(userId)
                    ref.observeSingleEvent(of: .value) { (snap) in
                        
                        if let data = snap.value as? [String: AnyObject] {
                            
                            let user = User(dic: data)
                            user.userId = userId
                            self.usersWhuGetMessage.append(user)
                        }
                    }
                }
            }
        }
    }
}
