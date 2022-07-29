//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sunil Sharma on 26/07/22.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray = [Category]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {[self]
            (action) in
            if let text = textField.text{
                let newCategory = Category(context: context)
                newCategory.name = text
                categoryArray.append(newCategory)
                saveData()
            }
        }
        alert.addTextField { alertTextField in
                   alertTextField.placeholder = "Create new Category"
                   textField = alertTextField
               }
        alert.addAction(action)
        present(alert, animated: true , completion: nil)
        
    }
    //MARK: - Table View DataSource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    //MARK: - Table View Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Open Items of This Category
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let request :NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
//        request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryArray[indexPath.row])
//        do{
//            let items = try context.fetch(request)
//
//
//        }catch{
//            print("Problem while deleting \(error)")
//        }
        context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        saveData()
        
    }
    
    //MARK: - Data Manipulation Method
    
    func saveData(){
        do{
            try context.save()
        }catch{
            print("error while saving \(error)")
        }
        tableView.reloadData()
    }
    func loadCategory( with request:NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("error while reading data \(error)")
        }
    }
    
    
}
