//
//  MakeItViewController.swift
//  makeitapp
//
//  Created by David on 2019-04-01.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SwipeCellKit
import ChameleonFramework


class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    
    private let cellId = "cellId"
    //private let headerId = "headerId"
    
    var categories: Results<Category>?
    
    var color: String?
    
    let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        tableView.backgroundColor = FlatBlack()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyCell.self, forCellReuseIdentifier: cellId)
        //tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: headerId)
        //tableView.sectionHeaderHeight = 50
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CategoryViewController.longPresseGestureRecognizer(_:)))
        tableView.addGestureRecognizer(longPress)
        
        //tableView.setEditing(true, animated: true)
        self.view.addSubview(tableView)
       
        //Navigation Bar
        navigationItem.title = "MakeIt"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CategoryViewController.addItems))
        
        editButtonItem.action = #selector(edit)
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
       
        
        //Realm
        categories = realm.objects(Category.self).sorted(byKeyPath: "order")
    }
    
    @objc func edit(){
        tableView.isEditing = !tableView.isEditing

        switch tableView.isEditing {
        case true:
            editButtonItem.title = "Done"
        case false:
            editButtonItem.title = "Edit"
        }

    }
    
    @objc func longPresseGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer){
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)

        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.flatBlackColorDark()?.darken(byPercentage: 0.05)
        navigationController?.navigationBar.tintColor = ContrastColorOf(backgroundColor: FlatBlack(), returnFlat: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: FlatBlack(), returnFlat: true)]
    }
    
    //MARK - Add new category
    
    @objc func addItems(){
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New MakeIt Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what happens once button is pressed.
            if textField.text != "" {
                let newCategory = Category()
                if let color = UIColor.randomFlat()?.hexValue() {
                  newCategory.color = color
                }
                newCategory.name = textField.text!
                
                self.saveCategories(category: newCategory)
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
    
    //MARK: - Load Categories
    
    func loadCategories(){
    
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK - Tableview DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SwipeTableViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MyCell
        
        cell.delegate = self
        
        color = categories?[indexPath.row].color
        
        cell.backgroundColor = UIColor(hexString: color ?? "1D9BF6" )
        
        cell.nameLabel.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        cell.nameLabel.textColor = ContrastColorOf(backgroundColor: UIColor(hexString: color), returnFlat: true)
        
        //cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        
        return cell
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")
//    }
    
    //MARK - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemsArray[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
        
       showTodoListController(index: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        try! realm.write {
            
            guard let items = categories else {fatalError("Error seting order #s")}
                for cell in items{
                    cell.order += 1
                }
            
            
            let sourceObject = items[sourceIndexPath.row]
            let destinationObject = items[destinationIndexPath.row]
            
            let destinationObjectOrder = destinationObject.order
            
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = items[index]
                    object.order -= 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let object = items[index]
                    object.order += 1
                }
            }
            sourceObject.order = destinationObjectOrder
            categories = items
        }
      
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    //MARK: Func to next VC
    func showTodoListController(index: IndexPath){
        let todoVListViewController = TodoListViewController()
        todoVListViewController.selectedCategory = categories?[index.row]
        navigationController?.pushViewController(todoVListViewController, animated: true)
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(category: Category){
        do {
            try realm.write {
                realm.add(category)
                for cell in categories!{
                    cell.order += 1
                }
            }
        } catch {
            print("Error saving category data, \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: - Swipe Cell Delegate Methods
extension CategoryViewController: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let category = self.categories?[indexPath.row]{
                do {
                    try self.realm.write {
                        self.realm.delete(category)
                    }
                } catch {
                    print("Error deleting category, \(error)")
                }
//                tableView.reloadData()
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

class Header: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.flatBlack()
        label.text = "MakeIt - Categories"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
    
}

class MyCell: SwipeTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "MakeItApp"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
}
