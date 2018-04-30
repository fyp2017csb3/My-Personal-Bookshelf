//
//  BooksTableViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log

class RecommendTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    //MARK: Properties
    var books = [Books]()
    var myBooks = [Books]()
    var fds = [User]()
    var filteredArr = [Books]()
    var reader = me
    var isSearching = false
    var loading = true
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: Actions
    
    @IBAction func recBk(_ sender: Any) {
        if !books.isEmpty {
            performSegue(withIdentifier: "ShowRecBk", sender: self)
        } else {
            let alert = UIAlertController(title: "Fatal Error", message: "Not enough books to perform recommendation.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sorting", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sort by title", style: .default, handler: { (nil) in
            self.books = self.sortTitle()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Sort by author", style: .default, handler: { (nil) in
            self.books = self.sortAuthor()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Sort by rating", style: .default, handler: { (nil) in
            self.books = self.sortRating()
            self.tableView.reloadData()
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
    
    
    
    //MARK: SORTING
    private func sortTitle() -> [Books] {
        let sortedArr = books.sorted(by: {$0.title < $1.title})
        return sortedArr
    }
    
    private func sortAuthor() -> [Books] {
        let sortedArr = books.sorted(by: {$0.author < $1.author})
        return sortedArr
    }
    
    private func loadBooks() -> [Books]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Books.ArchiveURL.path) as? [Books]
    }
    
    
    private func sortRating() -> [Books] {
        let sortedArr = books.sorted(by: {$0.rating > $1.rating})
        return sortedArr
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadFds() -> [User]? {
        if let fds =  NSKeyedUnarchiver.unarchiveObject(withFile: User.FdsArchiveURL.path) as? [User] {
            return fds
        }
        return []
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        //activity indicator
//        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        view.addSubview(activityIndicator)
//
//        //start act indicator
//        activityIndicator.startAnimating()
//        activityIndicator.backgroundColor = UIColor.white
        
        books = []
        tableView.reloadData()
        if let selfBooks = loadBooks() {
            myBooks = selfBooks
        } else {
            myBooks = []
        }
        fds = loadFds()!
        // print(fds.count)
        for i in fds {
            Books.returnFirebook(uid: i.UID, cat: "books", view: self)
        }
        
//        if !loading {
//            activityIndicator.stopAnimating()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
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
        
        books = removeDuplicate(sourceArray: books)
        
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
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            // Delete the row from the data source
    //            books.remove(at: indexPath.row)
    //
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //
    //        } else if editingStyle == .insert {
    //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //        }
    //    }
    
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
        case "ShowRecBk":

            var bayes = Books.getCatCount(srcBks: books)
            //print("getCatCount books: " , bayes)
            var myBayes = Books.getCatCount(srcBks: myBooks)
            //print("getCatCount mybooks: " ,myBayes)
            var sum = 0
            var cat : String?
            for i in bayes {
                print("Before bayes: ", i)
                if myBayes[i.key] != nil {
                    bayes.updateValue(2*myBayes[i.key]!+1, forKey: i.key)
                    print("Enter != nil")
                } else {
                    print("Enter else")
                    bayes.updateValue(1, forKey: i.key)
                }
                sum += bayes[i.key]!
            }
            print("After bayes: " ,bayes)
            
            //print("After SUM: " + String(sum))
            var num = Int(arc4random_uniform(UInt32(sum)))
            
            print ("initial num = " +  String(num))
            
            for i in bayes {
                num -= i.value
                if num <= 0 {
                    cat = i.key
                    break
                }
            }
            var tmpBks = [Books]()
            tmpBks = []
            for i in books {
                if(i.category?.contains(cat!))! {
                    tmpBks.append(i)
                }
            }
            
            //print("cat = " + cat!)
            
//            for i in tmpBks {
//                print("title = " + i.title)
//            }
//
//            print ("num = " +  String(num))
            
            num = Int(arc4random_uniform(UInt32(tmpBks.count)))
            
            guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            
            let selectedBook = tmpBks[num]
            bookDetailViewController.book = selectedBook
            bookDetailViewController.reader = nil
            
            
        case "ShowAllFdsBook":
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
            bookDetailViewController.reader = nil
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
}


