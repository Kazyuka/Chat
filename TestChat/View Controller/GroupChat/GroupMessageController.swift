//
//  GroupMessageController.swift
//  TestChat
//
//  Created by Руслан Казюка on 12.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

class GroupMessageController: ContactsSingleMessageController {

    var checkUsers = [User]()
    weak var delegate: DetailGroupControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func saveButtonClick(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.getCheckUser(users: self.checkUsers)
        }
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

