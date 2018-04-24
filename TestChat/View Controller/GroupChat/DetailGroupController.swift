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

@objc protocol DetailGroupControllerDelegate {
    func getCheckUser(users: [User])
}

protocol GoToGroupCahatRoomDelegate: class {
    func goToGroupChat(room: RoomChat)
}

class DetailGroupController: UIViewController {

    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var imageGroupView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var progressHUD: ProgressHUD? = nil
    var userArray = [User]()
    var group: Group?
    var keyChat: String?
    
    weak var delegate: GoToGroupCahatRoomDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureView() {
        
        progressHUD = ProgressHUD(text: "Please Wait")
        progressHUD?.hide()
        self.view.addSubview(progressHUD!)
        
        nameGroup.text = group?.nameGroup
        if let im = group?.image {
            self.imageGroupView.image = im
        }
        User.getCurrentUserFromFirebase { (us) in
            self.userArray.append(us)
            self.tableView.reloadData()
        }
    }
    @IBAction func addUsersButtonClick(_ sender: Any) {
        let groupMC = self.storyboard?.instantiateViewController(withIdentifier: "GroupMessageController") as! GroupMessageController
        groupMC.delegate = self
        self.present(groupMC, animated: true, completion: nil)
    }
    
    func getUIDForGroup() -> String {
        
        var users = [String]()
        for us in userArray {
            users.append(us.uid!)
        }
        let keyChat = users.joined(separator: " ")
        return keyChat
    }
    
    @IBAction func chatButtonClick(_ sender: Any) {
        
        if userArray.count != 0 {
            registerGroupIntoFirebase()
        } else {
            self.present(self.allertControllerWithOneButton(message: "Add users for Group"), animated: true, completion: nil)
        }
    }
    
    private func registerGroupIntoFirebase() {
        progressHUD?.show()
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("group_images").child("\(imageName).png")
        let uploadData = UIImagePNGRepresentation(self.group!.image!)
        keyChat = Database.database().reference().child("chat-romm").childByAutoId().key
        let ref = Database.database().reference().child("chat-romm").child(keyChat!).child("users")
    
            for us in userArray {
                let ch = ref.childByAutoId()
                let v = ["toId" : us.userId]
                ch.updateChildValues(v)
            }
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
                if err != nil{
                    
                    self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                    return
                }
                if let meta = metadata?.downloadURL()?.absoluteString {
                    let uid = Auth.auth().currentUser?.uid
                    let value = ["nameGroup": self.group?.nameGroup, "groupImageUrl" : meta, "ovnerGroup": uid, "isSingle": 0, "uidGroup": self.keyChat!] as [String : Any]
                    let ref = Database.database().reference().child("chat-romm").child(self.keyChat!)
                    ref.updateChildValues(value)
                    self.getChatRommFromFirebaseDatabase()
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
            self.progressHUD?.hide()
            self.dismiss(animated: true, completion: {
                self.delegate?.goToGroupChat(room: g)
            })
        }
    }

    @IBAction func editButtonClick(_ sender: Any) {
        let editGroup =  self.storyboard?.instantiateViewController(withIdentifier: "EditDetailGroupController") as! EditDetailGroupController
        editGroup.group = group
        editGroup.delegate = self
        self.present(editGroup, animated: true, completion: nil)
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
        return 75
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
        userArray.removeAll()
        User.getCurrentUserFromFirebase { (us) in
            self.userArray = users
            self.userArray.append(us)
            self.userArray = Array(self.userArray.reversed())
            self.tableView.reloadData()
        }
    }
}
