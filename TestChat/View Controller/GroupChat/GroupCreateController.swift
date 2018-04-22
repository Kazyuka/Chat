//
//  GroupCreateController.swift
//  TestChat
//
//  Created by Руслан Казюка on 17.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

protocol GroupCreateControllerDelegate: class {
    func goToDetailCreateGroup(g: Group)
}
class GroupCreateController: UIViewController {
    
    @IBOutlet weak var photoImageGroup: UIImageView!
    @IBOutlet weak var nameTextView: UITextView!
    
    var imageGroup = UIImage()
    let imagePicker = UIImagePickerController()
    weak var delegate: GroupCreateControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImageInsideCell(_:)))
        gesture.numberOfTapsRequired = 1
        photoImageGroup.isUserInteractionEnabled = true
        photoImageGroup.addGestureRecognizer(gesture)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func tapToImageInsideCell(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveGroup(_ sender: Any) {
        
        if photoImageGroup.image == nil || nameTextView.text == "" {
            self.present(self.allertControllerWithOneButton(message: "Выберите фото для группового чата или заполните название"), animated: true, completion: nil)
        } else {
            
            let group = Group(nameGroup: self.nameTextView.text, image: self.photoImageGroup.image!, typeGroup: false)
            
            self.dismiss(animated: true, completion: {
                self.delegate?.goToDetailCreateGroup(g: group)
            })
        }
    }
}

extension GroupCreateController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImagefromPisker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagefromPisker = editedImage
            
        } else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImagefromPisker = originalImage
        }
        if let selectedImage = selectedImagefromPisker {
           photoImageGroup.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

struct Group {
    var nameGroup: String?
    var image: UIImage?
    var typeGroup: Bool?
}
