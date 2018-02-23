//
//  LoginViewController+Actions.swift
//  TestChat
//
//  Created by Руслан Казюка on 15.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

extension LoginViewController {
    
    @objc func tapToImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func changeSegmentState() {
        
        let title = loginSegmentViewControl.titleForSegment(at: loginSegmentViewControl.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        inputConteinerViewHeightConstr?.constant = loginSegmentViewControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightConstr?.isActive = false
        nameTextFieldHeightConstr = userNameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier:loginSegmentViewControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightConstr?.isActive = true
        
        passwordTextFieldHeightConstr?.isActive = false
        passwordTextFieldHeightConstr = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginSegmentViewControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightConstr?.isActive = true
        
        emailTextFieldHeightConstr?.isActive = false
        emailTextFieldHeightConstr = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginSegmentViewControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightConstr?.isActive = true
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func registerNewUser() {
        loginSegmentViewControl.selectedSegmentIndex == 0 ? loginUser() : registerUser()
    }
    
    func loginUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return  }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            
            if err != nil {
                return
            }
            self.messagseController?.isUserLogin()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func registerUser() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = userNameTextField.text else { return  }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            print(error?.localizedDescription)
            if error != nil {
                return
            }
            
            guard let uid = user?.uid else { return }
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            let uploadData = UIImagePNGRepresentation(self.imageTopView.image!)
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
                if err != nil{
                    return
                }
                if let meta = metadata?.downloadURL()?.absoluteString {
                    let value = ["name": name, "email": email,"profileImageUrl" : meta]
                    self.registerUserIntoFirebase(uid: uid, value: value as [String : AnyObject] )
                }
            })
        }
    }
    
    private func registerUserIntoFirebase(uid: String, value: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let user = ref.child("users").child(uid)
        user.updateChildValues(value, withCompletionBlock: { (err, dref) in
            if err != nil {
                return
            }
            let user = User(dic: value)
            self.messagseController?.setupNAvigationBar(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImagefromPisker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagefromPisker = editedImage
            
        } else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImagefromPisker = originalImage
        }
        if let selectedImage = selectedImagefromPisker {
            imageTopView.image = selectedImage
            dismiss(animated: true, completion: nil)
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
