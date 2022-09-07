import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var items: [TodoItem] = []
    var selectedCategory: Category? {
        // As soon as selected category is set, run this..
        didSet{
            load()
        }
    }
    
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
            i.parentCategory = self.selectedCategory
            
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
    
    func load(with req: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPred = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let pred = predicate {
            // Create a compiund predicate using the values passed to this function
            req.predicate =  NSCompoundPredicate(andPredicateWithSubpredicates:
                                                    [pred, categoryPred])
        } else {
            // Load everythign associated with this category
            req.predicate = categoryPred
        }
        
        do {
            items = try ctx.fetch(req)
        } catch {
            print("error fetching objects: \(error)")
        }
                
        tableView.reloadData()
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

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Reload the tableview with text for query
        
        let req: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        
        // TODO: sanitize input
        let searchText = searchBar.text
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText!)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        load(with: req, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            load()
            
            // Dismiss the keyboard after clicking
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

