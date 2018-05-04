//
//  ChatGrupController.swift
//  TestChat
//
//  Created by Руслан Казюка on 12.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MobileCoreServices
import AVKit

class ChatGrupController: UIViewController {
  
    @IBOutlet weak var collectionView: UICollectionView!

    var idUsersWhoGetMessage = [String]()
    var allIdUserInString = " "
    let cellIdentifier = "Cell"
    
    var arrayMessages = [GroupMessage]()
    var startingFrame: CGRect?
    var blackView: UIView?
    var imageUserForNavigationBar = UIImageView()
    
    var hieghtConstraitForKeyword: NSLayoutConstraint?
    var heightConstraintForConteinerViewForMessage: NSLayoutConstraint?
    var unicKyeForChatRoom: String?
    
    var room: RoomChat! {
        
        didSet {
            navigationItem.title = room?.groupName
        }
    }
    
    @objc func pressToGropImageRightButton() {
       let  detailGroupControllerFromRoomChat =  self.storyboard?.instantiateViewController(withIdentifier: "DetailGroupControllerFromRoomChat") as! DetailGroupControllerFromRoomChat
        detailGroupControllerFromRoomChat.unicKyeForChatRoom = unicKyeForChatRoom
       self.navigationController?.pushViewController(detailGroupControllerFromRoomChat, animated: true)
    }
    var databaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    
    var allUsers: [String]? {
        didSet {
            self.arrayMessages.removeAll()
        }
    }
    
    func addImageForNavigationButton() {
        if let im = room?.imageGroup {
            let url = NSURL.init(string: im)
            imageUserForNavigationBar.sd_setImage(with: url! as URL)
        } else {
            imageUserForNavigationBar.image = UIImage.init(named: "user.png")!
        }
        self.allUsers = room.usersChat
        self.unicKyeForChatRoom = room.groupUID
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(imageUserForNavigationBar.image?.resizeImage(targetSize: CGSize.init(width: 30, height: 30)), for: UIControlState.normal)
        button.addTarget(self, action: #selector(pressToGropImageRightButton), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    
    func observerMessages() {
        arrayMessages.removeAll()
        let refChatRom = Database.database().reference().child("chat-romm").child(unicKyeForChatRoom!).child("messages")
        refChatRom.observe(.childAdded) { (snap) in
            
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            let g = GroupMessage.init(dic: dic)
            self.arrayMessages.append(g)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.collectionView?.reloadData()
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInputTextField()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        self.collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatGroupCell.self, forCellWithReuseIdentifier: cellIdentifier)
        addImageForNavigationButton()
        self.observerMessages()
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNotification()
        self.navigationController?.navigationBar.backItem?.title = " "
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func sendMassegaButtonTapped() {
        
        let ref = databaseRef.child("chat-romm").child(unicKyeForChatRoom!).child("messages").childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let time = Int(NSDate().timeIntervalSince1970)
        let text = textFieldInputTex.text!
        
        let value = ["text": text,"fromId" : fromId, "time": time] as [String : Any]
        ref.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                return
            }
            
            let refLastMessage = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!)
            refLastMessage.updateChildValues(["last-message": text])
        }
        
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
        view.endEditing(true)
        sendButton.isEnabled = false
        textFieldInputTex.text = "Your message"
        textFieldInputTex.textColor = UIColor.lightGray
    }
    
    func camera() {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.mediaTypes = [kUTTypeMovie as NSString as String]
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        self.present(myPickerController, animated: true, completion: nil)
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
        myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Make Photo".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose Photo".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Make Video".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photo()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose Video".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
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
    
    @objc func sendImageMassegaButtonTapped () {
        showActionSheet()
    }
    var  textInsideTextFeld: String? {
        
        didSet {
            if textInsideTextFeld != "" {
                sendButton.isEnabled = true
            } else {
                sendButton.isEnabled = false
            }
        }
    }
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"sendMess"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentMode = .scaleAspectFill
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendMassegaButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var sendImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"plus"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentMode = .scaleAspectFill
        button.frame = CGRect(x: 160, y: 100, width: 30, height: 30)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sendImageMassegaButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let massegeImputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textFieldInputTex: UITextView = {
        let text = UITextView()
        text.layer.cornerRadius = 18
        text.layer.masksToBounds = true
        text.layer.borderWidth = 1.0
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.isScrollEnabled = false
        text.text = "Message"
        text.textAlignment = .right
        text.textColor = UIColor.lightGray
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let separateView:  UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupInputTextField() {
        
        self.view.addSubview(massegeImputContainerView)
        massegeImputContainerView.addSubview(separateView)
        
        hieghtConstraitForKeyword = self.massegeImputContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        hieghtConstraitForKeyword!.isActive = true
        self.massegeImputContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        heightConstraintForConteinerViewForMessage = self.massegeImputContainerView.heightAnchor.constraint(equalToConstant: 40)
        heightConstraintForConteinerViewForMessage!.isActive = true
        self.massegeImputContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        textFieldInputTex.delegate = self
        textFieldInputTex.becomeFirstResponder()
        self.massegeImputContainerView.addSubview(textFieldInputTex)
        self.massegeImputContainerView.addSubview(sendButton)
        self.massegeImputContainerView.addSubview(sendImageButton)
        
        self.sendButton.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 4).isActive = true
        self.sendButton.rightAnchor.constraint(equalTo: self.massegeImputContainerView.rightAnchor, constant: -17).isActive = true
        self.sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.sendImageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.sendImageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.sendImageButton.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 4).isActive = true
        self.sendImageButton.rightAnchor.constraint(equalTo: self.textFieldInputTex.leftAnchor, constant: -20).isActive = true
        self.sendImageButton.leftAnchor.constraint(equalTo: self.massegeImputContainerView.leftAnchor, constant: 15).isActive = true
        
        self.textFieldInputTex.bottomAnchor.constraint(equalTo: self.massegeImputContainerView.bottomAnchor, constant: -2).isActive = true
        self.textFieldInputTex.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 1).isActive = true
        self.textFieldInputTex.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor, constant: -13).isActive = true
        
        self.separateView.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor).isActive = true
        self.separateView.widthAnchor.constraint(equalTo: self.massegeImputContainerView.widthAnchor).isActive = true
        self.separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func setUpNotification()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatGrupController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatGrupController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        hieghtConstraitForKeyword?.constant = 0
        let userInfo = notification.userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: {
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        hieghtConstraitForKeyword?.constant = -keyboardHeight
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: keyboardHeight + 60, right: 0)
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: {
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension ChatGrupController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMessages.count
    }
    
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ChatGroupCell
        cell?.delegate = self
        cell?.messageGroup = arrayMessages[indexPath.item]
        return cell!
    }
}

extension ChatGrupController: UICollectionViewDelegateFlowLayout {
    
    public  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = arrayMessages[indexPath.item].text
        
        if let messageText = text {
            return CGSize(width: UIScreen.main.bounds.width, height: (messageText.height(withConstrainedWidth: 200, font: UIFont.boldSystemFont(ofSize: 14))) + 20)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: 200 )
    }
}
extension ChatGrupController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        heightConstraintForConteinerViewForMessage?.constant = newFrame.size.height + 10
        textInsideTextFeld = textView.text
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Message" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Message"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ChatGrupController: ChatCollectionViewCellDelegate {
    
    func playVideo(video: NSURL) {
        let player = AVPlayer(url: video as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func tapToImage(gesture: UIImageView) {
        
        startingFrame = gesture.superview?.convert(gesture.frame, to: nil)
        let zoomingImage = UIImageView(frame: startingFrame!)
        zoomingImage.image = gesture.image
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapToImageZoomBack(_:)))
        zoomingImage.isUserInteractionEnabled = true
        gesture.numberOfTapsRequired = 1
        zoomingImage.addGestureRecognizer(gesture)
        
        if let keyWindow =  UIApplication.shared.keyWindow {
            
            blackView = UIView(frame: keyWindow.frame)
            blackView?.backgroundColor = UIColor.black
            blackView?.alpha = 0
            keyWindow.addSubview(blackView!)
            
            keyWindow.addSubview(zoomingImage)
            
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
                self.blackView?.alpha = 1
                zoomingImage.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: self.startingFrame!.height)
                zoomingImage.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc func tapToImageZoomBack(_ sender: UITapGestureRecognizer) {
        
        if let zoomOut = sender.view {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.blackView?.alpha = 0
                zoomOut.frame = self.startingFrame!
            }, completion: { (value) in
                zoomOut.removeFromSuperview()
            })
        }
    }
}


extension ChatGrupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            videoSelectedForInfo(url: videoUrl)
        } else {
            imageSelectedForInfo(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func videoSelectedForInfo(url: NSURL) {
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask =  Storage.storage().reference().child("message_movies").child(fileName).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                return
            }
            
            if let storageUrlVideo = metadata?.downloadURL()?.absoluteString {
                let url = URL.init(string: storageUrlVideo)
                let image = self.makeUIImageFromUrl(url: url as! NSURL)
                
                self.uploadImageToFirebase(image: image!, completion: { (storageUrl) in
                    self.saveVideoFileInFirebase(url: storageUrlVideo, urlPhoto: storageUrl)
                })
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let complectedUnitCount = snapshot.progress?.completedUnitCount {
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            
        }
    }
    
    private func makeUIImageFromUrl(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let inmageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            
            let cgImage =  try inmageGenerator.copyCGImage(at: CMTime.init(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    private func imageSelectedForInfo(info: [String: AnyObject]) {
        var selectedImagefromPisker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagefromPisker = editedImage
            
        } else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImagefromPisker = originalImage
        }
        if let selectedImage = selectedImagefromPisker {
            uploadImageToFirebase(image: selectedImage, completion: { (urlImage) in
                self.savePhotoFileInFirebase(url: urlImage)
            })
        }
    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (String) -> ()) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child("\(imageName).png")
        if let uploadData = UIImageJPEGRepresentation(image, 0.3) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if err != nil{
                    return
                }
                if let urlString = metadata?.downloadURL()?.absoluteString {
                    completion(urlString)
                }
            })
        }
    }
    
    private func savePhotoFileInFirebase(url: String) {
        
        let ref = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("messages").childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let time = Int(NSDate().timeIntervalSince1970)
        
        let value = ["imageUrl": url,"fromId" : fromId, "time": time] as [String : Any]
        ref.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                return
            }
        }
    }
    private func saveVideoFileInFirebase(url: String, urlPhoto: String) {
        
        let ref = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("messages").childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let time = Int(NSDate().timeIntervalSince1970)
        
        let value = ["imageUrl": urlPhoto,"fromId" : fromId, "time": time,  "videoUrl": url] as [String : Any]
        ref.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                return
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
