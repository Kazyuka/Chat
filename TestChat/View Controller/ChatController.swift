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
    var filteredGroupChat = [RoomChat]()
    
    var searchController:UISearchController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeUserMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(Logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group".localized, style: .plain, target: self, action: #selector(createGroupButtonClick))
        searchController = UISearchController(searchResultsController: nil);
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search".localized
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        isUserLogin()
    }
    
    func observeUserMessages() {
        self.grouChat.removeAll()
        
        let refChatRom = Database.database().reference().child("chat-romm")
        refChatRom.observe(.childAdded) { (snap) in
            
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            let g = RoomChat.init(dic: dic)
            if let uid = Auth.auth().currentUser?.uid {
                
                if let val = g.usersChat {
                    if val.contains(uid) {
                        self.grouChat.append(g)
                    } else {
                        self.grouChat.append(g)
                    }
                }
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
                    let user = User(dic: dictionary)
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
    
    func goToGroupChat(roomChat: RoomChat) {
        let chatLogGroupController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatGrupController") as! ChatGrupController
        chatLogGroupController.room = roomChat
        self.navigationController?.pushViewController(chatLogGroupController, animated: true)
    }
    func gotoSingleChat(roomChat: RoomChat) {
        
        let chatLogController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatSingleController") as! ChatSingleController
        RoomChat.getCurrentUserFromSingleMessage(chatRoom: roomChat) { (us) in
            chatLogController.user = us
            chatLogController.unicKyeForChatRoom = roomChat.groupUID
            self.navigationController?.pushViewController(chatLogController, animated: true)
        }
    }
}

extension ChatController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredGroupChat.count
        } else {
            return grouChat.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.chat = filteredGroupChat[indexPath.row]
        } else {
            if grouChat.count != 0 {
                cell.chat = grouChat[indexPath.row]
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatRoom = grouChat[indexPath.row]
        if let isTypeGroup = chatRoom.isSingle {
            if isTypeGroup {
                self.searchController.isActive = false
                gotoSingleChat(roomChat: chatRoom)
            } else {
                self.searchController.isActive = false
                goToGroupChat(roomChat: chatRoom)
            }
        }
    }
}

extension ChatController {
    
    func setupNAvigationBar(user: User) {
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

extension ChatController: GroupCreateControllerDelegate {
    
    func goToDetailCreateGroup(g: Group) {
        let detailGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailGroupController") as! DetailGroupController
        detailGroupVC.group = g
        detailGroupVC.delegate = self
        self.present(detailGroupVC, animated: true, completion: nil)
    }
}

extension ChatController: GoToGroupCahatRoomDelegate {
   
    func goToGroupChat(room: RoomChat) {
        self.goToGroupChat(roomChat: room)
    }
}

extension ChatController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(searchText:String) {
        
        filteredGroupChat = grouChat.filter({ (room) -> Bool in
    
            if room.groupName == nil {
                let name = room.usersChat!.first?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
                return name != nil
            } else {
                let name = room.groupName?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
                return name != nil
            }
            return false
        })
    }
}

extension ChatController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

