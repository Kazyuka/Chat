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
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var editBaButtonItem: UIBarButtonItem!
    var user: User?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Profile".localized
        editBaButtonItem.title = "Edit".localized
        aboutMeLabel.text = "About Me".localized
        getDataWithFireBase()
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.view.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
    }
    

    func getDataWithFireBase() {
        
        User.getCurrentUserFromFirebase {[weak self] (us) in
            self?.user = us
            self?.configureView()
        }
    }
    
    func configureView() {
        userImage.setRounded()
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
