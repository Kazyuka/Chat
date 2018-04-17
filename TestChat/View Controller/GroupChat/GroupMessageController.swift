//
//  GroupMessageController.swift
//  TestChat
//
//  Created by Руслан Казюка on 12.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

class GroupMessageController: ContactsSingleMessageController {

    var checkUsers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sendNewMessageButton = UIBarButtonItem(title: "Send message", style: .plain, target: self, action: #selector(sendMessageGroupUser))
        navigationItem.rightBarButtonItems = [sendNewMessageButton]
    }
    
    @objc func sendMessageGroupUser() {
        self.dismiss(animated: true) {
            self.messagesViewComtroller?.goToGrupChat(users: self.checkUsers)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.userArray[indexPath.row].userId
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                let indexToDelete = checkUsers.index(of: user!)
                checkUsers.remove(at: indexToDelete!)
            } else {
                cell.accessoryType = .checkmark
                checkUsers.append(user!)
            }
        }
    }
}

