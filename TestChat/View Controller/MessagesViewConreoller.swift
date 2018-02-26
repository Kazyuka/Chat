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

class MessagesViewConroller: UITableViewController {
    
    let cellId = "cell"
    var messages = [Message]()
    var messagesDic = [String: Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(Logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Messages", style: .plain, target: self, action: #selector(goToMessages))
        isUserLogin()
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
      
        let data = NSData.init(contentsOf: URL.init(string: user.imageProfile!)!)
        profileImage.image = UIImage(data: data as! Data)
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
    
    @objc func goToChat(user: User) {
        let chat = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chat.user = user
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    @objc func Logout() {
        do {
            try   Auth.auth().signOut()
        } catch let err {
            print(err)
        }
        
        let loginVC = LoginViewController()
        loginVC.messagseController = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @objc func goToMessages() {
        let newPostVC = NewMessagesController()
        newPostVC.messagesViewComtroller = self
        present(UINavigationController(rootViewController: newPostVC), animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let messeage = messages[indexPath.row]
        
        guard let chId = messeage.chatPartnerId else {
            return
        }
        
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


