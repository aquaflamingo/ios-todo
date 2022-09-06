import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var items: [TodoItem] = []
    let defaults = UserDefaults()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let ctx = ((UIApplication).shared.delegate as! AppDelegate).persistentContainer.viewContext
            
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let a = UIAlertController(title: "New", message: "Create a new item", preferredStyle: .alert)
        
     
        a.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new item"
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let i = TodoItem(context: self.ctx)
            i.title = textField.text!
            i.done = false
            
            self.items.append(i)
                
            self.save()
            
            self.tableView.reloadData()
        }
        
        a.addAction(action)
        
        present(a, animated:true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        load()
    }
    
    func save() {
        do {
            try self.ctx.save()
        } catch {
            print("Error saving with context")
        }
    }
    
    func load() {
        let req : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        do {
            items = try ctx.fetch(req)
        } catch {
            print("error fetching objects: \(error)")
        }
    }
}

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Called on instantiation of the individual cells / on load
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none

        save()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
 
        let isDone = item.done
        
        items[indexPath.row].done = !isDone
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

