//
//  Group.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import Foundation


struct Group {
    
    var groupName: String?
    var groupUID: String?
    var ovnerGroup: String?
    var imageGroup: String?
    
    init(dic: [String : AnyObject]) {
        
        self.groupName = dic["nameGroup"] as? String
        self.groupUID = dic["uidGroup"] as? String
        self.ovnerGroup = dic["fromId"] as? String
        self.imageGroup = dic["groupImageUrl"] as? String
    }
}
