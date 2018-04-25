//
//  ResetPasswordController.swift
//  TestChat
//
//  Created by Руслан Казюка on 16.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        resetPasswordButton.setTitle("ResetPassword", for: .normal)
        backButton.setTitle("Back", for: .normal)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonClick(_ sender: Any) {
        
        
        Auth.auth().sendPasswordReset(withEmail: emailField.text!) { (error) in
            if error != nil {
                self.present(self.allertControllerWithOneButton(message: error!.localizedDescription), animated: true, completion: nil)
            }
            self.present(self.allertControllerWithOneButton(message: "Для замены пароля проверьте электорнную почту!"), animated: true, completion: nil)
        }
    }
}


