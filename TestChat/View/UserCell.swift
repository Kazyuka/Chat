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
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var user: User! {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        userPhoto.setRounded()
        if let im = user.imageProfile {
            let url = NSURL.init(string: im)
            self.userPhoto.sd_setImage(with: url! as URL)
        } else {
            
            self.userPhoto.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "user.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
            }, completed: nil)
        }
        
        self.userName.text = user.name + " " + user.lastName!
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        userPhoto.setRounded()
    }
}

