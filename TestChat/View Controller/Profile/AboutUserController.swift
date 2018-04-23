//
//  AboutMeController.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

class AboutUserController: UIViewController {

    @IBOutlet weak var texViewAboutMe: UITextView!
 
    weak var delegate: EditProfileControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.texViewAboutMe.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
         delegate?.getAboutMeText(text: texViewAboutMe.text)
    }
}
