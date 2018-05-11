//
//  RegisterView.swift
//  TestChat
//
//  Created by Руслан Казюка on 27.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class RegisterController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordAgTextField: UITextField!
    
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "SignUp".localized
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        registerButton.layer.cornerRadius = 24
        registerButton.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        firstNameTextField.changeColor(textForPlaceHoder: "First name".localized, size: 16.0)
        lastNameTextField.changeColor(textForPlaceHoder: "Last name".localized, size: 16.0)
        emailTextField.changeColor(textForPlaceHoder: "Email".localized, size: 16.0)
        passwordTextField.changeColor(textForPlaceHoder: "Password".localized, size: 16.0)
        passwordAgTextField.changeColor(textForPlaceHoder: "Password again".localized, size: 16.0)
        registerButton.setTitle("CONTINUE".localized, for: .normal)
        
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        self.view.addSubview(activityIndicator!)
        
        checkTypeDevice()
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
   
    @IBAction func registerButtoClick(_ sender: Any) {
        comparePassword()
    }
    
    private func checkTypeDevice() {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.scrollView.isScrollEnabled = false
            self.scrollView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0)
            self.scrollView.scrollIndicatorInsets =  UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            self.scrollView.isScrollEnabled = true
            self.scrollView.contentInset =  UIEdgeInsetsMake(0, 0, 200, 0)
          
            self.scrollView.scrollIndicatorInsets =  UIEdgeInsetsMake(0, 0, 200, 0)
        }
    }
    
    private func comparePassword () {
        
        if passwordTextField.text != passwordAgTextField.text {
            self.present(self.allertControllerWithOneButton(message: "Passwords do not match".localized), animated: true, completion: nil)
        } else if lastNameTextField.text == "" {
            self.present(self.allertControllerWithOneButton(message: "Field name must be filled in".localized), animated: true, completion: nil)
        } else {
            registerUser()
        }
    }
    
    private func registerUser() {
        activityIndicator?.startAnimating()
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = firstNameTextField.text, let lastName = lastNameTextField.text else {
            self.activityIndicator?.stopAnimating()
            self.present(self.allertControllerWithOneButton(message: "Fill in all the fields!!".localized), animated: true, completion: nil)
            return  }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.activityIndicator?.stopAnimating()
                self.present(self.allertControllerWithOneButton(message: error!.localizedDescription), animated: true, completion: nil)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            let value = ["name": name, "email": email,"lastName" : lastName, "aboutMe": "", "uid": uid, "deviceId": AppDelegate.DEVICEID]
            self.registerUserIntoFirebase(uid: uid, value: value as [String : AnyObject] )
        }
    }
    
    private func registerUserIntoFirebase(uid: String, value: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let user = ref.child("users").child(uid)
        user.updateChildValues(value, withCompletionBlock: { (err, dref) in
            if err != nil {
                self.activityIndicator?.stopAnimating()
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            self.activityIndicator?.stopAnimating()
            let chatVC =  self.storyboard?.instantiateViewController(withIdentifier: "TabController") as! TabController
            self.navigationController?.pushViewController(chatVC, animated: true)
        })
    }
}
