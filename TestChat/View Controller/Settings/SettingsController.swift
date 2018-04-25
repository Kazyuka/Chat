//
//  SettingsController.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

class SettingsController: UIViewController {
    
    @IBOutlet weak var savebutt: UIBarButtonItem!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var emailTextView: UITextField!
    
    
    @IBOutlet weak var passworfTextField: UITextField!
    
    @IBOutlet weak var repeatPassword: UITextField!
    
    private var email: String!
    
    var currentLenguage: String = " "
    
    private var messageVC: ChatController {
        let messageVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatController") as! ChatController
        return messageVc
    }
    
    var langueages = ["English", "Русский"]
    
    @IBAction func russiaButtonClick(_ sender: Any) {
         Language.language = Language.russia
    }
    @IBAction func englishButtonClick(_ sender: Any) {
        Language.language = Language.english
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings".localized
        logOutButton.setTitle("LogOut".localized, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        currentLenguage = Bundle.main.preferredLocalizations.first!
        
        savebutt.title! = "save".localized
        User.getCurrentUserFromFirebase { (user) in
            self.emailTextView.text = user.email
            self.email = self.emailTextView.text!
        }
    }

    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func logOutButtonClick(_ sender: Any) {
        
        do {
            try   Auth.auth().signOut()
        } catch let err {
            print(err)
        }
        
        messageVC.Logout()
        //self.present(loginVC, animated: true, completion: nil)
    }
    @IBAction func saveButtonClick(_ sender: Any) {
       
        if self.email != emailTextView.text {
            changeEmail()
            changePassword()
        } else {
            changePassword()
        }
    }
    
    private func changeEmail() {
        
        let email = emailTextView.text
        let user = Auth.auth().currentUser
        
        user?.updateEmail(to: email!, completion: { (err) in
            
            if err != nil {
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            let ref = Database.database().reference().child("users").child(user!.uid)
            ref.updateChildValues(["email": email])
        })
    }
    
    private func changePassword() {
        
        let password = passworfTextField.text
        let rPassword = passworfTextField.text
        let user = Auth.auth().currentUser
        
        if password == "" || rPassword == "" {
            return
        } else if  password != rPassword {
            self.present(self.allertControllerWithOneButton(message: "Пароли не совпадают"), animated: true, completion: nil)
        } else {
            user?.updatePassword(to:password!, completion: { (err) in
                if err != nil {
                    self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                    return
                }
            })
        }
    }
}


