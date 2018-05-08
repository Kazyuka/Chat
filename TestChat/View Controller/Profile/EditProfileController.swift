//
//  EditProfileController.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

@objc protocol EditProfileControllerDelegate {
    func getAboutMeText(text: String)
}

class EditProfileController: UIViewController {

    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    var aboutMeText = ""
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameLabel.text = "First name".localized
        lastNameLabel.text = "Last name".localized
        aboutMeLabel.text = "About Me".localized
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.sendImageMassegaButtonTapped(_:)))
        userImageView.addGestureRecognizer(tap)
        userImageView.isUserInteractionEnabled = true
        getDataFromFirebase()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Edit Profile".localized
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backItem?.title = ""
        userImageView.setRounded()
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func aboutMeButtonClick(_ sender: Any) {
        
        let abouttProfileVC =  self.storyboard?.instantiateViewController(withIdentifier: "AboutUserController") as! AboutUserController
        abouttProfileVC.delegate = self
        abouttProfileVC.aboutMeText = aboutMeText
        self.navigationController?.pushViewController(abouttProfileVC, animated: true)
    }
    func getDataFromFirebase() {
        
        User.getCurrentUserFromFirebase {[weak self] (us) in
            self?.user = us
            self?.setUpView()
        }
    }
    
    func setUpView() {
        
        firstNameTextField.text = self.user?.name
        lastNameTextField.text = self.user?.lastName
        if let ab = self.user?.aboutMe {
            aboutMeText = ab
        }
        if let im = user?.imageProfile {
            let url = NSURL.init(string: im)
            self.userImageView.sd_setImage(with: url! as URL)
        } else {
            
            self.userImageView.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "userL.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
            }, completed: nil)
        }
    }

    @IBAction func saveButtonClick(_ sender: Any) {
    
        
        if lastNameTextField.text == "" || firstNameTextField.text == "" {
            self.present(self.allertControllerWithOneButton(message: "Заполните пустые поля"), animated: true, completion: nil)
        } else {
            
            if let lastN = lastNameTextField.text, let firstN  = firstNameTextField.text {
                let value = ["aboutMe": aboutMeText, "email": self.user?.email, "name": firstN, "lastName": lastN, "uid": self.user?.uid ]
                self.updateUserDataInFirebase(data: value as Dictionary<String, AnyObject>)
            }
        }
    }
    
    @objc func sendImageMassegaButtonTapped(_ sender: UITapGestureRecognizer) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension EditProfileController: EditProfileControllerDelegate {
    func getAboutMeText(text: String) {
        aboutMeText = text
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImagefromPisker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagefromPisker = editedImage
            
        } else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImagefromPisker = originalImage
        }
        if let selectedImage = selectedImagefromPisker {
            userImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func updateUserDataInFirebase(data: Dictionary <String, AnyObject>) {
        var value = data
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        if let uploadData = UIImageJPEGRepresentation(userImageView.image!, 0.3) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if err != nil{
                    return
                }
                if let urlString = metadata?.downloadURL()?.absoluteString {
                    
                    value["profileImageUrl"] = urlString as AnyObject
                    
                    let ref = Database.database().reference().child("users").child(self.user!.uid!)
                    ref.updateChildValues(value)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
