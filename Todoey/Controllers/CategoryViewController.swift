import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories: [Category] = []
    let ctx = ((UIApplication).shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        load()
    }
    
    func save() {
        do {
            try self.ctx.save()
        } catch {
            print("Error saving with context")
        }
    }
    
    func load(with req: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try ctx.fetch(req)
        } catch {
            print("error fetching objects: \(error)")
        }
                
        tableView.reloadData()
    }

    @IBAction func addNewCategoryClicked(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let a = UIAlertController(title: "New", message: "Create a new category", preferredStyle: .alert)
        
     
        a.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new category"
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let i = Category(context: self.ctx)
            i.name = textField.text!
            
            self.categories.append(i)
                
            self.save()
            
            self.tableView.reloadData()
        }
        
        a.addAction(action)
        
        present(a, animated:true, completion: nil)
    }
        
    // MARK: Table View Data Sources
    
    // MARK: Table View Data Methods
    
    // MARK: Add Category
    
    // MARK: Table View Delegates
}

extension CategoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // Called on instantiation of the individual cells / on load
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let cat = categories[indexPath.row]
        cell.textLabel?.text = cat.name

        save()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = categories[indexPath.row]
 
        
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow
        {
            // Set the category for destination view controller
            dest.selectedCategory = categories[indexPath.row]
        }
        
    }
}
