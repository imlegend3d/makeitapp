//
//  TodoListViewController.swift
//  makeitapp
//
//  Created by David on 2019-04-03.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   
    let realm = try! Realm()
    
    private let cellId = "cellId"
    // private let headerId = "headerId"
    // private let searchBarheight: Int = 40
    
    var itemResults: Results<Item>?
    
    let searchBar = UISearchBar()
    let tableView: UITableView = UITableView()
    
    var selectedCategory: Category? {
        didSet{
           loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        //tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: headerId)
        //tableView.sectionHeaderHeight = 50
        //navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TodoListViewController.addItems))
        
        //SearchBar setup
        
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        self.view.addSubview(tableView)
        //self.view.addSubview(searchBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color{
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            navBar.barTintColor = UIColor(hexString: colorHex)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: UIColor(hexString: colorHex), returnFlat: true)]
            navBar.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: colorHex), returnFlat: true)
            
            searchBar.barTintColor = UIColor(hexString: colorHex)
        }
    }
    
    //MARK - Add new items
    
    @objc func addItems(){
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New List Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what happens once button is pressed.
            if textField.text != "" {
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch  {
                        print("Error saving new item, \(error)")
                    }
                }
                self.tableView.reloadData()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert,animated: true, completion: nil)
    }
    
    //MARK: - Load Items 
    
    func loadItems(){
        
        itemResults = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemResults?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MyCell
        
        cell.delegate = self
        
        if let item = itemResults?[indexPath.row] {
            cell.nameLabel.text = item.title
        
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:(CGFloat(indexPath.row) / CGFloat(itemResults!.count))) {
                cell.backgroundColor = color
                //cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
                cell.nameLabel.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
            }
            
            //value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.nameLabel.text = "No Items Added"
        }
        
        return cell
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId)
//    }
    
    //MARK - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemResults?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
            
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//            if let item = itemResults?[indexPath.row] {
//                do{
//                    try realm.write {
//                        realm.delete(item)
//                    }
//                } catch {
//                    print("Error deleting item, \(error)")
//                }
//            }
//        }
//        tableView.reloadData()
//    }
}

extension TodoListViewController: UISearchBarDelegate{
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemResults = itemResults?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension TodoListViewController: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let item = self.itemResults?[indexPath.row]{
                do {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                } catch {
                    print("Error deleting category, \(error)")
                }
            }
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .reveal
        
        return options
    }
}
