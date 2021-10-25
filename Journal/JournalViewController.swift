//
//  ViewController.swift
//  Journal
//
//  Created by Kevin Lagat on 25/10/2021.
//

import UIKit
import CoreData

class JournalViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var myPredicate: NSPredicate?

    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var journal = [Journal]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Journals"
        tableView.dataSource = self
        tableView.delegate = self
        do {
            let journal = try managedObjectContext.fetch(Journal.fetchRequest())
        } catch {
            print("Error \(error)")
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchJournalEntries()
    }
    
    @IBAction func addJournal(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Entry",
                                      message: "Add a new journal entry",
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default)
        {
            _ in
            let textField = alert.textFields![0]
            let newJournalEntry = Journal(context: self.managedObjectContext)
            newJournalEntry.title = textField.text!
            newJournalEntry.topic = "Stuff I do everyday"
            newJournalEntry.createdAt = Date() as Date?
            self.saveJournalEntries()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveJournalEntries() {
        do {
            try managedObjectContext.save()
            print("Save successful")
        } catch {
            print("Error \(error)")
        }
        fetchJournalEntries()
        
    }
    
    func fetchJournalEntries() {
        do {
            journal = try managedObjectContext.fetch(Journal.fetchRequest())
            print("Success")
        } catch {
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
    
}

extension JournalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let journalItem = journal[indexPath.row]
        cell.textLabel!.text = journalItem.title
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journal.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        managedObjectContext.delete(journal[indexPath.row])
        self.saveJournalEntries()
    }
}


extension JournalViewController {
    
    func getUsingPredicate() {

        let fetchRequest:NSFetchRequest<Journal> = Journal.fetchRequest()

        let date = Date()
        
        let firstPredicate = NSPredicate(format: "isCompleted == true")
        let secondPredicate = NSPredicate(format: "createdAt < %@", date as CVarArg)

        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [firstPredicate, secondPredicate])
        
        do {
            try managedObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error: \(error)")
        }
    }
}

