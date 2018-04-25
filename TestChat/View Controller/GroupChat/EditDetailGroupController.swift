//
//  EditDetailGroupViewViewController.swift
//  TestChat
//
//  Created by Руслан Казюка on 20.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

 protocol EditDetailGroupControllerDelegate: class {
      func getEditedGroup(group: Group)
}

class EditDetailGroupController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var imageGroup: UIImageView!
    weak var delegate: EditDetailGroupControllerDelegate?
    
    var group: Group?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.title = "save".localized
        backButton.title = "Back".localized
        imagePicker.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImage(_:)))
        gesture.numberOfTapsRequired = 1
        imageGroup.isUserInteractionEnabled = true
        imageGroup.addGestureRecognizer(gesture)
        groupNameTextField.text = group?.nameGroup
        imageGroup.image = group?.image
    }
  
    @IBAction func backButtonClick(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        
        let group = Group.init(nameGroup: groupNameTextField.text, image: imageGroup.image, typeGroup: false)
        self.dismiss(animated: true) {
            self.delegate?.getEditedGroup(group: group)
        }
    }
    
    @objc func tapToImage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension EditDetailGroupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImagefromPisker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagefromPisker = editedImage
            
        } else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImagefromPisker = originalImage
        }
        if let selectedImage = selectedImagefromPisker {
            imageGroup.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
