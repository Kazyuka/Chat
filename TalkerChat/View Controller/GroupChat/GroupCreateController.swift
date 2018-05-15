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
import NVActivityIndicatorView

protocol GroupCreateControllerDelegate: class {
    func goToDetailCreateGroup(g: Group)
}

protocol DissmisGroupCreteDelegate: class {
    func dissmissGroupCreteView(room: RoomChat)
}


class GroupCreateController: UIViewController {
    
    @IBOutlet weak var photoImageGroup: UIImageView!
    @IBOutlet weak var nameGroupTextField: UITextField!
    @IBOutlet weak var groupNameLabel: UILabel!
    var activityIndicator: NVActivityIndicatorView?
    
    var imageGroup = UIImage()
    let imagePicker = UIImagePickerController()
    var keyChat: String?
    weak var delegate: GroupCreateControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImageInsideCell(_:)))
        gesture.numberOfTapsRequired = 1
        photoImageGroup.isUserInteractionEnabled = true
        photoImageGroup.addGestureRecognizer(gesture)
        photoImageGroup.image = UIImage.init(named: "groupL.png")
        photoImageGroup.setRounded()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        nameGroupTextField.changeColor(textForPlaceHoder: "Some Name".localized, size: 17.0)
        self.navigationItem.title = "Create Group".localized
        groupNameLabel.text = "Group Name".localized
        
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        activityIndicator?.center  = self.view.center
        self.view.addSubview(activityIndicator!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backItem?.title = ""
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
            registerGroupIntoFirebase()
        }
    }
    
    
    private func registerGroupIntoFirebase() {
        self.activityIndicator?.startAnimating()
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("group_images").child("\(imageName).png")
        let uploadData = UIImagePNGRepresentation(photoImageGroup.image!)
        keyChat = Database.database().reference().child("chat-romm").childByAutoId().key
        storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
            if err != nil{
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            if let meta = metadata?.downloadURL()?.absoluteString {
                let uid = Auth.auth().currentUser?.uid
                let value = ["nameGroup": self.nameGroupTextField.text, "groupImageUrl" : meta, "ovnerGroup": uid, "isSingle": 0, "uidGroup": self.keyChat!] as [String : Any]
                let ref = Database.database().reference().child("chat-romm").child(self.keyChat!)
                ref.updateChildValues(value, withCompletionBlock: { (err, snap) in
                    
                    if err != nil {
                        return
                    }
                    
                    let ref2 = Database.database().reference().child("chat-romm").child(self.keyChat!).child("users").childByAutoId()
                    ref2.updateChildValues(["toId" : Auth.auth().currentUser?.uid])
                    
                    self.getChatRommFromFirebaseDatabase()
                })
            }
        })
    }
    
    
    func getChatRommFromFirebaseDatabase() {
        
        let refChatRom = Database.database().reference().child("chat-romm").child(self.keyChat!)
        refChatRom.observeSingleEvent(of: .value) { (snap) in
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            self.activityIndicator?.stopAnimating()
            let roomChat = RoomChat.init(dic: dic)
            let detailGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailGroupController") as! DetailGroupController
            detailGroupVC.roomChat = roomChat
            self.navigationController?.pushViewController(detailGroupVC, animated: true)
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
    var idGroup: String?
    var nameGroup: String?
    var image: UIImage?
    var typeGroup: Bool?
}

