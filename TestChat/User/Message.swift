//
//  Message.swift
//  TestChat
//
//  Created by Руслан Казюка on 21.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
class Message: NSObject {
    
    var fromIdUser: String?
    var toIdUser: String?
    var text: String?
    var time: NSNumber?
    
    init(dic: [String: AnyObject]) {
        self.fromIdUser = dic["fromId"] as? String
        self.toIdUser = dic["toId"] as? String
        self.text = dic["text"] as? String
        self.time = dic["time"] as? NSNumber
    }
    
    var chatPartnerId: String? {
        return (fromIdUser == Auth.auth().currentUser?.uid ? toIdUser : fromIdUser)!
    }
}
