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
    
    override init(dic: [String : AnyObject]) {
        super.init(dic: dic)
        
        if let textMessage = dic["text"] as? String {
            self.text = textMessage
        }
        if let imageMessage = dic["imageUrl"] as? String {
            self.imageUrl = imageMessage
        }
        self.fromIdUser = dic["fromId"] as? String
    }
}
