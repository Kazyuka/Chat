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
    
    var progressHUD: ProgressHUD? = nil
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
        
        progressHUD = ProgressHUD(text: "Please Wait")
        progressHUD?.hide()
        self.view.addSubview(progressHUD!)
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

class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .dark)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndictor)
        vibrancyView.contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 2.3
            let height: CGFloat = 50.0
            
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2, y: superview.frame.height / 2 - height / 2, width: width, height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame =  CGRect(x: 5, y: height / 2 - activityIndicatorSize / 2, width: activityIndicatorSize, height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center

            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: width - activityIndicatorSize - 15, height: height)
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}

struct Group {
    var nameGroup: String?
    var image: UIImage?
    var typeGroup: Bool?
}
