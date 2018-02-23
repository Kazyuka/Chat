

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
class ChatLogController: UICollectionViewController {
   
    let cellIdentifier = "Cell"
    var arrayMessages = [Message]()
    var hieghtConstraitForKeyword: NSLayoutConstraint?
    var heightConstraintForConteinerViewForMessage: NSLayoutConstraint?
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            self.arrayMessages.removeAll()
            observerMessages()
        }
    }
    
    func observerMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("message-users").child(uid)
        ref.observe(.childAdded, with: { (snap) in
            
            let idUser = snap.key
            let messageUserRef = Database.database().reference().child("messages").child(idUser)
            messageUserRef.observe(.value, with: { (snap) in
                guard let dic = snap.value as? [String: AnyObject] else {
                    return
                }
                let mes = Message(dic: dic)
                
                if mes.chatPartnerId == self.user?.userId {
                      self.arrayMessages.append(mes)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
            }, withCancel: { (er) in
                
            })
            
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
         self.setupInputTextField()
         self.setUpNotification()
         collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
         self.collectionView?.backgroundColor = UIColor.white
         collectionView?.alwaysBounceVertical = true
         collectionView?.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ChatCollectionViewCell
        cell?.message = arrayMessages[indexPath.item]
        return cell!
    }
    
    @objc func sendMassegaButtonTapped()  {
       
        let ref = Database.database().reference().child("messages")
        let childRef  = ref.childByAutoId()
        let toIdUser = user?.userId
        let fromId = Auth.auth().currentUser!.uid
        let time = Int(NSDate().timeIntervalSince1970)
        let value = ["text": textFieldInputTex.text!, "toId": toIdUser, "fromId" : fromId, "time": time] as [String : Any]
    
        childRef.updateChildValues(value) { (err, data) in
            if err != nil {
                return
            }
            let messageRef = Database.database().reference().child("message-users").child(fromId)
            let messsID = childRef.key
            messageRef.updateChildValues([messsID: 2])
            
            let recipientRef = Database.database().reference().child("message-users").child(toIdUser!)
            recipientRef.updateChildValues([messsID: 2])
        }
        view.endEditing(true)
        heightConstraintForConteinerViewForMessage?.constant = 40
        sendButton.isEnabled = false
        textFieldInputTex.text = "Your message"
        textFieldInputTex.textColor = UIColor.lightGray
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
        button.setImage(UIImage(named:"send"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendMassegaButtonTapped), for: .touchUpInside)
        return button
    }()
    let massegeImputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textFieldInputTex: UITextView = {
        let text = UITextView()
        text.layer.borderWidth = 1.0
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.isScrollEnabled = false
        text.text = "Your message"
        text.textColor = UIColor.lightGray
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let separateView:  UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
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
        
        self.sendButton.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 4).isActive = true
        self.sendButton.rightAnchor.constraint(equalTo: self.massegeImputContainerView.rightAnchor, constant: -4).isActive = true
        self.sendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
    
        self.textFieldInputTex.bottomAnchor.constraint(equalTo: self.massegeImputContainerView.bottomAnchor, constant: -2).isActive = true
        self.textFieldInputTex.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor, constant: 2).isActive = true
         self.textFieldInputTex.leftAnchor.constraint(equalTo: self.massegeImputContainerView.leftAnchor, constant: 2).isActive = true
        self.textFieldInputTex.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor, constant: -10).isActive = true
        
        self.separateView.topAnchor.constraint(equalTo: self.massegeImputContainerView.topAnchor).isActive = true
        self.separateView.widthAnchor.constraint(equalTo: self.massegeImputContainerView.widthAnchor).isActive = true
        self.separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
  
    func setUpNotification()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatLogController.animateWithKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatLogController.animateWithKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func animateWithKeyboard(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let moveUp = (notification.name == NSNotification.Name.UIKeyboardWillShow)
        
        hieghtConstraitForKeyword?.constant = moveUp ? -keyboardHeight : 0
        
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: {
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}
extension ChatLogController: UICollectionViewDelegateFlowLayout {
   
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = arrayMessages[indexPath.item].text
        return CGSize(width: view.frame.width, height: (text?.height(withConstrainedWidth: 200, font: UIFont.boldSystemFont(ofSize: 14)))! + 20)
    }
}
extension ChatLogController: UITextViewDelegate {
    
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
        
        if textView.text == "Your message" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Your message"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

