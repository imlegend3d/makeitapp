//
//  Service.swift
//  makeitapp
//
//  Created by David on 2019-07-12.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import LBTAComponents

class Service {
    static let baseColor = UIColor(r: 254, g: 202, b: 64)
    static let darkBaseColor = UIColor(r: 253, g: 166, b: 47)
    static let unselectedItemColor = UIColor(r: 173, g: 173, b: 173)
    
    static let buttonFontSize: CGFloat = 16
    static let buttonTitleColor = UIColor.white
    static let buttonBackgroundColor = UIColor(r: 54, g: 54, b: 54)
    static let buttonCornerRadius: CGFloat = 7
    
    static func showAlert(on:UIViewController, style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)], completion: (()->Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: style)

        for action in actions {
            alert.addAction(action)
        }
        on.present(alert,animated: true, completion: nil)
    }
}
