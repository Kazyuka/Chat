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


extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
}


extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) 
        self.layer.masksToBounds = true
    }
}

extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UITextField {
   
    func changeColor(textForPlaceHoder: String , size: CGFloat) {
        self.attributedPlaceholder = NSAttributedString(string: textForPlaceHoder,
                                                        attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.4274509804, green: 0.4274509804, blue: 0.4274509804, alpha: 1), NSAttributedStringKey.font : UIFont(name: "Arial", size: size)!])
    }
}


extension UIViewController {
    
    func textByCenterSearchController(searchController: UISearchController, space: CGFloat) {
        
        var offset = UIOffset()
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone)
        {
            offset = UIOffset(horizontal: (searchController.searchBar.frame.width  / 2) - space , vertical: 0)
            searchController.searchBar.setPositionAdjustment(offset, for: .search)
        } else {
            offset = UIOffset(horizontal: (searchController.searchBar.frame.width  / 2) + 160 , vertical: 0)
            searchController.searchBar.setPositionAdjustment(offset, for: .search)
        }
    }
}