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

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

   
    let realm = try! Realm()
    
    private let cellId = "cellId"
    // private let headerId = "headerId"
    // private let searchBarheight: Int = 40
    
    //var itemResults: Results<Item>?
    var itemResults: List<Item>?
    //var itemResults: AnyRealmCollection<Item>!
    
    let searchBar = UISearchBar()
    let tableView: UITableView = UITableView()
    
    var selectedCategory: Category? {
        didSet{
           loadItems()
        }
    }
    
    var myTextField : UITextField = UITextField(frame: CGRect.zero)
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TodoListViewController.longPresseGestureRecognizer(_:)))
        tableView.addGestureRecognizer(longPress)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TodoListViewController.addItems))
        
         editButtonItem.action = #selector(edit)
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        //SearchBar setup
        
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        self.view.addSubview(tableView)
        
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
    
    @objc func longPresseGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer){
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        //let indexPath = tableView.indexPathForRow(at: locationInView)
        
        switch state {
        case UIGestureRecognizer.State.began:
            edit()
            //        case UIGestureRecognizer.State.changed:
            //
            //        case UIGestureRecognizer.State.cancelled:
            //        case .ended:
        //            edit()
        default:
            print("default")
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
                            if currentCategory.items.isEmpty{
                                newItem.order = 0
                                currentCategory.items.append(newItem)
                            } else {
                                newItem.order = currentCategory.items.count + 1
                                currentCategory.items.append(newItem)
                            }
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
    
    //MARK: - Save item
    
    
    //MARK: - Load Items 
    
    func loadItems(){
        
        //itemResults = selectedCategory?.items.sorted(byKeyPath: "order", ascending: true)

        itemResults = selectedCategory?.items

        
        tableView.reloadData()
    }
    
    //MARK: - Edit methods
    @objc func edit(){
        tableView.isEditing = !tableView.isEditing
        
        switch tableView.isEditing {
        case true:
            editButtonItem.title = "Done"
        case false:
            editButtonItem.title = "Edit"
            hideKeyBoard()
            loadItems()
        }
        
        for item in (selectedCategory?.items)!{
            print("Order #\(item.order)")
        }
        
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
          
            try! realm.write {
            item.order = indexPath.row
            }
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:(CGFloat(indexPath.row) / CGFloat(itemResults!.count))) {
                cell.backgroundColor = color
                cell.nameLabel.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
            }
            
            //value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.nameLabel.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        edit()
        
        selectedIndex = indexPath.row
        
        print("index:\(indexPath.row), order# \(selectedCategory!.items[indexPath.row].order)")
        
            if let originalTextLbl = tableView.cellForRow(at: indexPath) {
                let textFieldPlace: CGRect = originalTextLbl.frame
                myTextField = UITextField(frame: textFieldPlace)
                //let item = itemResults?[indexPath.row]
                myTextField.text = itemResults?[indexPath.row].title
                myTextField.backgroundColor = tableView.cellForRow(at: indexPath)?.backgroundColor
                myTextField.textColor = ContrastColorOf(backgroundColor: (tableView.cellForRow(at: indexPath)?.backgroundColor)!, returnFlat: true)
                myTextField.becomeFirstResponder()
                tableView.addSubview(myTextField)
                myTextField.delegate = self
            }
        
 // Done check funtionality to be move somewhere else.
//        if let item = itemResults?[indexPath.row] {
//            do{
//                try realm.write {
//                    item.done = !item.done
//                }
//            } catch {
//                print("Error saving done status, \(error)")
//            }
//        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        loadItems()
    }
    
    func updateCell(_ tableView: UITableView, at indexpathRow: Int){
        print("Fuckkkk")
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm.write {
                    let newItem = currentCategory.items[indexpathRow]
                    newItem.title = myTextField.text!
                    newItem.dateCreated = Date()
                    newItem.order = currentCategory.items[indexpathRow].order
                    currentCategory.items.replace(index: indexpathRow, object: newItem)
                
                }
            } catch  {
                print("Error updating new item, \(error)")
            }
        }
        loadItems()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath != destinationIndexPath{

        try! realm.write {
            
            itemResults?.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            
            }
        }
        loadItems()
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}

extension TodoListViewController: UISearchBarDelegate{
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        itemResults = itemResults?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        let queryResult = realm.objects(Item.self).filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        let converted = queryResult.reduce(List<Item>()) { (list, element) -> List<Item> in
            list.append(element)
            return list
        }
        
        itemResults = converted
        
        //itemResults =
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

extension TodoListViewController: UITextFieldDelegate{
    //TextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       hideKeyBoard()
        updateCell(tableView, at: selectedIndex)
        if tableView.isEditing{
            tableView.setEditing(false, animated: true)
        }
        return true
    }
    
    func hideKeyBoard(){
        
         myTextField.resignFirstResponder()
        myTextField.removeFromSuperview()
    }
    
}
