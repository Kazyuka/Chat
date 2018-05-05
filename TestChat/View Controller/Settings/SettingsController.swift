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
    
    @IBOutlet weak var englishFlagImage: UIImageView!
    
    @IBOutlet weak var russianFlagImage: UIImageView!
    
    @IBOutlet weak var mainSettingsLabel: UILabel!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var passwordAgainLabel: UILabel!
    
    private var email: String!
    
    private var language = Languages()
    
    private var chatController: ChatController {
        let messageVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatController") as! ChatController
        return messageVc
    }
    
    @IBAction func russiaButtonClick(_ sender: Any) {
        russianFlagImage.isHidden = false
        englishFlagImage.isHidden = true
        language.selectedLanguage = "ru"
    }
    @IBAction func englishButtonClick(_ sender: Any) {
        russianFlagImage.isHidden = true
        englishFlagImage.isHidden = false
        language.selectedLanguage = "en"
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        englishFlagImage.isHidden = true
        russianFlagImage.isHidden = true
        navigationItem.title = "Settings".localized
        mainSettingsLabel.text = "Main Settings".localized
        emailLabel.text = "Email".localized
        passwordLabel.text = "Password".localized
        passwordAgainLabel.text = "Password again".localized
        languageLabel.text = "Language".localized
        logOutButton.setTitle("LOGOUT".localized, for: .normal)
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        checkLenguage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutButton.setTitle("LogOut".localized, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        User.getCurrentUserFromFirebase { (user) in
            self.emailTextView.text = user.email
            self.email = self.emailTextView.text!
        }
    
        logOutButton.layer.cornerRadius = 24
        logOutButton.clipsToBounds = true
        logOutButton.setTitle("LOGOUT", for: .normal)
    }

    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
   private func checkLenguage() {
        
        language.checkLanguage()
    
        if language.currentLanguage == "en" {
            englishFlagImage.isHidden = false
        } else {
            russianFlagImage.isHidden = false
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
        
        language.changeLanguage()
        
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

struct Languages {
    
    var currentLanguage: String {
        return language
    }
    
    private var language: String = Locale.preferredLanguages[0]
    
    var selectedLanguage: String {
        
        get {
            return language
        }
        set(newLanguage) {
            language = newLanguage
        }
    }
    
     mutating func checkLanguage() {
        if Locale.preferredLanguages[0] == "en" {
            language = "en"
        } else {
            language = "ru"
        }
    }
    
    nonmutating func changeLanguage() {
        
        if currentLanguage == "en" {
            Language.language = Language.english
        } else {
            Language.language = Language.russia
        }
    }
}


