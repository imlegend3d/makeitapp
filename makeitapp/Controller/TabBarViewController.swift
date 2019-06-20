//
//  TabBarViewController.swift
//  makeitapp
//
//  Created by David on 2019-06-20.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class TabBarViewController: UIViewController {

    var tabBarCtlr: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            displayTabViewControllers()
        
    }
    
    func displayTabViewControllers() {
        tabBarCtlr = UITabBarController()
        tabBarCtlr?.tabBar.barStyle = .black
        
        let contactsVC = ContactsViewController()
        contactsVC.title = "Contacts"
        
        
        let usersVC = UIViewController()
        usersVC.title = "Users"
        usersVC.view.backgroundColor = .yellow
        
        tabBarCtlr?.viewControllers = [contactsVC, usersVC]
        
        self.view.addSubview(tabBarCtlr!.view)
    }


}
