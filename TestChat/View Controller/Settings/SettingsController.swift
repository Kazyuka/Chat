//
//  SettingsController.swift
//  TestChat
//
//  Created by Руслан Казюка on 18.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

class SettingsController: UIViewController {
    
    @IBOutlet weak var emailTextView: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var passworfTextField: UITextField!
    
    @IBOutlet weak var repeatPassword: UITextField!
    
    
    var langueages = ["English", "Русский"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.getCurrentUserFromFirebase { (user) in
            self.emailTextView.text = user.email
        }
    }

    @IBAction func logOutButtonClick(_ sender: Any) {
       
    }
    @IBAction func saveButtonClick(_ sender: Any) {
        
        let password = passworfTextField.text
        let rPassword = passworfTextField.text
        let email = emailTextView.text
        
        
    
        let firebaseUser = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email!, password: password!)
        firebaseUser?.reauthenticateAndRetrieveData(with: credential, completion: { (res, err) in
            if err != nil {
                print(err.debugDescription)
            }
            
        
        })
      
    }
}

extension SettingsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return langueages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = langueages[indexPath.row]
        return cell
    }
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
           
                cell.accessoryType = .checkmark
            }
        }
}

