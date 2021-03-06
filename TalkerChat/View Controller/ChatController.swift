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
import NVActivityIndicatorView

protocol ChatControllerDelegate: class {
    func observeChangedMessageInsideChatRoom()
}

class ChatController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var transition = PresentAnimation()
    var grouChat = [RoomChat]()
    var filteredGroupChat = [RoomChat]()
    
    var searchController:UISearchController!
    var activityIndicator: NVActivityIndicatorView?
    
    
    var offset = UIOffset()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Chats".localized
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.setupNavigationBar()
        self.tabBarController?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(removeGroupObserver(notification:)), name: .REMOVE_GROUP, object: nil)
    }
    
    @objc func removeGroupObserver(notification: NSNotification) {
        self.observeUserMessages()
        NotificationCenter.default.removeObserver(self, name: .REMOVE_GROUP, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = true
        tableView.separatorColor = UIColor.clear
        searchController = UISearchController(searchResultsController: nil);
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.backgroundColor = UIColor.white
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        self.tableView.separatorColor = UIColor.clear
        isUserLogin()
        
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2 - 10, y: self.view.frame.height/2 - 60 , width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        
        self.view.addSubview(activityIndicator!)
        self.observeUserMessages()
        
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.7450980392, blue: 0.9411764706, alpha: 1)
        searchController.searchBar.tintColor = .white
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textAlignment = .center
            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = .white
            }
            textfield.textColor = UIColor.white
            textfield.placeholder = "Search"
            let textFieldInsideSearchBarLabel = textfield.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = UIColor.white
            
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                backgroundview.layer.cornerRadius = 18
                backgroundview.clipsToBounds = true
            }
        }
    }
    
    func observeUserMessages() {
        self.activityIndicator?.startAnimating()
        self.grouChat.removeAll()
        self.tableView.isHidden = false
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
                    } else if g.ovnerGroup == uid {
                        self.grouChat.append(g)
                    }
                }
                self.grouChat.sort(by: { (chat1, chat2) -> Bool in
                    
                    if let time = chat1.time, let time2 = chat2.time {
                         return time > time2
                    }
                    return true
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.activityIndicator?.stopAnimating()
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
            self.activityIndicator?.stopAnimating()
        })
    }
    
    func isUserLogin() {
        
        let uid = Auth.auth().currentUser?.uid
        if uid == nil {
            self.logout()
        } else {
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            })
        }
    }

    @IBAction func createGroupButtonAction(_ sender: Any) {
        let createGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "GroupCreateController") as! GroupCreateController
        createGroupVC.delegate = self
        self.navigationController?.pushViewController(createGroupVC, animated: true)
    }
    
    @objc func logout() {
        do {
            try   Auth.auth().signOut()
        } catch let err {
            print(err)
        }
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func goToGroupChat(roomChat: RoomChat) {
        let chatLogGroupController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatGrupController") as! ChatGrupController
        chatLogGroupController.room = roomChat
        chatLogGroupController.delegate = self
        self.navigationController?.pushViewController(chatLogGroupController, animated: true)
    }
    func gotoSingleChat(roomChat: RoomChat) {
        
        let chatLogController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatSingleController") as! ChatSingleController
        RoomChat.getCurrentUserFromSingleMessage(chatRoom: roomChat) { (us) in
            chatLogController.user = us
            chatLogController.unicKyeForChatRoom = roomChat.groupUID
            chatLogController.delegate = self
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
        cell.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}

extension ChatController: DissmisGroupCreteDelegate {
    func dissmissGroupCreteView(room: RoomChat) {
        self.goToGroupChat(roomChat: room)
    }
}

extension ChatController: ChatControllerDelegate {
    func observeChangedMessageInsideChatRoom() {
        self.tableView.isHidden = true
        activityIndicator?.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.observeUserMessages()
        }
    }
}

extension ChatController: GroupCreateControllerDelegate {
    
    func goToDetailCreateGroup(g: Group) {
        let detailGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailGroupController") as! DetailGroupController
        detailGroupVC.group = g
        self.navigationController?.pushViewController(detailGroupVC, animated: true)
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
                
                let name = room.searchUser!.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
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

extension ChatController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 1 {
            self.grouChat.removeAll()
            self.observeUserMessages()
        }
    }
}


extension Notification.Name {
    static let REMOVE_GROUP = Notification.Name("REMOVE_GROUP")
}

