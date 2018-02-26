//
//  UserCell.swift
//  TestChat
//
//  Created by Руслан Казюка on 21.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import SDWebImage

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy var userImage: UIImageView = {
        var im = UIImageView()
        im.layer.cornerRadius = 20
        im.layer.masksToBounds = true
        im.backgroundColor = UIColor.black
        im.contentMode = .scaleAspectFill
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    lazy var userName: UILabel = {
        var im = UILabel()
        im.font = UIFont.systemFont(ofSize: 16)
        im.textColor = UIColor.blue
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    lazy var messageText: UILabel = {
        var im = UILabel()
        im.font = UIFont.systemFont(ofSize: 14)
        im.textColor = UIColor.brown
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    lazy var timeLabel: UILabel = {
        var im = UILabel()
        im.font = UIFont.boldSystemFont(ofSize: 12)
        im.textColor = UIColor.darkGray
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    var user: User! {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
         let url = NSURL.init(string: user.imageProfile!)
        
        self.userImage.sd_setImage(with: url as! URL)
        self.userName.text = user.name
    }
    
    func setUpCell() {
        
        self.addSubview(userImage)
        self.addSubview(userName)
        self.addSubview(messageText)
        self.addSubview(timeLabel)
        
        self.userImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        self.userImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.userImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.userImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.userName.leftAnchor.constraint(equalTo: self.userImage.rightAnchor, constant: 10).isActive = true
        self.userName.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.userName.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.userName.heightAnchor.constraint(equalToConstant: 15).isActive = true

        
        self.messageText.leftAnchor.constraint(equalTo: self.userImage.rightAnchor, constant: 10).isActive = true
        self.messageText.topAnchor.constraint(equalTo: self.userName.bottomAnchor, constant: 8).isActive = true
        self.messageText.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.messageText.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
}

