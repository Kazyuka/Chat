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

class MessageCell: UserCell {
    
    var message: Message! {
        didSet {
            configureView()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
        
       
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        
        if let todId  = message?.chatPartnerId {
            let ref = Database.database().reference().child("users")
            ref.child(todId).observeSingleEvent(of: .value, with: { (snap) in
                
                if let data = snap.value as? [String: AnyObject] {
                    let user = User(dic: data)
                    self.userName.text = user.name
                    let url = NSURL.init(string: user.imageProfile!)
                    self.userImage.sd_setImage(with: url as! URL)
                }
            })
        }
        self.messageText.text = message.text
        if let sec = message.time?.doubleValue {
            let timeS = NSDate(timeIntervalSince1970: sec)
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "hh:mm:ss a"
            timeLabel.text = dateFormater.string(from: timeS as Date)
        }
    }
}
