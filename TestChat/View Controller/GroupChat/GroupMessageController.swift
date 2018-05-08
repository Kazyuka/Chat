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
    var filterArrayUser = [User]()
    var idUsers = [String]()
    
    weak var delegate: DetailGroupControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    @IBAction func saveButtonClick(_ sender: Any) {
        self.delegate?.getCheckUser(users: self.checkUsers)
        self.navigationController?.popViewController(animated: true)
    }
    
    func filterUser() {
        
        var currentUserId = [String]()
        self.userArray.removeAll()
        self.currentLisrUser.forEach { (us) in
            currentUserId.append(us.uid!)
        }
        
        let differenceUser = idUsers.difference(from: currentUserId)
        for us in differenceUser {
            
            Database.database().reference().child("users").child(us).observeSingleEvent(of: .value, with: { (snap) in
                
                if let user = snap.value as? [String: AnyObject] {
                    
                    let u = user as! Dictionary <String, AnyObject>
                    let user = User.init(dic: u)
                    
                    if Auth.auth().currentUser?.uid != user.uid {
                        self.userArray.append(user)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    override func getAllUser() {
        
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            self.activityIndicator?.stopAnimating()
            if let users = snapshot.value as? [String: AnyObject] {
                for d in users {
                    
                    let user = User.init(dic: d.value as! Dictionary<String, AnyObject>)
                    if Auth.auth().currentUser?.uid != user.uid {
                        self.userArray.append(user)
                        self.idUsers.append(user.uid!)
                    }
                }
                
                if self.currentLisrUser.count > 1 {
                    self.filterUser()
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.userArray[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.5294117647, alpha: 1)
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


extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
