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

    @IBOutlet weak var topContainerConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkTypeDevice()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Forgot Password".localized
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        resetPasswordButton.layer.cornerRadius = 24
        resetPasswordButton.clipsToBounds = true
        resetPasswordButton.setTitle("SEND PASSWORD".localized, for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        emailField.changeColor(textForPlaceHoder: "Email".localized, size: 16.0)
    }
    
    private func checkTypeDevice() {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            topContainerConstraint.constant = 250
        } else {
           topContainerConstraint.constant = 19
        }
    }
    
    @IBAction func resetButtonClick(_ sender: Any) {
        
        Auth.auth().sendPasswordReset(withEmail: emailField.text!) { (error) in
            if error != nil {
                self.present(self.allertControllerWithOneButton(message: error!.localizedDescription), animated: true, completion: nil)
            }
            self.present(self.allertControllerWithOneButton(message: "Для замены пароля проверьте электорнную почту!"), animated: true, completion: nil)
        }
    }
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


