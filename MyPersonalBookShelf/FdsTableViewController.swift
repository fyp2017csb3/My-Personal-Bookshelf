//
//  BooksTableViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log
import Firebase

class FdsTableViewController: UITableViewController, UISearchBarDelegate {

    
    
    
    //MARK: Properties
    var fds = [User]()
    
    var qrCode = ""
    
    var isSearching = false
    
    
    //MARK: Actions
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        self.fds = self.sortName()
        self.tableView.reloadData()
        self.saveFds()
    }
    
    @IBAction func unwindToFriendsList(sender: UIStoryboardSegue) {
        var code = qrCode
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("serial").child(code).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if let fdUID = dataSnapshot.value as? String
            {
                ref.child("users").child(fdUID).child("name").observeSingleEvent(of: .value, with: { (dataSnapshot2) in
                    let fdName = dataSnapshot2.value as! String
                    
                    let storageRef = Storage.storage().reference()
                    let imgURL = fdUID+"/propic"
                    storageRef.child(imgURL).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                        if(error == nil) {
                            let img = UIImage(data: data!)
                            let newfd = User(name: fdName, UID: fdUID, photo: img)
                            self.fds.append(newfd!)
                            print("added a fd from base")
                            self.tableView.reloadData()
                            self.saveFds()
                        }
                        else {
                            let newfd = User(name: fdName, UID: fdUID, photo: UIImage(named: "defaultBookImage"))
                            self.fds.append(newfd!)
                            print("added a fd from base")
                            self.tableView.reloadData()
                            self.saveFds()
                        }
                    }
                    )
                    
                })
                
                
                
            }
            else
            {
                let errorAlert = UIAlertController(title: "Friend not found", message: nil, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        })
    }
    
    
    //MARK: Private Methods
    
    private func saveFds() {
            let successfulSave = NSKeyedArchiver.archiveRootObject(fds, toFile: User.FdsArchiveURL.path)

    }
    
    private func loadFds() -> [User]? {
        if let fdss = NSKeyedUnarchiver.unarchiveObject(withFile: User.FdsArchiveURL.path) as? [User] {
            return fdss
        }
        return []
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
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Friend", message: "Input friend's serial number", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = " "
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            var code = "11111111"
            if textField?.text != "" || textField?.text != nil {
                code = (textField?.text!)!
            }
            var ref: DatabaseReference!
            ref = Database.database().reference()
            
            ref.child("serial").child(code).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                if let fdUID = dataSnapshot.value as? String
                {
                    ref.child("users").child(fdUID).child("name").observeSingleEvent(of: .value, with: { (dataSnapshot2) in
                        let fdName = dataSnapshot2.value as! String
                        
                        let storageRef = Storage.storage().reference()
                        let imgURL = fdUID+"/propic"
                        storageRef.child(imgURL).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                            if(error == nil) {
                                let img = UIImage(data: data!)
                                let newfd = User(name: fdName, UID: fdUID, photo: img)
                                self.fds.append(newfd!)
                                print("added a fd from base")
                                self.tableView.reloadData()
                                self.saveFds()
                            }
                            else {
                                let newfd = User(name: fdName, UID: fdUID, photo: UIImage(named: "defaultBookImage"))
                                self.fds.append(newfd!)
                                print("added a fd from base")
                                self.tableView.reloadData()
                                self.saveFds()
                            }
                        }
                        )
                       
                    })
                    
                    
                    
                }
                else
                {
                    let errorAlert = UIAlertController(title: "Friend not found", message: nil, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            })
            
            
        }))
        alert.addAction(UIAlertAction(title: "QR", style: .default, handler: { [weak alert] (_) in
            self.performSegue(withIdentifier: "ShowQRScanner", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var navItems = [UIBarButtonItem]()
        
        
        navItems.append(UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addFd)))
        navItems.append(UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortButton)))
        navigationItem.setRightBarButtonItems(navItems, animated: true)
        
        
     
        
        //Load saved books else sample
        fds = loadFds()!
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
        
        case "ShowProfile":
            break
            
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
            booksTableViewController.navigationItem.title = selectedFd.name + "'s Books"
            
        case "ShowQRScanner":
            break
            
        default:
            print(segue.identifier)
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
}

