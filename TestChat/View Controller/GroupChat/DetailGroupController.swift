//
//  DetailGroupController.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import NVActivityIndicatorView

@objc protocol DetailGroupControllerDelegate {
    func getCheckUser(users: [User])
}

protocol GoToGroupCahatRoomDelegate: class {
    func goToGroupChat(room: RoomChat)
}

class DetailGroupController: UIViewController {

    @IBOutlet weak var addUserLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var imageGroupView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: NVActivityIndicatorView?
    var userArray = [User]()
    var group: Group?
    var keyChat: String?
    var currentUser: User?
    
    weak var delegateForDissmiss: DissmisGroupCreteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = group?.nameGroup
    }
    
    func configureView() {
        
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        self.view.addSubview(activityIndicator!)
        self.navigationItem.title = group?.nameGroup
        nameGroup.text = group?.nameGroup
        if let im = group?.image {
            self.imageGroupView.image = im
        }
        User.getCurrentUserFromFirebase { (user) in
            self.currentUser = user
            if let im = user.imageProfile {
                let url = NSURL.init(string: im)
                self.currentUserImageView.sd_setImage(with: url! as URL)
            } else {
                
                self.currentUserImageView.sd_setImage(with: NSURL() as URL, placeholderImage: UIImage.init(named: "userImage.png"), options: .cacheMemoryOnly, progress: { (y, r, ur) in
                }, completed: nil)
            }
            
            self.currentUserNameLabel.text = user.name + " " + user.lastName!
        }
        self.currentUserImageView.setRounded()
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        tableView.separatorColor = .clear
        self.navigationItem.leftBarButtonItem = backButton
        addUserLabel.text = "Add User".localized
    }
    @IBAction func addUsersButtonClick(_ sender: Any) {
        let groupMC = self.storyboard?.instantiateViewController(withIdentifier: "GroupMessageController") as! GroupMessageController
        groupMC.delegate = self
        groupMC.currentLisrUser = userArray
        self.navigationController?.pushViewController(groupMC, animated: true)
    }
    
    func getUIDForGroup() -> String {
        
        var users = [String]()
        for us in userArray {
            users.append(us.uid!)
        }
        let keyChat = users.joined(separator: " ")
        return keyChat
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        registerGroupIntoFirebase()
    }

    private func registerGroupIntoFirebase() {
        self.activityIndicator?.startAnimating()
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("group_images").child("\(imageName).png")
        let uploadData = UIImagePNGRepresentation(self.group!.image!)
        keyChat = Database.database().reference().child("chat-romm").childByAutoId().key
        self.userArray.append(currentUser!)
        storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
            if err != nil{
                self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                return
            }
            if let meta = metadata?.downloadURL()?.absoluteString {
                let uid = Auth.auth().currentUser?.uid
                let value = ["nameGroup": self.group?.nameGroup, "groupImageUrl" : meta, "ovnerGroup": uid, "isSingle": 0, "uidGroup": self.keyChat!] as [String : Any]
                let ref = Database.database().reference().child("chat-romm").child(self.keyChat!)
                ref.updateChildValues(value, withCompletionBlock: { (err, snap) in
                    
                    if err != nil {
                        return
                    }
                    
                    for us in self.userArray {
                        let ref2 = Database.database().reference().child("chat-romm").child(self.keyChat!).child("users").childByAutoId()
                        ref2.updateChildValues(["toId" :us.uid])
                    }
                    
                    self.getChatRommFromFirebaseDatabase()
                })
            }
        })
    }
    
    
    func getChatRommFromFirebaseDatabase() {
    
        let refChatRom = Database.database().reference().child("chat-romm").child(self.keyChat!)
        refChatRom.observe(.value) { (snap) in
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            let g = RoomChat.init(dic: dic)
            self.activityIndicator?.stopAnimating()
            self.delegateForDissmiss?.dissmissGroupCreteView(room: g)
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func editButtonClick(_ sender: Any) {
        let editGroup =  self.storyboard?.instantiateViewController(withIdentifier: "EditDetailGroupController") as! EditDetailGroupController
        editGroup.group = group
        editGroup.delegate = self
        self.navigationController?.pushViewController(editGroup, animated: true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension DetailGroupController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserCell
        cell.user = userArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let us = userArray[indexPath.row].uid
        if us != Auth.auth().currentUser?.uid {
            
            if editingStyle == .delete {
                userArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension DetailGroupController: EditDetailGroupControllerDelegate {
    func getEditedGroup(group: Group) {
        self.group = group
        nameGroup.text = group.nameGroup
        if let im = group.image {
            self.imageGroupView.image = im
        }
    }
}

extension DetailGroupController: DetailGroupControllerDelegate {
    
    func getCheckUser(users: [User]) {
        users.forEach { (us) in
            self.userArray.append(us)
            self.tableView.reloadData()
        }
    }
}
