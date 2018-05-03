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
import MobileCoreServices
import AVKit

protocol GroupCreateControllerDelegate: class {
    func goToDetailCreateGroup(g: Group)
}
class GroupCreateController: UIViewController {
    
    @IBOutlet weak var photoImageGroup: UIImageView!
    @IBOutlet weak var nameGroupTextField: UITextField!
    
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
        photoImageGroup.image = UIImage.init(named: "groupImage.png")
        photoImageGroup.setRounded()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        nameGroupTextField.changeColor(textForPlaceHoder: "Some Name", size: 17.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationItem.title = "Create Group"
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func tapToImageInsideCell(_ sender: UITapGestureRecognizer) {
        showActionSheet()
    }
    
    func photo() {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func photoLibrary() {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.mediaTypes = [kUTTypeImage as String]
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Make Photo".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photo()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose Photo".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
     

        actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.cancel, handler: nil))
        
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    

    @IBAction func saveGroup(_ sender: Any) {
        
        if  nameGroupTextField.text == "" {
            self.present(self.allertControllerWithOneButton(message: "Заполните название"), animated: true, completion: nil)
        } else {
            let group = Group(nameGroup: self.nameGroupTextField.text, image: self.photoImageGroup.image!, typeGroup: false)
            
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
