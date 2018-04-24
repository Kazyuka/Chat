//
//  GroupMessageController.swift
//  TestChat
//
//  Created by Руслан Казюка on 12.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class GroupMessageController: ContactsSingleMessageController {

    var checkUsers = [User]()
    var currentLisrUser = [User]()
    
    weak var delegate: DetailGroupControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentLisrUser)
        
    }
    @IBAction func saveButtonClick(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.getCheckUser(users: self.checkUsers)
        }
    }
    
    override func getAllUser() {
        
        
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            print(snapshot)
            
            if let users = snapshot.value as? [String: AnyObject] {
                
            }
        }
       /* Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let users = snapshot.value as? [String: AnyObject] {
                let user = User.init(dic: users)
                user.userId = snapshot.key
                if Auth.auth().currentUser?.uid != user.userId {
                    print(user)
                    self.userArray.append(user)
                }
            }
            
            
            
            for u in self.currentLisrUser {
                
               var arr = self.userArray.filter { $0.userId != u.userId }
            }*/
           
           /* for u in self.userArray {
                
                if let idx =  self.currentLisrUser.index(of: u) {
                    
                    print(idx)
                    self.userArray.remove(at: idx)
                    
                }
            }*/
           /* self.tableView.reloadData()
        }, withCancel: nil)*/
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.userArray[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                let indexToDelete = checkUsers.index(of: user)
                checkUsers.remove(at: indexToDelete!)
            } else {
                cell.accessoryType = .checkmark
                checkUsers.append(user)
            }
        }
    }
}

