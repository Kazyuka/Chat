//
//  Group.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class RoomChat {
    
    var groupName: String?
    var groupUID: String?
    var ovnerGroup: String?
    var imageGroup: String?
    var usersChat: [String]?
    var isSingle: Bool?
    var message: [Message]?
    var lastMessage: String?
    var toId: String?
    var searchUser: String?
    
    init(dic: [String : AnyObject]) {
        
        if let name = dic["nameGroup"] as? String {
            self.groupName = name
        }
        self.groupUID = dic["uidGroup"] as? String
        self.ovnerGroup = dic["ovnerGroup"] as? String
        
        if let image = dic["groupImageUrl"] as? String {
            self.imageGroup = image
        }
        
        isSingle = dic["isSingle"] as? Bool
        
        if let arrayUserChat = dic["users"] as? Dictionary<String, AnyObject> {
            usersChat = getUsersForChat(dic: arrayUserChat)
        }
        
        if let lastM = dic["last-message"] as? String {
           lastMessage = lastM
        }
        if let toID = dic["toId"] as? String {
            toId = toID
            getUserNameById(idUser: toID, userName: { (user)  in
                self.searchUser = user
            })
        }
        
        if let mes = dic["messages"] as? Dictionary<String, AnyObject> {
            message = getMessageChat(dic: mes)
        }
    }
    
    func getUserNameById(idUser: String, userName: @escaping (String) ->() ) {
        
        let ref = Database.database().reference().child("users").child(idUser)
        ref.observeSingleEvent(of: .value, with: { (snap) in
            
            if let u = snap.value as? [String: AnyObject] {
                let user = User(dic: u)
                userName(user.name + " " + user.lastName!)
            }
        })
    }

    func getUsersForChat(dic: Dictionary<String, AnyObject>) -> [String] {
        
        var arrayUsers = [String]()
        for d in  dic {
            let messeageDictionary =  d.value as? Dictionary<String, AnyObject>
            if messeageDictionary != nil {
                let toId = messeageDictionary!["toId"] as? String
                arrayUsers.append(toId!)
            }
        }
        return arrayUsers
    }
    
    static func getCurrentUserFromSingleMessage(chatRoom: RoomChat, user: @escaping (User)->())  {
        
        let uid = Auth.auth().currentUser?.uid
        
        if uid == chatRoom.ovnerGroup {
            let ref = Database.database().reference().child("users").child(chatRoom.toId!)
            ref.observeSingleEvent(of: .value, with: { (snap) in
                
                if let u = snap.value as? [String: AnyObject] {
                    let use = User(dic: u)
                    user(use)
                }
            })
        } else {
            
            let ref = Database.database().reference().child("users").child(chatRoom.ovnerGroup!)
            ref.observeSingleEvent(of: .value, with: { (snap) in
                
                if let u = snap.value as? [String: AnyObject] {
                    let use = User(dic: u)
                    user(use)
                }
            })
        }
    }
    
    func getMessageChat(dic: Dictionary<String, AnyObject>) -> [Message] {
        var arrayMessage = [Message]()
        for d in  dic {
            let messeageDictionary =  d.value as? Dictionary<String, AnyObject>
            let mes = Message.init(dic: messeageDictionary!)
            arrayMessage.append(mes)
        }
        return arrayMessage
    }
}

