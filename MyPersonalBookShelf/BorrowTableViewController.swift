//
//  BooksTableViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log

class BorrowTableViewController: UITableViewController, UISearchBarDelegate {
    
    var state = "borrow"
    

    
    //MARK: Properties
    var bbooks = [Books]()
    var lbooks = [Books]()
    var books = [Books]()
    var filteredArr = [Books]()
    
    var isSearching = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: Actions
    @IBAction func borrowButton(_ sender: Any) {
        let alert = UIAlertController(title: "Borrow Method", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Scan with QR", style: .default, handler: { (nil) in
            self.performSegue(withIdentifier: "ShowQR", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Input manually", style: .default, handler: { (nil) in
            self.performSegue(withIdentifier: "borrowManually", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (nil) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToBorrowList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? ManualInputViewController, let book = sourceViewController.book {
            
//            if let selectedIndexPath = tableView.indexPathForSelectedRow{
//                //Update
//                books[selectedIndexPath.row] = book
//                tableView.reloadRows(at: [selectedIndexPath], with: .none)
//            }
//
//            else
//            {   //Add
            
            state = sourceViewController.state
            
            if (sourceViewController.state == "borrow") {
                bbooks = loadBBooks()!
                bbooks.append(book)
                books = bbooks
            } else {
                lbooks = loadLBooks()!
                lbooks.append(book)
                books = lbooks
            }
            saveBooks()
            
            tableView.reloadData()

            
//            }
            
        }
    }
    

    
    
    @objc func lbSwitchClick() {
        if (state == "borrow"){
            state = "lend"
            navigationItem.title = "Lend"
            books = lbooks
        }
        else {
            state = "borrow"
            navigationItem.title = "Borrow"
            books = bbooks
        }
        self.tableView.reloadData()
        self.viewWillAppear(true)
    }
    
    @IBOutlet weak var lbswitch: UIBarButtonItem!
    
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sorting", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sort by title", style: .default, handler: { (nil) in
            self.books = self.sortTitle()
            self.tableView.reloadData()
            self.saveBooks()
        }))
        alert.addAction(UIAlertAction(title: "Sort by owner", style: .default, handler: { (nil) in
            self.books = self.sortOwner()
            self.tableView.reloadData()
            self.saveBooks()
        }))
        alert.addAction(UIAlertAction(title: "Sort by return date", style: .default, handler: { (nil) in
            self.books = self.sortDate()
            self.tableView.reloadData()
            self.saveBooks()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Private Methods
    private func loadSampleBooks()-> [Books]? {
        let photo1 = UIImage(named: "sampleBook1")
        let photo2 = UIImage(named: "sampleBook2")
        let photo3 = UIImage(named: "sampleBook3")
        let sampleCategory = ["Sample"]
        
        guard let book1 = Books(title: "Sample1", author: "Author1", photo: photo1, rating: 4, describeText: nil, owner:"Friend1", returnDate:Date(), publishedDate: nil, isbn: nil, dateAdded: "tbd", publisher: "", category: sampleCategory) else {
            fatalError("Unable to instantiate book1")
        }
        
        guard let book2 = Books(title: "Sample2", author: "Author2", photo: photo2, rating: 5, describeText: nil, owner:"Friend1", returnDate:Date(), publishedDate: nil, isbn: nil, dateAdded: "tbd", publisher: "", category: sampleCategory) else {
            fatalError("Unable to instantiate book2")
        }
        
        guard let book3 = Books(title: "Sample3", author: "Author3", photo: photo3, rating: 3, describeText: nil, owner:"Friend1", returnDate:Date(), publishedDate: nil, isbn: nil, dateAdded: "tbd", publisher: "", category: sampleCategory) else {
            fatalError("Unable to instantiate book3")
        }
        var temp = [book1, book2, book3]
        return temp
    }
    
    func saveBooks() {
        if state == "borrow" {
            bbooks = books
            let successfulSave = NSKeyedArchiver.archiveRootObject(bbooks, toFile: Books.BorrowArchiveURL.path)
        } else {
            lbooks = books
            let successfulSave = NSKeyedArchiver.archiveRootObject(lbooks, toFile: Books.LendArchiveURL.path)
            
        }
        
//        if successfulSave {
//            os_log("Books is saved.", log: OSLog.default, type: . debug)
//        }
//        else
//        {
//            os_log("Failed to save book", log: OSLog.default, type: .error)
//        }
    }
    
    func loadBBooks() -> [Books]? {
        if let bks = NSKeyedUnarchiver.unarchiveObject(withFile: Books.BorrowArchiveURL.path) as? [Books] {
            return bks
        }
        return []
    }
    func loadLBooks() -> [Books]? {
        if let bks = NSKeyedUnarchiver.unarchiveObject(withFile: Books.LendArchiveURL.path) as? [Books] {
            return bks
        }
        return []
    }
    
    //MARK: SORTING
    private func sortTitle() -> [Books] {
        let sortedArr = books.sorted(by: {$0.title < $1.title})
        return sortedArr
    }
    
    private func sortOwner() -> [Books] {
        let sortedArr = books.sorted(by: {$0.owner! < $1.owner!})
        return sortedArr
    }
    
    private func sortDate() -> [Books] {
        let sortedArr = books.sorted(by: {$0.returnDate! < $1.returnDate!})
        return sortedArr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchBar.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Switch View", style: .plain, target: self, action: #selector(lbSwitchClick))
        
        var navItems = [UIBarButtonItem]()
        navItems.append(navigationItem.rightBarButtonItems![0])
        

        navItems.append(UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortButton)))
    navigationItem.setRightBarButtonItems(navItems, animated: true)
        
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        //Load saved books else sample
        if let savedBooks = loadBBooks(){
            bbooks = savedBooks
            books = bbooks
        }
        else {
            bbooks = loadSampleBooks()!
            books = bbooks
            saveBooks()
        }
        if let savedBooks = loadLBooks(){
            lbooks = savedBooks
        }
        else {
            lbooks = loadSampleBooks()!
            saveBooks()
        }
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            
            view.endEditing(true)
            
            tableView.reloadData()
        }
        else {
            isSearching = true
            
            filteredArr = books.filter({books -> Bool in
                guard let text = searchBar.text else {return false}
                return books.title.lowercased().contains(text.lowercased())
            })
            
            filteredArr += books.filter({books -> Bool in
                guard let text = searchBar.text else {return false}
                return books.author.lowercased().contains(text.lowercased())
            })
            
            tableView.reloadData()
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
        if isSearching {
            return filteredArr.count
        }
        return books.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BooksTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of BooksTableViewCell.")
        }
        
        var book = books[indexPath.row]
        
        if isSearching {
            book = filteredArr[indexPath.row]
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        cell.titleLabel.text = book.title
        if (state == "lend") {
           cell.authorLabel.text = "Lent to: " + book.owner!
        } else {
            cell.authorLabel.text = "Owner: " + book.owner!
        }
        
        cell.photoImageView.image = book.photo
        cell.ratingLabel.text = "Return By: " + dateFormatter.string(from: book.returnDate!)
        
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
            books.remove(at: indexPath.row)
            saveBooks()
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
        case "AddBook":
            os_log("Adding a new book.", log: OSLog.default, type: .debug)
            
        case "ShowBorrowBk":
            guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let selectedBookCell = sender as? BooksTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not displayed by the table")
            }
            
            let selectedBook = books[indexPath.row]
            bookDetailViewController.book = selectedBook
            bookDetailViewController.reader = nil
            bookDetailViewController.state = state
        case "ShowQR":
            break
            
        case "borrowManually":
            guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            bookDetailViewController.state = "borrow"
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
}

