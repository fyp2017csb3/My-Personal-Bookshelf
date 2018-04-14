//
//  BooksTableViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log

class FdsTableViewController: UITableViewController, UISearchBarDelegate {

    
    
    
    //MARK: Properties
    var fds = [User]()
    
    var isSearching = false
    
    
    //MARK: Actions
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        self.fds = self.sortName()
        self.tableView.reloadData()
        self.saveFds()
    }
    
    
    //MARK: Private Methods
    private func loadSampleBooks()-> [User]? {
        let photo1 = UIImage(named: "sampleBook1")
        let photo2 = UIImage(named: "sampleBook2")
        let photo3 = UIImage(named: "sampleBook3")
        
        guard let fd1 = User(name: "friend1", UID: "UID1", photo: photo1) else {
            fatalError("Unable to instantiate book1")
        }
        guard let fd2 = User(name: "friend2", UID: "UID2", photo: photo1) else {
            fatalError("Unable to instantiate book1")
        }
        guard let fd3 = User(name: "friend3", UID: "UID3", photo: photo1) else {
            fatalError("Unable to instantiate book1")
        }
        var temp = [fd1, fd2, fd3]
        return temp
        
    }
    
    private func saveFds() {
            let successfulSave = NSKeyedArchiver.archiveRootObject(fds, toFile: User.FdsArchiveURL.path)

        
        //        if successfulSave {
        //            os_log("Books is saved.", log: OSLog.default, type: . debug)
        //        }
        //        else
        //        {
        //            os_log("Failed to save book", log: OSLog.default, type: .error)
        //        }
    }
    
    private func loadFds() -> [User]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: User.FdsArchiveURL.path) as? [User]
    }
    
    //MARK: SORTING
    private func sortName() -> [User] {
        let sortedArr = fds.sorted(by: {$0.name < $1.name})
        return sortedArr
    }
    
    @objc func showProfile() {
        print("My Profile")
    }
    
    @objc func addFd() {
        print("add Friend")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "My Profile", style: .plain, target: self, action: #selector(showProfile))
        
        var navItems = [UIBarButtonItem]()
        
        
        navItems.append(UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addFd)))
        navItems.append(UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortButton)))
        navigationItem.setRightBarButtonItems(navItems, animated: true)
        
        
     
        
        //Load saved books else sample
        if let savedFds = loadFds() {
            fds += savedFds
        }
        else {
            fds = loadSampleBooks()!
        }
    }
    

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fds.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "FdsTableViewCell", for: indexPath) as! FdsTableViewCell
        
        var fd = fds[indexPath.row]
        
        cell.userName.text = fd.name
        cell.userImg.image = fd.photo
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            fds.remove(at: indexPath.row)
            saveFds()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowFd":
            guard let booksTableViewController = segue.destination as? BooksTableViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let selectedFdCell = sender as? FdsTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedFdCell) else {
                fatalError("The selected cell is not displayed by the table")
            }
            
            let selectedFd = fds[indexPath.row]
            booksTableViewController.reader = selectedFd
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
}

