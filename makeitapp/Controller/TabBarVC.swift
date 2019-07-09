//
//  TabBarViewController.swift
//  makeitapp
//
//  Created by David on 2019-06-20.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class TabBarVC: UIViewController, UITabBarControllerDelegate{

    var tabBarCtlr : UITabBarController?
//    var tabBar: UITabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarCtlr = UITabBarController()
        
        tabBarCtlr!.delegate = self
        displayTabViewControllers()
        
    }
    
    func displayTabViewControllers() {
    //set up tab bar

        let contactsVC = ContactsViewController()
        contactsVC.title = "Contacts"
        
        let usersVC = UsersViewController()
        usersVC.title = "Users"
        
        contactsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        usersVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let controllers = [contactsVC, usersVC]
        
        if let tabBar = tabBarCtlr {
           tabBar.viewControllers = controllers
            
            tabBar.viewControllers = controllers.map{ UINavigationController(rootViewController: $0)}
            
            self.view.addSubview(tabBar.view)
        }
        //setup navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Contacts"
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController){
        //modify navigation title on tab bar selection
        navigationItem.title = tabBarController.selectedViewController?.title
    }

}


