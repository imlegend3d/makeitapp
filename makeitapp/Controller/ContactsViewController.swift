//
//  ContactsViewController.swift
//  makeitapp
//
//  Created by David on 2019-05-11.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import ChameleonFramework
import Contacts
import RealmSwift

struct expandableContacts{
    
    var isExpanded: Bool
    var names: [MyContact]
    
}

struct MyContact {
    let contact: CNContact
    var isShared: Bool
}

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var category: Category?
    
    let tableView: UITableView = UITableView()
    
    let cellID = "cell"
    
    let titleVC = "Contacts"
    
    var contacts: [expandableContacts] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContacts()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellID)
        
        view.addSubview(tableView)
        
    }
    
    
    func fetchContacts() {
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access", err)
                return
            }

            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]

                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

                do {
                    
                    var myContacts = [MyContact]()
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerStopEnumarating ) in
                        
                        myContacts.append(MyContact(contact: contact, isShared: false))
                    })
                    
                    let names = expandableContacts(isExpanded: true, names: myContacts)
                    
                    self.contacts = [names]
                    
                } catch let err {
                    print("Failed to enumarate contacts", err)
                }

            } else {
                print("Access denied")
            }
        }
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
        
        let isShared = contact.isShared
        contacts[indexPathTapped.section].names[indexPathTapped.row].isShared = !isShared
    
        cell.accessoryView?.tintColor = !isShared ? FlatPurple() : FlatGray()
      
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
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ContactCell
        
        let cell = ContactCell(style: .subtitle, reuseIdentifier: cellID)
        
        cell.link = self
        
        let cellContact = contacts[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = cellContact.contact.givenName + " " + cellContact.contact.familyName
        cell.textLabel?.font = UIFont(name: "Marker felt", size: 18)
       
        cell.detailTextLabel?.text = cellContact.contact.phoneNumbers.first?.value.stringValue
        
        cell.accessoryView?.tintColor = cellContact.isShared ? FlatPurple() : FlatGray()
        
        return cell
    }

}
