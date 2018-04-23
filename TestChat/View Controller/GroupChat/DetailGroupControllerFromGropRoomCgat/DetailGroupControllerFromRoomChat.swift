//
//  DetailGroupControllerFromRoomChat.swift
//  TestChat
//
//  Created by Руслан Казюка on 23.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DetailGroupControllerFromRoomChat: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var nameGroup: UILabel!
    
    var unicKyeForChatRoom: String!
    var roomChat: RoomChat?
    var group: Group?
    var userArray = [User]()
    var progressHUD: ProgressHUD? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupFromFirebase()
    }
    
    func getGroupFromFirebase() {
        
        let refChatRom = Database.database().reference().child("chat-romm").child(unicKyeForChatRoom!)
        refChatRom.observe(.value) { (snap) in
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            self.roomChat = RoomChat.init(dic: dic)
            self.configureView()
        }
    }
    
    @IBAction func editGroupButtonClick(_ sender: Any) {
        let editGroup =  self.storyboard?.instantiateViewController(withIdentifier: "EditDetailGroupController") as! EditDetailGroupController
        group = Group(nameGroup: roomChat?.groupName, image: imageGroup.image, typeGroup: roomChat?.isSingle)
        editGroup.group = group
        editGroup.delegate = self
        self.present(editGroup, animated: true, completion: nil)
    }
    func configureView() {
        
        let url = URL.init(string: (roomChat?.imageGroup)!)
        imageGroup.sd_setImage(with: url! as URL)
        nameGroup.text = roomChat?.groupName
        
        progressHUD = ProgressHUD(text: "Please Wait")
        progressHUD?.hide()
        self.view.addSubview(progressHUD!)
        
        if let usersChat = roomChat {
            
            if usersChat.usersChat != nil {
                for user in usersChat.usersChat! {
                    let ref = Database.database().reference().child("users").child(user)
                    ref.observeSingleEvent(of: .value, with: { (snap) in
                        
                        if let u = snap.value as? [String: AnyObject] {
                            let use = User(dic: u)
                            self.userArray.append(use)
                        }
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    @IBAction func chatButtonClick(_ sender: Any) {
        updateGroupIntoFirebase()
    }
    @IBAction func addUserButtonClick(_ sender: Any) {
        
        let groupMC = self.storyboard?.instantiateViewController(withIdentifier: "GroupMessageController") as! GroupMessageController
        groupMC.delegate = self
        self.present(groupMC, animated: true, completion: nil)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func updateGroupIntoFirebase() {
        progressHUD?.show()
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("group_images").child("\(imageName).png")
        let uploadData = UIImagePNGRepresentation(self.imageGroup.image!)
        let ref = Database.database().reference().child("chat-romm").child(self.unicKyeForChatRoom).child("users")
        ref.removeValue()
       
        for us in self.userArray {
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
                let value = ["nameGroup": self.nameGroup?.text, "groupImageUrl" : meta] as [String : Any]
                let ref = Database.database().reference().child("chat-romm").child(self.unicKyeForChatRoom)
                ref.updateChildValues(value)
                self.progressHUD?.hide()
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}

extension DetailGroupControllerFromRoomChat: UITableViewDataSource, UITableViewDelegate {
    
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

extension DetailGroupControllerFromRoomChat: DetailGroupControllerDelegate {
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

extension DetailGroupControllerFromRoomChat: EditDetailGroupControllerDelegate {
    func getEditedGroup(group: Group) {
        self.group = group
        nameGroup.text = group.nameGroup
        if let im = group.image {
            self.imageGroup.image = im
        }
    }
}
