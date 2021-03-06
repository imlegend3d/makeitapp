//
//  TabBarViewController.swift
//  makeitapp
//
//  Created by David on 2019-06-20.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class TabBarVC: UIViewController {

    var tabBarCtlr : UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            displayTabViewControllers()
        
    }
    
    func displayTabViewControllers() {
        tabBarCtlr = UITabBarController()
        
        //tabBarCtlr?.tabBar.barStyle = .black
        
        let contactsVC = ContactsViewController()
        
        let usersVC = UsersViewController()
        
        //self.navigationController?.navigationBar.topItem?.title = "Users"
        
        contactsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        usersVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let controllers = [contactsVC, usersVC]
        
        if let tabBar = tabBarCtlr {
            //tabBar.viewControllers = controllers
            
            tabBar.viewControllers = controllers.map{ UINavigationController(rootViewController: $0)}
            
            self.view.addSubview(tabBar.view)
        }
        self.navigationController?.isNavigationBarHidden = true
        
    }

    func dismissVCs(){
        navigationController?.isNavigationBarHidden = false
        navigationController?.popViewController(animated: true)
    }
}


