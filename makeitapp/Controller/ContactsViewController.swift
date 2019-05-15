//
//  ContactsViewController.swift
//  makeitapp
//
//  Created by David on 2019-05-11.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import ChameleonFramework

struct expandableContacts{
    
    var isExpanded: Bool
    var names: [Contact]
    
}

struct Contact {
    let name : String
    var isShared: Bool
}

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var category: Category?
    
    let tableView: UITableView = UITableView()
    
    let cellID = "cell"
    
    var contacts = [
        expandableContacts(isExpanded: true, names: [Contact(name: "Luisa", isShared: false), Contact(name: "Fernanda", isShared: false), Contact(name: "Cuddles", isShared: false)]),
        expandableContacts(isExpanded: true, names: ["Diana","Carolina", "Karen", "Paola", "Eliabeth", "Jose"].map{Contact(name: $0, isShared: false)}),
        expandableContacts(isExpanded: true, names: ["Cristina", "Chimoltrufia", "Alexander", "Alexandra aka Popo"].map{Contact(name: $0, isShared: false)})
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FlatBlack()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellID)
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let btn = UIButton(type: .system)
        btn.setTitle("Close", for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.titleLabel?.font = UIFont(name: "Marker Felt", size: 16)
        btn.setTitleColor(.black, for: .normal)
        
        btn.addTarget(self, action: #selector(expandClose), for: .touchUpInside)
        
        btn.tag = section
        
        return btn
    }
    
    @objc func expandClose(button: UIButton){
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        for row in contacts[section].names.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let expanded = contacts[section].isExpanded
        contacts[section].isExpanded = !expanded
        
        button.setTitle(expanded ? "Open" : "Close", for: .normal)
        
        if expanded {
            tableView.deleteRows(at: indexPaths , with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        
    }
    
    // method called by shareLiostButton in the cell to share the list with contacts
    func shareListWithFriends(cell: UITableViewCell){
        guard let indexPathTapped = tableView.indexPath(for: cell) else {return}
        
        let contact = contacts[indexPathTapped.section].names[indexPathTapped.row]
        print(contact)
        
        let isShared = contact.isShared
        contacts[indexPathTapped.section].names[indexPathTapped.row].isShared = !isShared
        
        cell.accessoryView?.tintColor = isShared ? FlatGray() : FlatPurple()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !contacts[section].isExpanded {
            return 0
        }
        return contacts[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ContactCell
        
        cell.link = self
        
        let contact = contacts[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = contact.name
        
        cell.accessoryView?.tintColor = contact.isShared ? FlatPurple() : FlatGray()
        
        return cell
    }
    



}
