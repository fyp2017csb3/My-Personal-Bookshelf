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



var me = User.getUser()

var firUsr:String!
var firCode:String!


class BooksTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    //MARK: Properties
    var books = [Books]()
    var filteredArr = [Books]()
    var reader:User?
    var isSearching = false
    var book:Books?
    var ref : DatabaseReference!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: Actions
    @IBAction func unwindToBookList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? ManualInputViewController, let book = sourceViewController.book {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                //Update
                let fbk = book.saveFirebook(uid: (me?.UID)!, cat: "books")
                print(fbk.firKey)
                books[selectedIndexPath.row] = fbk
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            }
            
            else
            {   //Add
                let newIndexPath = IndexPath(row: books.count, section: 0)
                let fbk = book.saveFirebook(uid: (me?.UID)!, cat: "books")
                print(fbk.firKey)
                books.append(fbk)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                //Push Notification
                let fds = loadFds()!
                ref = Database.database().reference()
                for i in fds {
                    ref.child("users").child(i.UID).child("alert").child((me?.UID)!+"/"+book.firKey!).setValue((me?.name)! + " have added " + book.title)
                }
                
            }
            //Save
            saveBooks()
            
            
            
            
            
        }
    }
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sorting", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sort by title", style: .default, handler: { (nil) in
            self.books = self.sortTitle()
            self.tableView.reloadData()
            self.saveBooks()
        }))
        alert.addAction(UIAlertAction(title: "Sort by author", style: .default, handler: { (nil) in
            self.books = self.sortAuthor()
            self.tableView.reloadData()
            self.saveBooks()
        }))
        alert.addAction(UIAlertAction(title: "Sort by rating", style: .default, handler: { (nil) in
            self.books = self.sortRating()
            self.tableView.reloadData()
            self.saveBooks()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Private Methods
    private func loadSampleBooks(){
        let photo1 = UIImage(named: "sampleBook1")
        let photo2 = UIImage(named: "sampleBook2")
        let photo3 = UIImage(named: "sampleBook3")
        let sampleCategory = ["Sample"]
        
        guard let book1 = Books(title: "Sample1", author: "Author1", photo: photo1, rating: 4, describeText: nil, owner: nil, returnDate: nil, publishedDate: nil, isbn: nil, dateAdded: "tbd", publisher: "", category: sampleCategory,firKey:"nil") else {
            fatalError("Unable to instantiate book1")
        }
        
        guard let book2 = Books(title: "Sample2", author: "Author2", photo: photo2, rating: 5, describeText: nil, owner: nil, returnDate: nil, publishedDate: nil, isbn: nil, dateAdded: "tbd", publisher: "", category: sampleCategory,firKey:"nil") else {
            fatalError("Unable to instantiate book2")
        }
        
        guard let book3 = Books(title: "Sample3", author: "Author3", photo: photo3, rating: 3, describeText: nil, owner: nil, returnDate: nil, publishedDate: nil, isbn: nil, dateAdded: "tbd", publisher: "", category: sampleCategory,firKey:"nil") else {
            fatalError("Unable to instantiate book3")
        }
        
        books += [book1, book2, book3]
        
    }
    
    

    private func saveBooks() {
        let successfulSave = NSKeyedArchiver.archiveRootObject(books, toFile: Books.ArchiveURL.path)
        if successfulSave {
           os_log("Books is saved.", log: OSLog.default, type: . debug)
        }
        else
        {
            os_log("Failed to save book", log: OSLog.default, type: .error)
        }
    }
    
    private func loadBooks() -> [Books]? {
            return NSKeyedUnarchiver.unarchiveObject(withFile: Books.ArchiveURL.path) as? [Books]
        
    }
    
    private func loadFds() -> [User]? {
        if let fds =  NSKeyedUnarchiver.unarchiveObject(withFile: User.FdsArchiveURL.path) as? [User] {
            return fds
        }
        return []
    }
    
    //MARK: SORTING
    private func sortTitle() -> [Books] {
        let sortedArr = books.sorted(by: {$0.title < $1.title})
        return sortedArr
    }
    
    private func sortAuthor() -> [Books] {
        let sortedArr = books.sorted(by: {$0.author < $1.author})
        return sortedArr
    }
    
    private func sortRating() -> [Books] {
        let sortedArr = books.sorted(by: {$0.rating > $1.rating})
        return sortedArr
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func viewReload() {
        if (reader == nil) {
            reader = me
        }
        if (reader == me) {
            if let savedBooks = loadBooks() {
                books = savedBooks
            }
            else {
                books = []
            }
            navigationItem.leftBarButtonItem = editButtonItem
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
            //loadFirebase
            Books.returnFirebook(uid: (reader?.UID)!, cat: "books",view: self)
            
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        //Load saved books else sample
        
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: myNotification, object: nil, queue: nil, using: catchNotification)
        
    }
    let myNotification = Notification.Name(rawValue:"MyNotification")
    
    func catchNotification(notification: Notification) -> Void {
        print("Catch notification")
        
        guard let userInfo = notification.userInfo,
            let message  = userInfo["message"] as? String,
            let date     = userInfo["date"]    as? Date else {
                print("No userInfo found in notification")
                return
        }

        let alert = UIAlertController(title: "Your friend have added a new book",
                                      message:"\(message)",
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tabBarController!.selectedIndex == 0 {
            reader = me
        }
        viewReload()
        let nc = NotificationCenter.default
        
        var ref:DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("users").child((me?.UID)!).child("alert").observe(.childAdded) { (DataSnapshot) in
            firUsr = DataSnapshot.key as! String
            var msgDict = DataSnapshot.value as! [String:String]
            let mkeyPair = msgDict.popFirst()
            let msg = mkeyPair?.value
            firCode = mkeyPair?.key
            
            
            let alert = UIAlertController(title: msg, message: "Take a look at the book?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                self.getBook {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

                    let bookDetailViewController = storyBoard.instantiateViewController(withIdentifier: "BookDetail") as! ManualInputViewController


                    bookDetailViewController.book = self.book
                    bookDetailViewController.state = "read"

                    bookDetailViewController.reader = self.reader

                    self.navigationController?.pushViewController(bookDetailViewController, animated: true)
                    
//                    self.performSegue(withIdentifier: "ShowAlertBook", sender: self)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                alert?.dismiss(animated: true, completion: nil)
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            
            
            
//            nc.post(name:self.myNotification,
//                    object: nil,
//                    userInfo:["message": msg, "date": Date()])
            ref.child("users").child((me?.UID)!).child("alert").child(DataSnapshot.key).setValue(nil)
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
            
            //Filter Author
            for items in (books.filter({books -> Bool in
                guard let text = searchBar.text else {return false}
                return books.author.lowercased().contains(text.lowercased())
            })) {
                filteredArr.append(items)
            }
            
            for items in (books.filter({books -> Bool in
                guard let text = searchBar.text else {return false}
                for i in books.category! {
                if i.lowercased().contains(text.lowercased()) {
                        return true
                    }
                }
                return false
            })) {
                filteredArr.append(items)
            }
            
            filteredArr = removeDuplicate(sourceArray: filteredArr)
            
            tableView.reloadData()
        }
    }
    
    private func removeDuplicate(sourceArray: Array<Books>) -> Array<Books> {
        var encountered = Set<Books>()
        var result: [Books] = []
        for value in sourceArray {
            if encountered.contains(value) {
                
            }
            else {
                encountered.insert(value)
                result.append(value)
            }
        }
        return result
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
        
        var book: Books
        
        if isSearching {
            book = filteredArr[indexPath.row]
        }
        else {
            book = books[indexPath.row]
        }
        
        cell.titleLabel.text = book.title
        cell.authorLabel.text = "Author: " + book.author
        cell.photoImageView.image = book.photo
        cell.ratingLabel.text = "Rating: " + String(book.rating)
        
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
        if reader == me {
        if editingStyle == .delete {
            // Delete the row from the data source
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("users").child((me?.UID)!).child("books").child(books[indexPath.row].firKey!).setValue(nil)
            
            books.remove(at: indexPath.row)
            saveBooks()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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
    func getBook(completion: @escaping () -> Void) {
        ref = Database.database().reference()
        var fds = NSKeyedUnarchiver.unarchiveObject(withFile: User.FdsArchiveURL.path) as? [User]
        while (true) {
            reader = fds?.popLast()
            if(reader?.UID == firUsr) {
                break
            }
        }
        
        ref.child("users").child(firUsr).child("books").child(firCode).observeSingleEvent(of: .value) { (DataSnapshot) in
            if let imgURL = DataSnapshot.childSnapshot(forPath: "photo").value as? String {
                print(imgURL)
                let storageRef = Storage.storage().reference()
                storageRef.child(imgURL).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    let img = UIImage(data: data!)
                    
                    let bk = Books(
                        title: DataSnapshot.childSnapshot(forPath: "title").value as! String,
                        author: DataSnapshot.childSnapshot(forPath: "author").value as! String,
                        photo:img != nil ? img : UIImage(named: "defaultBookImage"),
                        rating: DataSnapshot.childSnapshot(forPath: "rating").value as! Int,
                        describeText: DataSnapshot.childSnapshot(forPath: "describeText").value as? String,
                        owner: DataSnapshot.childSnapshot(forPath: "owner").value as? String,
                        returnDate: nil,
                        publishedDate: DataSnapshot.childSnapshot(forPath: "publishedDate").value as? String,
                        isbn: DataSnapshot.childSnapshot(forPath: "isbn").value as? String,
                        dateAdded: DataSnapshot.childSnapshot(forPath: "dateAdded").value as? String,
                        publisher: DataSnapshot.childSnapshot(forPath: "publisher").value as? String,
                        category: DataSnapshot.childSnapshot(forPath: "category").value as! [String],
                        firKey:DataSnapshot.childSnapshot(forPath: "firKey").value as! String
                    )
                self.book = bk
                completion()
                })
            } else {
                let bk = Books(
                    title: DataSnapshot.childSnapshot(forPath: "title").value as! String,
                    author: DataSnapshot.childSnapshot(forPath: "author").value as! String,
                    photo: UIImage(named: "defaultBookImage"),
                    rating: DataSnapshot.childSnapshot(forPath: "rating").value as! Int,
                    describeText: DataSnapshot.childSnapshot(forPath: "describeText").value as? String,
                    owner: DataSnapshot.childSnapshot(forPath: "owner").value as? String,
                    returnDate: nil,
                    publishedDate: DataSnapshot.childSnapshot(forPath: "publishedDate").value as? String,
                    isbn: DataSnapshot.childSnapshot(forPath: "isbn").value as? String,
                    dateAdded: DataSnapshot.childSnapshot(forPath: "dateAdded").value as? String,
                    publisher: DataSnapshot.childSnapshot(forPath: "publisher").value as? String,
                    category: DataSnapshot.childSnapshot(forPath: "category").value as! [String],
                    firKey:DataSnapshot.childSnapshot(forPath: "firKey").value as! String
                )
                self.book = bk
                completion()
            }
    }
    }
    
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddBook":
            os_log("Adding a new book.", log: OSLog.default, type: .debug)
            
        case "ShowAlertBook":
            guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            bookDetailViewController.book = book
            bookDetailViewController.state = "read"
            
            bookDetailViewController.reader = reader
            
            
            
        case "ShowDetail":
            guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
                
                guard let selectedBookCell = sender as? BooksTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                    fatalError("The selected cell is not displayed by the table")
                }
                
            var selectedBook: Books
            if isSearching {
                selectedBook = filteredArr[indexPath.row]
            } else {
                selectedBook = books[indexPath.row]
            }
            bookDetailViewController.book = selectedBook
            bookDetailViewController.state = "read"
            
            bookDetailViewController.reader = reader
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            }
    }
 

}
