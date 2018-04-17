//
//  User.swift
//  TestChat
//
//  Created by Руслан Казюка on 14.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String  = " "
    var email: String = " "
    var imageProfile: String?
    var userId: String?
    var lastName: String?
    var aboutMe: String?
    
    init(dic: [String: AnyObject]) {
        self.name = dic["name"] as! String
        self.email = dic["email"] as! String
        if let image = dic["profileImageUrl"] as? String {
            self.imageProfile = image
        } 
        self.lastName = dic["lastName"] as? String
        self.aboutMe = dic["aboutMe"] as? String
    }
}

