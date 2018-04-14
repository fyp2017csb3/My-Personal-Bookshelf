//
//  SearchResultTableViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 28/2/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit

class SearchResultTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var searchResultArray = [Books]()
    var books = [Books]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("get book list")
        print(searchResultArray[0].title)
        
        for i in 0..<searchResultArray.count {
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                //Update
                books[selectedIndexPath.row] = searchResultArray[i]
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
                
            else
            {   //Add
                let newIndexPath = IndexPath(row: books.count, section: 0)
                books.append(searchResultArray[i])
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        
        print(books.count)
        print(books[0].title)
        
        
        /*
        //Sample
        let sample1 = Books(title: "whatever", author: "whoever", photo: #imageLiteral(resourceName: "sampleBook1"), rating: 0, describeText: "")
        let sample2 = Books(title: "whatever", author: "whoever", photo: #imageLiteral(resourceName: "sampleBook2"), rating: 0, describeText: "")
        let sample3 = Books(title: "whatever", author: "whoever", photo: #imageLiteral(resourceName: "sampleBook3"), rating: 0, describeText: "")
        books += [sample1!, sample2!, sample3!]
        */
 
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchResultTableViewCell else {
            fatalError("The dequeued cell is not an instance of SearchResultTableViewCell.")
        }
        
        let book = books[indexPath.row]
        
        cell.titleLabel.text = book.title
        cell.authorLabel.text = "Author: " + book.author
        cell.ImageView.image = book.photo
        
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        
        guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
            fatalError("Unexpected Destination: \(segue.destination)")
        }
        
        guard let selectedBookCell = sender as? SearchResultTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
            fatalError("The selected cell is not displayed by the table")
        }
        
        let selectedBook = books[indexPath.row]
        bookDetailViewController.book = selectedBook
    }
    

}
