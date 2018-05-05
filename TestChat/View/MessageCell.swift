//
//  MessageCell.swift
//  TestChat
//
//  Created by Руслан Казюка on 21.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import FirebaseAuth

class MessageCell: UserCell {
    
    @IBOutlet weak var messageText: UILabel!
    var chat: RoomChat! {
        didSet {
            configureView()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func configureView() {
        
        if let isSingleOptional = chat.isSingle {
            
            if isSingleOptional {
                
                RoomChat.getCurrentUserFromSingleMessage(chatRoom: chat, user: { (user) in
                    if let im = user.imageProfile {
                        let url = NSURL.init(string: im)
                        self.userPhoto.sd_setImage(with: url! as URL)
                    } else {
                        
                        self.userPhoto.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "userImage.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
                        }, completed: nil)
                    }
                    self.userName.text = user.name
                    self.messageText.text = self.chat.lastMessage
                })
                
            } else {
                
                if let im = chat.imageGroup {
                    let url = NSURL.init(string: im)
                    self.userPhoto.sd_setImage(with: url! as URL)
                }
                self.userName.text = chat.groupName
                self.messageText.text = self.chat.lastMessage
            }
        }
    }
}
