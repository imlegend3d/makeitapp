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
    var newCell = MyCell(frame: CGRect.zero)
    
    var selectedIndex: Int = 0
    
    var selectedToDetailVC: Bool = false
    
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
       
        // create and add uibarbutton with image to the navBar
       let shareButton = UIBarButtonItem( image: UIImage(named: "share3")?.withRenderingMode(.alwaysOriginal), style: .plain ,target: self, action: #selector(TodoListViewController.shareList))
        
        editButtonItem.action = #selector(edit)
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem, shareButton]
        
        //SearchBar setup
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        self.view.addSubview(tableView)
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboaardWillCahnge(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboaardWillCahnge(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboaardWillCahnge(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color{
            
            navigationController?.navigationBar.prefersLargeTitles = true
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            navBar.barTintColor = UIColor(hexString: colorHex)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: UIColor(hexString: colorHex), returnFlat: true)]
            navBar.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: colorHex), returnFlat: true)
            
            searchBar.barTintColor = UIColor(hexString: colorHex)
            //tableView.backgroundColor = UIColor(hexString: colorHex)
            tableView.backgroundColor = FlatBlack()
        }
    }
    
    @objc func longPresseGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer){
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
       // let locationInView = longPress.location(in: tableView)
        //let indexPath = tableView.indexPathForRow(at: locationInView)
        
        switch state {
        case UIGestureRecognizer.State.began:
            edit()

        default:
            print("default")
        }
        
    }
    
    //MARK: - Share list
    
    @objc func shareList(){
        let contactsVC = ContactsViewController()
        contactsVC.category = self.selectedCategory
        navigationController?.pushViewController(contactsVC, animated: true)
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
                            newItem.color = currentCategory.color
                            if currentCategory.items.isEmpty{
                                newItem.order = 0
                                currentCategory.items.append(newItem)
                            } else {
                                newItem.order = currentCategory.items.count + 1
                                currentCategory.items.append(newItem)
                            }
                            self.tableView.reloadData()
                        }
                    } catch  {
                        print("Error saving new item, \(error)")
                    }
                }
            }
           self.tableView.isScrollEnabled = true
            
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
           //updateCell(tableView, at: selectedIndex)
            loadItems()
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemResults?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MyCell
        
        cell.delegate = self
        cell.nameLabel.font = UIFont(name: "Marker Felt", size: 23)
        cell.nameLabel.numberOfLines = 0
        
        if let item = itemResults?[indexPath.row] {
            let text = item.title
            
            //StrikeThrough line by checking on the done property of the cell
            if item.done {
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
                cell.nameLabel.attributedText = attributedString
                
            } else {
                let notDoneString = NSMutableAttributedString(string: text)
                notDoneString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, notDoneString.length))
                cell.nameLabel.attributedText = notDoneString
            }
            
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
        
        selectedIndex = indexPath.row
        // add cell and textfiled to the tableview when tapped - it displays the detail button and the cell can be edited.
            if let originalCellLbl = tableView.cellForRow(at: indexPath) {
                
                newCell.frame = originalCellLbl.frame
                let textFieldPlace = CGRect(x: (originalCellLbl.frame.origin.x + 8), y:           originalCellLbl.frame.origin.y, width: (originalCellLbl.frame.width - 50), height: originalCellLbl.frame.height)
                myTextField = UITextField(frame: textFieldPlace)
                myTextField.font = UIFont(name: "Marker Felt", size: 23)
                myTextField.text = itemResults?[indexPath.row].title
                myTextField.backgroundColor = tableView.cellForRow(at: indexPath)?.backgroundColor
                myTextField.textColor = ContrastColorOf(backgroundColor: (tableView.cellForRow(at: indexPath)?.backgroundColor)!, returnFlat: true)
                myTextField.becomeFirstResponder()
                myTextField.delegate = self
                
                newCell.accessoryType = .detailButton
                
                tableView.addSubview(newCell)
                tableView.addSubview(myTextField)
                
            }
    
        tableView.deselectRow(at: indexPath, animated: true)
        
        loadItems()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        showDetailVC(at: indexPath)
    }
    
    func showDetailVC(at index: IndexPath){
        let detailViewController = DetailViewController()
        detailViewController.item = selectedCategory?.items[index.item]
        navigationController?.pushViewController(detailViewController, animated: true)
        //navigationController?.showDetailViewController(detailViewController, sender: self)
    }
    
    //MARK: - Update Cell
    
    func updateCell(_ tableView: UITableView, at indexpathRow: Int){
        
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
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}

extension TodoListViewController: UISearchBarDelegate{
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let queryResult = itemResults?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false){
        //let queryResult = realm.objects(Item.self).filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        let converted = queryResult.reduce(List<Item>()) { (list, element) -> List<Item> in
            list.append(element)
            return list
        }
        
        itemResults = converted
        }
        
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
        if orientation == .right {
            
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
            
        } else if orientation == .left {
            
                if let item = self.itemResults?[indexPath.row]{
                    // when the user swipes from left to right the done property changes and is saved.
                    do {
                        try self.realm.write {
                            item.done = !item.done
                        }
                    } catch {
                        print("Error crossing category, \(error)")
                    }
                }
           tableView.reloadData()
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeTableOptions()
        
        if orientation == .left {
            //none
        } else {
            options.expansionStyle = .destructive
            options.transitionStyle = .reveal
        }
        
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
    
    @objc func keyboaardWillCahnge(notification: Notification){
        //print("Keyboard will show: \(notification.name.rawValue)")
        tableView.isScrollEnabled = true
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardRect.height, right: 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets

        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardRect.height
                if (!aRect.contains(myTextField.frame.origin)){
                    tableView.scrollRectToVisible(myTextField.frame, animated: false)
                }
        // view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
            //var info = notification.userInfo!
            //let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
            tableView.isScrollEnabled = true
            view.endEditing(true)
        }
    }
    
    func hideKeyBoard(){
        selectedToDetailVC = false
         myTextField.resignFirstResponder()
        newCell.removeFromSuperview()
        myTextField.removeFromSuperview()
    }
    
}
