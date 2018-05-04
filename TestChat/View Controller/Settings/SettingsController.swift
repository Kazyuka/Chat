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
    
    
    var selectedLenguage: String?
    
    var currentLenguage: String = " "
    
    private var chatController: ChatController {
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        navigationItem.title = "Settings"
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutButton.setTitle("LogOut".localized, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        currentLenguage = Bundle.main.preferredLocalizations.first!
        
        User.getCurrentUserFromFirebase { (user) in
            self.emailTextView.text = user.email
            self.email = self.emailTextView.text!
        }
        checkLenguage()
        
        logOutButton.layer.cornerRadius = 24
        logOutButton.clipsToBounds = true
        logOutButton.setTitle("LOGOUT", for: .normal)
    }

    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func checkLenguage() {
        
        if Locale.preferredLanguages[0] == "en" {
            selectedLenguage = "en"
        } else {
            selectedLenguage = "ua"
        }
    }
    
    @IBAction func logOutButtonClick(_ sender: Any) {
        do {
            try   Auth.auth().signOut()
        } catch let err {
            print(err)
        }
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.messagseController = chatController
        self.navigationController?.pushViewController(loginVC, animated: true)
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


