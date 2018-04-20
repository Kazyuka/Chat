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
        
        User.getCurrentUserFromFirebase {[weak self] (us) in
            self?.user = us
            self?.configureView()
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
        
        let editProfileVC =  self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController") as! EditProfileController
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
}