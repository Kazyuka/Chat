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
    var transition = PresentAnimation()
    var grouChat = [RoomChat]()
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeUserMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(Logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group", style: .plain, target: self, action: #selector(createGroupButtonClick))
        isUserLogin()
        navigationController?.delegate = self
    }
    
    func observeUserMessages() {
        
        self.grouChat.removeAll()
        let refChatRom = Database.database().reference().child("chat-romm")
        refChatRom.observe(.childAdded) { (snap) in
            
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            
            let g = RoomChat.init(dic: dic)
            let uid = Auth.auth().currentUser?.uid
            if let usersInChatRomm = g.groupUID?.components(separatedBy:" ") {
                if usersInChatRomm.contains(uid!) {
                    self.grouChat.append(g)
                }
            } else {
                self.grouChat.append(g)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.tableView.reloadData()
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

    @objc func createGroupButtonClick () {
        let createGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "GroupCreateController") as! GroupCreateController
        createGroupVC.delegate = self
        self.present(createGroupVC, animated: true, completion: nil)
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
    
    func setupNAvigationBar(user: User) {
        self.grouChat.removeAll()
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
}

extension ChatController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return grouChat.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
        cell.chat = grouChat[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let gr = grouChat[indexPath.row]
   
        if let isTypeGroup = gr.isSingle {
            
            if isTypeGroup {
                
                let chatLogController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatSingleController") as! ChatSingleController
                User.getCurrentUserFromFirebase(user: { (us) in
                    chatLogController.user = us
                    chatLogController.unicKyeForChatRoom = gr.groupUID
                    self.navigationController?.pushViewController(chatLogController, animated: true)
                })
            } else {
                
                  let chatLogGroupController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatGrupController") as! ChatGrupController
                  chatLogGroupController.allUsers = gr.usersChat
                  chatLogGroupController.unicKyeForChatRoom = gr.groupUID
                  chatLogGroupController.room = gr
                  self.navigationController?.pushViewController(chatLogGroupController, animated: true)
                
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

extension ChatController: GroupCreateControllerDelegate {
    
    func goToDetailCreateGroup(g: Group) {
        let detailGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailGroupController") as! DetailGroupController
        detailGroupVC.group = g
        self.present(detailGroupVC, animated: true, completion: nil)
    }
}


