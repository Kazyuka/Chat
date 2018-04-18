//
//  OtherProfileController.swift
//  TestChat
//
//  Created by Руслан Казюка on 17.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OtherProfileController: UIViewController {

    @IBOutlet weak var abouUserText: UITextView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!

    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
  
    
    func configureView() {
        
        if let im = user?.imageProfile {
            let url = NSURL.init(string: im)
            self.userImage.sd_setImage(with: url! as URL)
            
        } else {
            self.userImage.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "user.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
            }, completed: nil)
        }
        userNameLabel.text = user?.name
        abouUserText.text = user?.aboutMe
    }
}
