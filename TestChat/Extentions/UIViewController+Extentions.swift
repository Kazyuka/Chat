//
//  UIViewController+Extentions.swift
//  TestChat
//
//  Created by Руслан Казюка on 16.04.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func allertControllerWithOneButton(message: String) -> UIAlertController {
        let alert = UIAlertController(title: " ", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
}

