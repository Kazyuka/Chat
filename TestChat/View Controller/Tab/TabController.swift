//
//  TabController.swift
//  TestChat
//
//  Created by Руслан Казюка on 16.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

class TabController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 0
    
    static var isLanguageChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TabController.isLanguageChange {
            selectedIndex = 3
        } else {
            selectedIndex = defaultIndex
        }
        
        if let items = self.tabBar.items {
            items.forEach({ (item) in
                if item.tag == 0 {
                    item.title = "Contacts".localized
                } else if item.tag == 1 {
                    item.title = "Chats".localized
                } else if item.tag == 2 {
                    item.title = "Profile".localized
                } else if item.tag == 3 {
                    item.title = "Settings".localized
                }
            })
        }
    }
}
