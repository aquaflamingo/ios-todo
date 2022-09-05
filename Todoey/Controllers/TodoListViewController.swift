import UIKit

class TodoListViewController: UITableViewController {
    
    var items: [TodoItem] = []
    let defaults = UserDefaults()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let a = UIAlertController(title: "New", message: "Create a new item", preferredStyle: .alert)
        
     
        a.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new item"
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let i = TodoItem(textField.text!, false)
            
            self.items.append(i)
                
            self.save()
            
            self.tableView.reloadData()
        }
        
        a.addAction(action)
        
        present(a, animated:true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items.append(TodoItem("TODO1", false))
        items.append(TodoItem("TODO2", false))
        items.append(TodoItem("TODO3", false))
        
        load()
    }
    
    func save() {
        let encoder  = PropertyListEncoder()
        do {
            let d = try encoder.encode(self.items)
            try d.write(to: self.dataFilePath!)
        } catch { print("failed to save to file ")}
    }
    
    func load() {
        if let d = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([TodoItem].self, from: d)
            } catch {
                print("failed to deserialize")
            }
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

