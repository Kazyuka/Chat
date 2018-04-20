//
//  EditDetailGroupViewViewController.swift
//  TestChat
//
//  Created by Руслан Казюка on 20.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

class EditDetailGroupController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var imageGroup: UIImageView!
    
    var group: Group?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonClick(_ sender: Any) {
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
    }
}
