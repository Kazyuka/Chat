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
import NVActivityIndicatorView

class DetailGroupControllerFromRoomChat: UIViewController {
    
    @IBOutlet weak var addButtonUser: UIButton!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    @IBOutlet weak var editButtonUser: UIBarButtonItem!
    @IBOutlet weak var addUserLabel: UILabel!
    
    var activityIndicator: NVActivityIndicatorView?
    
    var unicKyeForChatRoom: String!
    var roomChat: RoomChat?
    var group: Group?
    var userArray = [User]()

    let currentUser = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var back: UIBarButtonItem!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUserImageView.setRounded()
        imageGroup.setRounded()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3019607843, green: 0.7411764706, blue: 0.9294117647, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.white]
        tableView.separatorColor = .clear
        self.navigationItem.leftBarButtonItem = back
        addUserLabel.text = "Add User".localized
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupFromFirebase()
    }
    
    func getGroupFromFirebase() {
        
        let refChatRom = Database.database().reference().child("chat-romm").child(unicKyeForChatRoom!)
        refChatRom.observeSingleEvent(of: .value, with: { (snap) in
            guard let dic = snap.value as? [String: AnyObject] else {
                return
            }
            self.roomChat = RoomChat.init(dic: dic)
            self.configureView()
        })
    }
    
    @IBAction func editGroupButtonClick(_ sender: Any) {
        let editGroup =  self.storyboard?.instantiateViewController(withIdentifier: "EditDetailGroupController") as! EditDetailGroupController
       
        group =  Group(idGroup: roomChat?.groupUID, nameGroup: roomChat?.groupName, image: imageGroup.image, typeGroup: roomChat?.isSingle)
        editGroup.group = group
        editGroup.delegate = self
        self.navigationController?.pushViewController(editGroup, animated: true)
    }
    
    func configureView() {
        
        checkOvnerGroup()
        getCurrentUser()
        
        let url = URL.init(string: (roomChat?.imageGroup)!)
        imageGroup.sd_setImage(with: url! as URL)
        nameGroup.text = roomChat?.groupName
        self.navigationItem.title = roomChat?.groupName
        activityIndicator = NVActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 30.0, height: 30.0), type: .ballClipRotatePulse, color:  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), padding: 0.0)
        self.view.addSubview(activityIndicator!)
        
        if let usersChat = roomChat {
            if usersChat.usersChat != nil {
                for user in usersChat.usersChat! {
                    let ref = Database.database().reference().child("users").child(user)
                    ref.observeSingleEvent(of: .value, with: { (snap) in
                        
                        if let u = snap.value as? [String: AnyObject] {
                            let use = User(dic: u)
                            
                            if use.uid != self.currentUser {
                                self.userArray.append(use)
                            }
                        }
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    
    private func getCurrentUser() {
        
        User.getCurrentUserFromFirebase { (user) in
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
    }
    
    private func checkOvnerGroup() {
        if currentUser == roomChat!.ovnerGroup {
            addButtonUser.isHidden = false
            addButtonUser.isEnabled = true
            editButtonUser.isEnabled = true
            editButtonUser.tintColor = nil
        } else {
            addButtonUser.isHidden = true
            addButtonUser.isEnabled = false
            editButtonUser.isEnabled = false
            editButtonUser.tintColor = UIColor.clear
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if currentUser == roomChat!.ovnerGroup {
            updateGroupIntoFirebase()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func addUserButtonClick(_ sender: Any) {
        
        let groupMC = self.storyboard?.instantiateViewController(withIdentifier: "GroupMessageController") as! GroupMessageController
        groupMC.delegate = self
        groupMC.currentLisrUser = userArray
        self.navigationController?.pushViewController(groupMC, animated: true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func updateGroupIntoFirebase() {
         self.activityIndicator?.startAnimating()
        Storage.storage().reference().child("group_images")
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("group_images").child("\(imageName).png")
      
        if let uploadData = self.imageGroup.image?.lowQualityJPEGNSData {

            let ref = Database.database().reference().child("chat-romm").child(self.unicKyeForChatRoom).child("users")
            ref.removeValue()
            for us in self.userArray {
                let ch = ref.childByAutoId()
                let v = ["toId" : us.userId]
                ch.updateChildValues(v)
            }
            storageRef.putData(uploadData as Data as Data, metadata: nil, completion: { (metadata, err) in
                if err != nil{
                    
                    self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                    return
                }
                if let meta = metadata?.downloadURL()?.absoluteString {
                    
                    let value = ["nameGroup": self.nameGroup?.text, "groupImageUrl" : meta] as [String : Any]
                    let ref = Database.database().reference().child("chat-romm").child(self.unicKyeForChatRoom)
                    ref.updateChildValues(value, withCompletionBlock: { (err, data) in
                        
                        if err != nil{
                            self.present(self.allertControllerWithOneButton(message: err!.localizedDescription), animated: true, completion: nil)
                            return
                        }
                        
                        for us in self.userArray {
                            let ref2 = Database.database().reference().child("chat-romm").child(self.unicKyeForChatRoom).child("users").childByAutoId()
                            ref2.updateChildValues(["toId" :us.uid])
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            self.activityIndicator?.stopAnimating()
                            self.navigationController?.popViewController(animated: true)
                        })
                    })
                }
            })
        }
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
        return 57
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          let us = userArray[indexPath.row].uid
          if us != currentUser && currentUser == roomChat!.ovnerGroup {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            userArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension DetailGroupControllerFromRoomChat: DetailGroupControllerDelegate {
    func getCheckUser(users: [User]) {
        users.forEach { (us) in
            self.userArray.append(us)
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
