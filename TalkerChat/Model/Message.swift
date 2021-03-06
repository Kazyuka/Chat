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
    var imageUrl: String?
    var videoUrl: String?
    
    init(dic: [String: AnyObject]) {
        self.fromIdUser = dic["fromId"] as? String
        self.toIdUser = dic["toId"] as? String
        if let textMessage = dic["text"] as? String {
             self.text = textMessage
        }
        if let imageMessage = dic["imageUrl"] as? String {
            self.imageUrl = imageMessage
        }
        
        if let videoMessage = dic["videoUrl"] as? String {
            self.videoUrl = videoMessage
        }
        
        if let t = dic["time"] as? NSNumber {
            self.time = t
        }
    }
    
    var chatPartnerId: String? {
        return (fromIdUser == Auth.auth().currentUser?.uid ? toIdUser : fromIdUser)!
    }
}
