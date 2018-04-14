//
//  ManualISBNViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 23/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit

class ManualISBNViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    //UI
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var keywordTextField: UITextField!
    
    //Struct of google book
    struct TopTier : Codable {
        var kind: String
        var totalItems: Int
        var items: [Item]
    }
    struct Item: Codable {
        var kind: String
        var id: String
        var etag: String
        var selfLink: String
        var volumeInfo: VolumeInfo
    }
    struct VolumeInfo: Codable {
        var title: String
        var subtitle: String?
        var authors: Array<String>?
        var description: String?
        var imageLinks: ImageLinks?
    }
    
    struct ImageLinks: Codable {
        var smallThumbnail: String?
        var thumbnail: String?
    }
    
    var book: Books?
    var bookArray = [Books]()
    
    //MARK: Action
    @IBAction func searchButton(_ sender: UIButton) {
        performTitleSearch()
    }
    
    @IBAction func isbnSearchReturn(_ sender: UITextField) {
        performISBNSearch()
    }
    
    @IBAction func titleSearchReturn(_ sender: UITextField) {
        performTitleSearch()
    }
    
    @IBAction func authorSearchReturn(_ sender: UITextField) {
        performAuthorSearch()
    }
    
    @IBAction func keywordSearchReturn(_ sender: UITextField) {
        performKeywordSearch()
    }
    
    //MARK: Search Functions
    private func performISBNSearch() {
        if !isbnTextField.text!.isEmpty {
            let isbnInput = isbnTextField.text!
            if searchByISBN(isbn: isbnInput) {
                performSegue(withIdentifier: "unwindToInput", sender: self)
            } else {
                let alert = UIAlertController(title: "Book not available", message: "The information of the book was not found in the database", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func performTitleSearch() {
        if !titleTextField.text!.isEmpty {
            let titleInput = titleTextField.text!
            if searchByTitle(keyword: ("intitle:" + titleInput)) {
                performSegue(withIdentifier: "searchResultSegue", sender: self)
            }
            else {
                let alert = UIAlertController(title: "No match result", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    private func performAuthorSearch() {
        if !authorTextField.text!.isEmpty {
            let authorInput = authorTextField.text!
            if searchByTitle(keyword: ("inauthor:" + authorInput)) {
                performSegue(withIdentifier: "searchResultSegue", sender: self)
            }
            else {
                let alert = UIAlertController(title: "No match result", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    private func performKeywordSearch() {
        if !keywordTextField.text!.isEmpty {
            let keywordInput = keywordTextField.text!
            if searchByTitle(keyword: keywordInput) {
                performSegue(withIdentifier: "searchResultSegue", sender: self)
            }
            else {
                let alert = UIAlertController(title: "No match result", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isbnTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ManualInputViewController {
            destination.manualSearchData = book
        }
        if let destination2 = segue.destination as? SearchResultTableViewController {
            destination2.searchResultArray = bookArray
        }
    }
    
    //MARK: Private Function
    private func searchByISBN(isbn: String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var title = ""
        var author = ""
        var image = #imageLiteral(resourceName: "defaultBookImage")
        var describeText = ""
        
        var topTierData = [TopTier]()
        
        let jsonURL = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn
        let url = URL(string: jsonURL)
        
        let dataTask = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            else{
                do{
                    //Decode JSON
                    let jsonDecoder = JSONDecoder()
                    topTierData = try [jsonDecoder.decode(TopTier.self, from: data!)]
                    
                    //Check book title
                    print(topTierData[0].items[0].volumeInfo.title)
                    
                    title = topTierData[0].items[0].volumeInfo.title
                    
                    if topTierData[0].items[0].volumeInfo.authors != nil {
                        author = topTierData[0].items[0].volumeInfo.authors![0]
                    }
                    
                    //Download Image
                    if topTierData[0].items[0].volumeInfo.imageLinks != nil {
                        if let imageLink = topTierData[0].items[0].volumeInfo.imageLinks!.thumbnail {
                            image = self.downloadImage(link: imageLink)
                        }
                    }
                    
                    //Description
                    if topTierData[0].items[0].volumeInfo.description != nil {
                        describeText = topTierData[0].items[0].volumeInfo.description!
                    }
                }
                catch
                {
                    print("Cannot decode the top tier data of the book.")
                }
                
                
                self.book = Books(title: title, author: author, photo: image, rating: 3, describeText: describeText, owner:nil, returnDate:nil)
                sem.signal()
                }
            } as URLSessionTask
        
        dataTask.resume()
        
        sem.wait()
        if self.book?.title == nil {
            print("Enter alert")
            return false
        }
        print("URLSession Completed")
        return true
    }
    
    private func urlHandler(keyword: String) -> URL {
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=" + keyword + "&maxResults=40"
        let jsonURL = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: jsonURL!)
        return url!
    }
    
    //Also use for keyword and author search
    private func searchByTitle(keyword: String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var topTierData = [TopTier]()
        
        /* let urlString = "https://www.googleapis.com/books/v1/volumes?q=intitle:" + titleInput + "&maxResults=40"
        let jsonURL = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: jsonURL!) */
        
        let url = urlHandler(keyword: keyword)
        print(url)
        
        //Books Attibute
        var title = ""
        var author = ""
        var image = #imageLiteral(resourceName: "defaultBookImage")
        var describeText = ""
        
        let dataTask = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            else{
                do{
                    //Decode JSON
                    let jsonDecoder = JSONDecoder()
                    topTierData = try [jsonDecoder.decode(TopTier.self, from: data!)]
                    
                    var itemCount = topTierData[0].totalItems
                    if(itemCount > 40) {
                        itemCount = 40
                    }
                    for i in 0..<itemCount {
                        title = topTierData[0].items[i].volumeInfo.title
                    
                        if topTierData[0].items[i].volumeInfo.authors != nil {
                            author = topTierData[0].items[i].volumeInfo.authors![0]
                        }
                    
                        //Download Image
                        if topTierData[0].items[i].volumeInfo.imageLinks != nil {
                            if let imageLink = topTierData[0].items[i].volumeInfo.imageLinks!.thumbnail {
                                image = self.downloadImage(link: imageLink)
                            }
                        }
                    
                        //Description
                        if topTierData[0].items[0].volumeInfo.description != nil {
                            describeText = topTierData[0].items[0].volumeInfo.description!
                        }
                        
                        self.book = Books(title: title, author: author, photo: image, rating: 0, describeText: describeText, owner:nil, returnDate:nil)!
                        self.bookArray.append(self.book!)
                    }
                }
                catch
                {
                    print("Cannot decode the top tier data of the book.")
                }
                
                sem.signal()
            }
            } as URLSessionTask
        
        dataTask.resume()
        
        sem.wait()
        if self.book?.title == nil {
            print("Enter alert")
            return false
        }
        print("URLSession Completed")
        return true
        
    }
    
    private func downloadImage(link: String) -> UIImage {
        let imgURL = NSURL(string: link)
        let imgData = NSData.init(contentsOf: imgURL! as URL)
        let image = UIImage(data: imgData! as Data)
        
        return image!
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
