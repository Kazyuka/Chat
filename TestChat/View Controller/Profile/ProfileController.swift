//
//  ProfileController.swift
//  TestChat
//
//  Created by Руслан Казюка on 17.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileController: UIViewController {

    @IBOutlet weak var aboutMETextView: UITextView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var user: User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Profile"
        getDataWithFireBase()
        configureView()
    }
    

    func getDataWithFireBase() {
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snap) in
                
                if let user = snap.value as? [String: AnyObject] {
                    self.user = User.init(dic: user)
                    self.configureView()
                }
            })
        }
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
        aboutMETextView.text = user?.aboutMe
    }

    @IBAction func editProfileButtonClick(_ sender: Any) {
        
    }
}
