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

class DetailGroupController: UIViewController {

    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var imageGroupView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var userArray = [User]()
    var group: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        nameGroup.text = group?.groupName
        if let im = group?.imageGroup {
            let url = NSURL.init(string: im)
            self.imageGroupView.sd_setImage(with: url! as URL)
        }
    }
    @IBAction func addUsersButtonClick(_ sender: Any) {
        let groupMC = self.storyboard?.instantiateViewController(withIdentifier: "GroupMessageController") as! GroupMessageController
        groupMC.delegate = self
        self.present(groupMC, animated: true, completion: nil)
    }
    
    @IBAction func chatButtonClick(_ sender: Any) {
        
        let ref = Database.database().reference().child("group-messages").child(group!.groupUID!).child("users-group")
        
        for us in userArray {
            let ch = ref.childByAutoId()
            let v = ["toId" : us.userId]
            ch.setValue(v)
            
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func editButtonClick(_ sender: Any) {
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
        if editingStyle == .delete {
            userArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}


extension DetailGroupController: DetailGroupControllerDelegate {
    func getCheckUser(users: [User]) {
        userArray.removeAll()
        userArray = users
        self.tableView.reloadData()
    }
}
