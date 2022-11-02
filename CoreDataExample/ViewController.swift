//
//  ViewController.swift
//  CoreDataExample
//
//  Created by User on 2/11/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]().self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        getAllItems()
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapBarAdd))
    }
    
    @objc private  func didTapBarAdd(){
        let alerController = UIAlertController(title: "Add New Item", message: "Enter new item for to do list!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _ in
            guard let textField = alerController.textFields?.first, let text = textField.text, !text.isEmpty  else{
                return
            }
            
            self?.createItem(name: text)
        })
        alerController.addTextField(configurationHandler: nil)
        alerController.addAction(action)
        
        present(alerController, animated: true, completion: nil)
    }
    
    
//    MARK: TableView configurations
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(model.name!) "
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet   = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Cancel ", style: .cancel, handler: nil)
        let editAction = UIAlertAction(title: "Edit ", style: .default, handler: {_ in
            let alerController = UIAlertController(title: "Edit Item", message: "Edit your item!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Save", style: .cancel, handler: {[weak self] _ in
                guard let textField = alerController.textFields?.first, let newName = textField.text, !newName.isEmpty else{
                    return
                }
                
                self?.updateItem(item: item, newName: newName)
                
            })
            alerController.addTextField(configurationHandler: nil)
            alerController.textFields?.first?.text = item.name
            alerController.addAction(action)
            
            self.present(alerController, animated: true)
        })
        let deleteAction = UIAlertAction(title: "Delete ", style: .destructive, handler: {[weak self] _ in
            self?.deleteItem(item: item)
        })
        
        sheet.addAction(editAction)
        sheet.addAction(deleteAction)
        sheet.addAction(action)
        
        present(sheet , animated: true, completion: nil)
        
    }
    
    
//    MARK: Core Data implementations
//    MARK: Get All Items
    func getAllItems(){
        do{
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async { [self] in
                self.tableView.reloadData()
            }
                
        }catch{
            //error
        }
    }
// MARK: Create new Item
    func createItem(name: String){
        
        let newItem = ToDoListItem(context: context)
        
        newItem.name = name
        newItem.createdAt = Date()
        
        do{
            try context.save()
            getAllItems()
        }catch{
            //error
        }
        
    }
    
    
//    MARK: Delete the Item
    
    func deleteItem(item: ToDoListItem){
        context.delete(item)
        do{
            try context.save()
            getAllItems()
        }catch{
            //error
        }
    }
    
    
//    MARK: Update the Item
    func updateItem(item: ToDoListItem, newName: String){
        item.name = newName
        
        do{
            try context.save()
            getAllItems()
        }catch{
            //error
        }
    }
}

