

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MobileCoreServices
import AVKit
import NVActivityIndicatorView
import Alamofire

class ChatSingleController: UIViewController {
   
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    var arrayMessages = [Message]()
    var startingFrame: CGRect?
    var blackView: UIView?
    var imageUserForNavigationBar = UIImage()
    var hieghtConstraitForKeyword: NSLayoutConstraint?
    var heightConstraintForConteinerViewForMessage: NSLayoutConstraint?
    var unicKyeForChatRoom: String?
    var activityIndicator: NVActivityIndicatorView?
    var grouChat = [RoomChat]()
    var isPushingNitification: Bool = false
    
    weak var delegate: ChatControllerDelegate?
    
    var databaseRef: DatabaseReference! {
        return Database.database().reference()
    }

    var user: User? {
        
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    func addImageForNavigationButton() {
        
        DispatchQueue.global().async {
            if let im = self.user?.imageProfile {
                let data = NSData.init(contentsOf: URL.init(string: im)!)
                if data != nil {
                    self.imageUserForNavigationBar = UIImage(data: data as! Data)!
                }
                
            } else {
                self.imageUserForNavigationBar = UIImage.init(named: "userImage.png")!
            }
            
            DispatchQueue.main.async(execute: {
                let viewImage = UIView()
                let imageView  = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(self.pressToUserImageRightButton))
                gesture.numberOfTapsRequired = 1
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(gesture)
                imageView.contentMode = .scaleAspectFill
                imageView.setRounded()
                imageView.image = self.imageUserForNavigationBar
                viewImage.addSubview(imageView)
                viewImage.frame = imageView.bounds

                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewImage)
            })
        }
    }
    
    func observerMessages() {
        arrayMessages.removeAll()
        let refChatRom = Database.database().reference().child("chat-romm").child(unicKyeForChatRoom!).child("messages")
        refChatRom.observe(.childAdded) { (snap) in
            
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            let g = Message.init(dic: dic)
            self.arrayMessages.append(g)
            self.activityIndicator?.stopAnimating()
            DispatchQueue.main.async(execute: {
                self.collectionView.reloadData()
                let indexPath  = IndexPath(item: self.arrayMessages.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNotification()
        self.navigationController?.navigationBar.backItem?.title = " "
        self.navigationController?.navigationBar.topItem?.title = " "
        FirebaseInternetConnection.isConnectedToInternet { (isConnect) in
            if isConnect {
                self.addImageForNavigationButton()
            }
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
        if isPushingNitification {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.viewControllers.remove(at: 1)
            self.delegate?.observeChangedMessageInsideChatRoom()
        } else {
            self.navigationController?.viewControllers.remove(at: 1)
            self.delegate?.observeChangedMessageInsideChatRoom()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInputTextField()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0)
        self.collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        activityIndicator?.center = self.view.center
        self.view.addSubview(activityIndicator!)
        self.arrayMessages.removeAll()
        self.navigationItem.leftBarButtonItem = backItem
        FirebaseInternetConnection.isConnectedToInternet { (isConnect) in
            if isConnect {
                self.observerMessages()
                self.addImageForNavigationButton()
            }
        }
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @objc func pressToUserImageRightButton() {
        
        let chatLogController =  self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileController") as! OtherProfileController
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
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
            self.photo()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose Photo".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Make Video".localized, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
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
    
    @objc func sendMassegaButtonTapped()  {
        let ref = databaseRef.child("chat-romm").child(unicKyeForChatRoom!)
        let toIdUser = user?.uid
        let fromId = Auth.auth().currentUser!.uid
        let time = Int(NSDate().timeIntervalSince1970)
        let value = ["ovnerGroup": fromId, "isSingle": 1, "uidGroup": unicKyeForChatRoom] as [String : Any]
        let text = self.textFieldInputTex.text
        
        ref.updateChildValues(value) { (err, data) in
            if err != nil {
                return
            }
            
            let ref1 =  self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("messages").childByAutoId()
            let value2 =  ["text": text, "fromId": fromId, "toId": toIdUser, "time": time, "deviceId": AppDelegate.DEVICEID] as [String : Any]
            
            ref1.updateChildValues(value2) { (err, data) in
                if err != nil {
                    return
                }
            }
            
            let ref2 = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("users")
            let ref3 = ref2.childByAutoId()
            let value3 =  ["toId": toIdUser] as [String : Any]
            
            ref3.updateChildValues(value3) { (err, data) in
                if err != nil {
                    return
                }
            }
            
            let refLastMessage = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!)
            refLastMessage.updateChildValues(["last-message": text])
            
            let timeRef = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!)
            timeRef.updateChildValues(["time": time])
            
            let refToIdUser = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!)
            refToIdUser.updateChildValues(["toId": toIdUser])
            self.featchMessages(toId: toIdUser!, textMessage: text!)
        }
        heightConstraintForConteinerViewForMessage?.constant = 40
        sendButton.isEnabled = false
        textFieldInputTex.text = " "
        self.plceholderLabel.isHidden = false
    }
    
    
    private func featchMessages(toId: String, textMessage: String) {
        let ref = Database.database().reference().child("users").child(toId)
        ref.observeSingleEvent(of: .value) { (snap) in
            
            guard let dic = snap.value  as? [String: AnyObject] else {
                return
            }
            
            let toIdDevice = dic["deviceId"] as? String
            self.sendPushNotificationToUser(idUser: toIdDevice!, textMessage: textMessage )
        }
    }
    
    private func sendPushNotificationToUser(idUser: String, textMessage: String) {
        
        var headers: HTTPHeaders = HTTPHeaders()
        headers = ["Content-Type": "application/json", "Authorization": "key=\(AppDelegate.SERVERCEY)"]
        let notificatios = ["to":"\(idUser)","notification":["body":textMessage,"title": " " ,"badge":1,"sound":"default","idRoom": self.unicKyeForChatRoom!, "isSingle": 1]] as [String: AnyObject]
        Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notificatios, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
    
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
        button.frame = CGRect(x: 160, y: 100, width: 28, height: 28)
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
        text.font = UIFont.systemFont(ofSize: 14)
        text.layer.cornerRadius = 18
        text.layer.masksToBounds = true
        text.layer.borderWidth = 1.0
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.isScrollEnabled = false
        text.textAlignment = .left
        text.textColor = UIColor.black
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let plceholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Your message".localized
        label.textAlignment = .left
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        self.massegeImputContainerView.addSubview(textFieldInputTex)
        self.massegeImputContainerView.addSubview(sendButton)
        self.massegeImputContainerView.addSubview(sendImageButton)
        
        self.sendButton.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 4).isActive = true
        self.sendButton.rightAnchor.constraint(equalTo: self.massegeImputContainerView.rightAnchor, constant: -17).isActive = true
        self.sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.sendImageButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        self.sendImageButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        self.sendImageButton.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 4).isActive = true
        self.sendImageButton.rightAnchor.constraint(equalTo: self.textFieldInputTex.leftAnchor, constant: -15).isActive = true
        self.sendImageButton.leftAnchor.constraint(equalTo: self.massegeImputContainerView.leftAnchor, constant: 17).isActive = true
        
        self.textFieldInputTex.bottomAnchor.constraint(equalTo: self.massegeImputContainerView.bottomAnchor, constant: -4).isActive = true
        self.textFieldInputTex.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 0.5).isActive = true
        self.textFieldInputTex.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor, constant: -13).isActive = true
        
        
        self.textFieldInputTex.addSubview(plceholderLabel)
        self.plceholderLabel.leftAnchor.constraint(equalTo: self.massegeImputContainerView.leftAnchor, constant: 65).isActive = true
        self.plceholderLabel.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 8).isActive = true
        self.plceholderLabel.widthAnchor.constraint(equalTo: self.massegeImputContainerView.widthAnchor).isActive = true
        
        self.separateView.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor).isActive = true
        self.separateView.widthAnchor.constraint(equalTo: self.massegeImputContainerView.widthAnchor).isActive = true
        self.separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
  
    func setUpNotification()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatSingleController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatSingleController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        hieghtConstraitForKeyword?.constant = 0
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0)
        let userInfo = notification.userInfo!
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        hieghtConstraitForKeyword?.constant = -keyboardHeight
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: keyboardHeight + 40, right: 0)
        self.messegeTextFieldUp()
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
    
    private func messegeTextFieldUp() {
        
        if self.arrayMessages.count > 1 {
            let indexPath  = IndexPath(item: self.arrayMessages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension ChatSingleController: UICollectionViewDelegate, UICollectionViewDataSource {
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMessages.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ChatCollectionViewCell
        cell?.delegate = self
        cell?.message = arrayMessages[indexPath.item]
        
        let uid = Auth.auth().currentUser?.uid
        
        if let text = arrayMessages[indexPath.item].text {
             cell?.bubleWidthAchor?.constant = estimateFrameForText(text: text).width + 32
        } else {
              cell?.bubleWidthAchor?.constant = 200
        }
   
        return cell!
    }
    
}

extension ChatSingleController: UICollectionViewDelegateFlowLayout {
   
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = arrayMessages[indexPath.item].text
        var height: CGFloat = 80
       
        if let messageText = text {
            height = estimateFrameForText(text: messageText).height + 20
        } else {
            height = 200
        }
        return CGSize(width: UIScreen.main.bounds.width, height: height )
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString.init(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
}

extension ChatSingleController: ChatCollectionViewCellDelegate {
    
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
        zoomingImage.contentMode = .scaleAspectFill
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
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
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
extension ChatSingleController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        self.plceholderLabel.isHidden = !textView.text.isEmpty
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        heightConstraintForConteinerViewForMessage?.constant = newFrame.size.height + 10
        textInsideTextFeld = textView.text
    }
}

extension ChatSingleController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            videoSelectedForInfo(url: videoUrl)

        } else {
            imageSelectedForInfo(info: info as [String : AnyObject])
        
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func videoSelectedForInfo(url: NSURL) {
        self.activityIndicator?.startAnimating()
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask =  Storage.storage().reference().child("message_movies").child(fileName).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
    
            if error != nil {
                return
            }
            
            if let storageUrlVideo = metadata?.downloadURL()?.absoluteString {
                let url = URL.init(string: storageUrlVideo)
                let image = self.makeUIImageFromUrl(url: url as! NSURL)
                
                self.uploadImageToFirebase(image: image!, completion: { (storageUrl) in
                    self.saveVideoFileInFirebase(url: storageUrlVideo, photoUrl: storageUrl)
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
            self.activityIndicator?.startAnimating()
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
        
        let ref = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!)
        let time = Int(NSDate().timeIntervalSince1970)
        let toIdUser = self.user?.uid
        let fromId = Auth.auth().currentUser!.uid
        let value =  ["ovnerGroup": fromId, "isSingle": 1, "uidGroup": self.unicKyeForChatRoom, "toId": toIdUser] as [String : Any]
        
        ref.updateChildValues(value) { (err, data) in
            if err != nil {
                return
            }
            let ref1 =  self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("messages").childByAutoId()
            let value2 =  ["fromId" : fromId, "toId": toIdUser, "imageUrl": url, "time": time] as [String : Any]
            
            ref1.updateChildValues(value2) { (err, data) in
                if err != nil {
                    return
                }
            }
            
            let ref2 =  self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("users")
            let value3 =  ["toId": toIdUser] as [String : Any]
            
            ref2.updateChildValues(value3) { (err, data) in
                if err != nil {
                    return
                }
            }
            
             self.activityIndicator?.stopAnimating()
        }
    }
    private func saveVideoFileInFirebase(url: String, photoUrl: String) {

        let ref = self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!)
        let time = Int(NSDate().timeIntervalSince1970)
        let toIdUser = user!.uid
        
        let fromId = Auth.auth().currentUser!.uid
        let value =  ["ovnerGroup": fromId, "isSingle": 1, "uidGroup": self.unicKyeForChatRoom, "toId": toIdUser] as [String : Any]
        
        ref.updateChildValues(value) { (err, data) in
            if err != nil {
                return
            }
            let ref1 =  self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("messages").childByAutoId()
            let value2 =  ["fromId" : fromId, "toId": toIdUser, "videoUrl": url, "time": time, "imageUrl": photoUrl] as [String : Any]
        
            ref1.updateChildValues(value2) { (err, data) in
                if err != nil {
                    return
                }
            }
            let ref2 =  self.databaseRef.child("chat-romm").child(self.unicKyeForChatRoom!).child("users")
            let value3 =  ["toId": toIdUser] as [String : Any]
            ref2.updateChildValues(value3) { (err, data) in
                if err != nil {
                    return
                }
            }
            
            self.activityIndicator?.stopAnimating()
        }
    }
     public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


struct FirebaseInternetConnection {
    
    static func isConnectedToInternet(isConnect:@escaping (Bool)->()) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
               isConnect(true)
            } else {
               isConnect(false)
            }
        })
    }
}
