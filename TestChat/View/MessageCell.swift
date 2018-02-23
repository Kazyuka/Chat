//
//  MessageCell.swift
//  TestChat
//
//  Created by Руслан Казюка on 21.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MessageCell: UserCell {
    
    var message: Message! {
        didSet {
            configureView()
        }
    }
    
    override func configureView() {
        
        if let todId  = message?.chatPartnerId {
            let ref = Database.database().reference().child("users")
            ref.child(todId).observeSingleEvent(of: .value, with: { (snap) in
                
                if let data = snap.value as? [String: AnyObject] {
                    let user = User(dic: data)
                    self.userName.text = user.name
                    let data = NSData.init(contentsOf: URL.init(string: user.imageProfile!)!)
                    self.userImage.image = UIImage(data: data as! Data)
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
