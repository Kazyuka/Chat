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

class GroupCreateController: UIViewController {
    
    @IBOutlet weak var photoImageGroup: UIImageView!
    @IBOutlet weak var nameTextView: UITextView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImageInsideCell(_:)))
        gesture.numberOfTapsRequired = 1
        photoImageGroup.isUserInteractionEnabled = true
        photoImageGroup.addGestureRecognizer(gesture)
    }
    
    @objc func tapToImageInsideCell(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func saveGroup(_ sender: Any) {
        
        if photoImageGroup.image == nil || nameTextView.text == "" {
            self.present(self.allertControllerWithOneButton(message: "Выберите фото для группового чата или заполните название"), animated: true, completion: nil)
        } else {
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("group_images").child("\(imageName).png")
            let uploadData = UIImagePNGRepresentation(self.photoImageGroup.image!)
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
                if err != nil{
                    
                    self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                    return
                }
                if let meta = metadata?.downloadURL()?.absoluteString {
                    let uid = Auth.auth().currentUser?.uid
                    let value = ["nameGroup": self.nameTextView.text, "groupImageUrl" : meta, "fromId": uid,"toId": "", "text": ""] as [String : Any]
                    self.registerGroupIntoFirebase(value: value as [String : AnyObject] )
                }
            })
        }
    }
    private func registerGroupIntoFirebase(value: [String: AnyObject]) {
        
        let ref = Database.database().reference().child("group").child("group-messages")
        let childRef  = ref.childByAutoId()
      
        
        childRef.updateChildValues(value) { (err, snap) in
            if err != nil {
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
             self.navigationController?.popViewController(animated: true)
        }
        
        /*childRef.updateChildValues(value, withCompletionBlock: { (err, dref) in
            if err != nil {
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            let messageRef = Database.database().reference().child("message-group").child(childRef.key)
            let uid = Auth.auth().currentUser?.uid
            let v = ["text": " ","fromId" : uid, "toId": " "] as [String : Any]
            messageRef.updateChildValues(v)
            self.navigationController?.popViewController(animated: true)
        })*/
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
