//
//  ViewController.swift
//  TestChat
//
//  Created by Руслан Казюка on 09.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var messages = [Message]()
    var messagesDic = [String: Message]()
    var transition = PresentAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(Logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group", style: .plain, target: self, action: #selector(createGroupButtonClick))
        isUserLogin()
        navigationController?.delegate = self
    }
    
    func observeGrupUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let refGroup = Database.database().reference().child("group")
        refGroup.observe(.childAdded) { (snap) in
            let messageGroup = Database.database().reference().child("message-group")
            messageGroup.observeSingleEvent(of: .value, with: { (snapshot) in
                
               
                
            })
            
        }
        
        /*let refUserMessage = Database.database().reference().child("message-users").child(uid)
        refUserMessage.observe(.childAdded) { (snap) in
            let messages = Database.database().reference().child("message-group")
            messages.observeSingleEvent(of: .value, with: { (data) in
                
                
                if let snapshots = data.children.allObjects as? [DataSnapshot] {
                    
                    for snap in snapshots {
                        
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            
                            let mess = GroupMessage(dic: postDict)
                            
                            if let chatPartnerId = mess.fromIdUser {
                                self.messagesDic[chatPartnerId] = mess
                                self.messages = Array(self.messagesDic.values)
                                self.messages.sort(by: { (m1, m2) -> Bool in
                                    return m1.time!.intValue > m2.time!.intValue
                                })
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            })
        }*/
    }
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
         let refUserMessage = Database.database().reference().child("message-users").child(uid)
            refUserMessage.observe(.childAdded) { (snap) in
             let messageId = snap.key
             let messages = Database.database().reference().child("messages").child(messageId)
                messages.observeSingleEvent(of: .value, with: { (data) in
                if let dic = data.value as? [String: AnyObject] {
                    let mes = Message(dic: dic)
                    
                    if let chatPartnerId = mes.chatPartnerId {
                        self.messagesDic[chatPartnerId] = mes
                        self.messages = Array(self.messagesDic.values)
                        self.messages.sort(by: { (m1, m2) -> Bool in
                            return m1.time!.intValue > m2.time!.intValue
                        })
                    }
                }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                       self.tableView.reloadData()
                    })
            })
        }
    }
    
    func isUserLogin() {
        
        let uid = Auth.auth().currentUser?.uid
        
        if uid == nil {
            self.Logout()
        } else {
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    var user = User(dic: dictionary)
                    self.setupNAvigationBar(user: user)
                }
            })
        }
    }

    func setupNAvigationBar(user: User) {
        messages.removeAll()
        messagesDic.removeAll()
        self.tableView.reloadData()
        observeGrupUserMessages()
        observeUserMessages()
        self.navigationItem.title = user.name
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        let conteinerView = UIView()
        conteinerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(conteinerView)
        
        let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        
        profileImage.layer.cornerRadius = 20
        profileImage.layer.masksToBounds = true
        profileImage.backgroundColor = UIColor.black
        profileImage.contentMode = .scaleAspectFill
      
       // let data = NSData.init(contentsOf: URL.init(string: user.imageProfile!)!)
       // profileImage.image = UIImage(data: data as! Data)
        conteinerView.addSubview(profileImage)
       
        profileImage.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        conteinerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true
        
        conteinerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        conteinerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        titleView.isUserInteractionEnabled = true
    }
    
    @objc func createGroupButtonClick () {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "GroupCreateController") as! GroupCreateController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc func goToChat(user: User) {
        /*let chat = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chat.user = user
        self.navigationController?.pushViewController(chat, animated: true)*/
    }
    
    @objc func goToGrupChat(users: [String]) {
        let chat = ChatGrupController(collectionViewLayout: UICollectionViewFlowLayout())
        chat.allUsers = users
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    @objc func Logout() {
        do {
            try   Auth.auth().signOut()
        } catch let err {
            print(err)
        }
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.messagseController = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ChatController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
        cell.message = messages[indexPath.row]
        return cell
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let messeage = messages[indexPath.row]
        
        guard let chId = messeage.chatPartnerId else {
            return
        }
        
        if type(of: messeage) == GroupMessage.self {
            
            let  mes = messeage as? GroupMessage
            goToGrupChat(users: mes!.toIdUsers )
            
        } else {
            
            let ref = Database.database().reference().child("users").child(chId)
            ref.observeSingleEvent(of: .value) { (snap) in
                
                if let data = snap.value as? [String: AnyObject] {
                    let user = User(dic: data)
                    user.userId = chId
                    self.goToChat(user: user)
                }
            }
        }
    }
}

extension ChatController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.duraction = 2.5
        transition.presentDefault = .presentation
        return transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension ChatController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presentDefault = .presentation
        switch operation {
        case .push:
            return transition
        default:
            break
        }
        return transition
    }
}


