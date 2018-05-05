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
    @IBOutlet weak var aboutMelabel: UILabel!
    
    var user: User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
         aboutMelabel.text! = "About Me".localized
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        self.view.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func configureView() {
        userImage.setRounded()
        if let im = user?.imageProfile {
            let url = NSURL.init(string: im)
            self.userImage.sd_setImage(with: url! as URL)
            
        } else {
            self.userImage.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "userImage.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
            }, completed: nil)
        }
        userNameLabel.text = user?.name
        abouUserText.text = user?.aboutMe
    }
}
