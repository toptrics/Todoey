//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray:[ToDoItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category?{
        didSet{
            loadItems()

        }
    }
    
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.reloadData()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK: - TableViewDataSource
    
            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return itemArray.count
            }
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
                cell.textLabel?.text = itemArray[indexPath.row].item
                
                cell.accessoryType = itemArray[indexPath.row].checkStatus==true ? .checkmark : .none
                return cell
            }
    
   
    
    //MARK: - Table View Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].checkStatus = !itemArray[indexPath.row].checkStatus
         saveData()

        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        saveData()
    }
    
    //MARK: - Add new item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Item in Todoey", message: "", preferredStyle: .alert)
       
        let action = UIAlertAction(title: "Add Item", style: .default) { [self]
            (action) in
            if let text = textField.text{
                
                let newItem = ToDoItem(context: context)
                newItem.item = text
                newItem.checkStatus = false
                newItem.parentCategory = selectedCategory
                itemArray.append(newItem)
               saveData()
            }
        }
        alert.addTextField { alertTextField in
                   alertTextField.placeholder = "Create new Item"
                   textField = alertTextField
               }
        alert.addAction(action)
        present(alert, animated: true , completion: nil)
    }
    
//MARK :- Data Manipulation Methods
    func saveData(){
       
        do{
            try context.save()
        }catch{
            print("error while saving context\(error)")
        }
        
        tableView.reloadData()
    }
    func loadItems(with request :NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest() ,predicate :NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let optionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [optionalPredicate , categoryPredicate])
        }else{
            request.predicate = categoryPredicate
        }
//        request.predicate = categoryPredicate
        
        
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("error while reading data \(error)")
        }
        
    }
    
    
}
//MARK: - UISearchBar Delegate Method
extension ToDoListViewController :UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request :NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let predicate = NSPredicate(format: "item CONTAINS[cd] %@", searchBar.text!)
        
        let sortDiscriptor = NSSortDescriptor(key: "item", ascending: true)
        request.sortDescriptors = [sortDiscriptor]
        
        loadItems(with : request , predicate : predicate)
        tableView.reloadData()
        }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
       
    }
}



