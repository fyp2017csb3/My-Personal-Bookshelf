//
//  Books.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log
import Firebase


class Books: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(author, forKey: PropertyKey.author)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(describeText, forKey: PropertyKey.describeText)
        aCoder.encode(owner, forKey: PropertyKey.owner)
        aCoder.encode(returnDate, forKey: PropertyKey.returnDate)
        aCoder.encode(publishedDate, forKey: PropertyKey.publishedDate)
        aCoder.encode(isbn, forKey: PropertyKey.isbn)
        aCoder.encode(dateAdded, forKey: PropertyKey.dateAdded)
        aCoder.encode(publisher, forKey: PropertyKey.publisher)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(firKey, forKey: PropertyKey.firKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        //Fail if no title
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the title for the book.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let author = aDecoder.decodeObject(forKey: PropertyKey.author) as? String
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        let describeText = aDecoder.decodeObject(forKey: PropertyKey.describeText) as? String
        let owner = aDecoder.decodeObject(forKey: PropertyKey.owner) as? String
        let returnDate = aDecoder.decodeObject(forKey: PropertyKey.returnDate) as? Date
        let publishedDate = aDecoder.decodeObject(forKey: PropertyKey.publishedDate) as? String
        let isbn = aDecoder.decodeObject(forKey: PropertyKey.isbn) as? String
        let dateAdded = aDecoder.decodeObject(forKey: PropertyKey.dateAdded) as? String
        let publisher = aDecoder.decodeObject(forKey: PropertyKey.publisher) as? String
        var category = aDecoder.decodeObject(forKey: PropertyKey.category) as? Array<String>
        if category == nil {
            category = [String]()
        }
        let firKey = aDecoder.decodeObject(forKey: PropertyKey.firKey) as? String
        
        self.init(title: title, author: author!, photo: photo, rating: rating, describeText: describeText, owner: owner, returnDate: returnDate, publishedDate: publishedDate, isbn: isbn, dateAdded: dateAdded, publisher: publisher, category: category!,firKey:firKey!)
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("books")
    static let BorrowArchiveURL = DocumentsDirectory.appendingPathComponent("bbooks")
    static let LendArchiveURL = DocumentsDirectory.appendingPathComponent("lbooks")
    
    //MARK: Properties
    var title: String
    var author: String
    var photo: UIImage?
    var rating: Int
    var describeText: String?
    var owner: String?
    var returnDate: Date?
    var publishedDate: String?
    var isbn: String?
    var dateAdded: String?
    var publisher: String?
    var category: Array<String>?
    var firKey:String?
    
    struct PropertyKey {
        static let title = "title"
        static let author = "author"
        static let photo = "photo"
        static let rating = "rating"
        static let describeText = "describeText"
        static let owner = "owner"
        static let returnDate = "returnDate"
        static let publishedDate = "publishedDate"
        static let isbn = "isbn"
        static let dateAdded = "dateAdded"
        static let publisher = "publisher"
        static let category = "category"
        static let firKey = "firKey"
    }
    
    //MARK: Initialization
    init?(title: String, author: String, photo: UIImage?, rating: Int, describeText: String?, owner:String?, returnDate: Date?, publishedDate: String?, isbn: String?, dateAdded: String?, publisher: String?, category: Array<String>, firKey:String){
        
        guard !title.isEmpty else{
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else{
            return nil
        }
        
        self.title = title
        self.author = author
        self.photo = photo
        self.rating = rating
        self.describeText = describeText
        self.owner = owner
        self.returnDate = returnDate
        self.publishedDate = publishedDate
        self.isbn = isbn
        self.dateAdded = dateAdded
        self.publisher = publisher
        self.category = category
        self.firKey = firKey
        if firKey == nil {
            self.firKey = "nil"
        }
    }

    static func returnFirebook(uid:String, cat:String, view:Any)  {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var bks = [Books]()
        bks = []
        var img:UIImage?
        var queue = 0
        ref.child("users").child(uid).child(cat).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children{
                queue += 1
                if let imgURL = (child as! DataSnapshot).childSnapshot(forPath: "photo").value as? String {
                    let storageRef = Storage.storage().reference()
                    storageRef.child(imgURL).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                        img = UIImage(data: data!)
                        
                        let returnDateStr = (child as! DataSnapshot).childSnapshot(forPath: "returnDate").value as? String
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        
                        let bk = Books(
                            title: (child as! DataSnapshot).childSnapshot(forPath: "title").value as! String,
                            author: (child as! DataSnapshot).childSnapshot(forPath: "author").value as! String,
                            photo:img,
                            rating: (child as! DataSnapshot).childSnapshot(forPath: "rating").value as! Int,
                            describeText: (child as! DataSnapshot).childSnapshot(forPath: "describeText").value as? String,
                            owner: (child as! DataSnapshot).childSnapshot(forPath: "owner").value as? String,
                            returnDate: returnDateStr != nil ? formatter.date(from: returnDateStr!):nil,
                            publishedDate: (child as! DataSnapshot).childSnapshot(forPath: "publishedDate").value as? String,
                            isbn: (child as! DataSnapshot).childSnapshot(forPath: "isbn").value as? String,
                            dateAdded: (child as! DataSnapshot).childSnapshot(forPath: "dateAdded").value as? String,
                            publisher: (child as! DataSnapshot).childSnapshot(forPath: "publisher").value as? String,
                            category: (child as! DataSnapshot).childSnapshot(forPath: "category").value as! [String],
                            firKey:(child as! DataSnapshot).childSnapshot(forPath: "firKey").value as! String
                        )
                        if let sourceView = view as? BooksTableViewController {
                            sourceView.books.append(bk!)
                            sourceView.tableView.reloadData()
                        } else if let sourceView = view as? RecommendTableViewController{
                            sourceView.books.append(bk!)
                            sourceView.tableView.reloadData()

                        } else {
                            if let sourceView = view as? profileViewController {
                                switch(cat) {
                                case"books":
                                    sourceView.books.append(bk!)
                                case"bbooks":
                                    sourceView.bbooks.append(bk!)
                                case"lbooks":
                                    sourceView.lbooks.append(bk!)
                                default:
                                    break
                                }
                                print("added a bk from base")
                                queue -= 1
                                if queue == 0 {
                                    if let sourceView = view as? profileViewController {
                                        switch(cat) {
                                        case"books":
                                            sourceView.saveBooks()                                    case"bbooks":
                                                sourceView.saveBBooks()
                                        case"lbooks":
                                            sourceView.saveLBooks()
                                        default:
                                            break
                                        }
                                    }
                                }
            
                            }
                        }
                        
                        
                    })
                }
                else {
                    
                    
                    let bk = Books(
                        title: (child as! DataSnapshot).childSnapshot(forPath: "title").value as! String,
                        author: (child as! DataSnapshot).childSnapshot(forPath: "author").value as! String,
                        photo:img != nil ? img : UIImage(named: "defaultBookImage"),
                        rating: (child as! DataSnapshot).childSnapshot(forPath: "rating").value as! Int,
                        describeText: (child as! DataSnapshot).childSnapshot(forPath: "describeText").value as? String,
                        owner: (child as! DataSnapshot).childSnapshot(forPath: "owner").value as? String,
                        returnDate: nil,
                        publishedDate: (child as! DataSnapshot).childSnapshot(forPath: "publishedDate").value as? String,
                        isbn: (child as! DataSnapshot).childSnapshot(forPath: "isbn").value as? String,
                        dateAdded: (child as! DataSnapshot).childSnapshot(forPath: "dateAdded").value as? String,
                        publisher: (child as! DataSnapshot).childSnapshot(forPath: "publisher").value as? String,
                        category: (child as! DataSnapshot).childSnapshot(forPath: "category").value as! [String],
                        firKey:(child as! DataSnapshot).childSnapshot(forPath: "firKey").value as! String
                    )
                    if let sourceView = view as? BooksTableViewController {
                        sourceView.books.append(bk!)
                        print("added a bk from base")
                        sourceView.tableView.reloadData()
                    } else if let sourceView = view as? RecommendTableViewController{
                        
                        sourceView.books.append(bk!)
                        print("added a bk from base")
                        sourceView.tableView.reloadData()
                        
                    } else {
                        if let sourceView = view as? profileViewController {
                            switch(cat) {
                            case"books":
                                sourceView.books.append(bk!)
                            case"bbooks":
                                sourceView.bbooks.append(bk!)
                            case"lbooks":
                                sourceView.lbooks.append(bk!)
                            default:
                                break
                            }
                            print("added a bk from base")
                            queue -= 1
                            if queue == 0 {
                                if let sourceView = view as? profileViewController {
                                    switch(cat) {
                                    case"books":
                                        sourceView.saveBooks()                                    case"bbooks":
                                        sourceView.saveBBooks()   
                                    case"lbooks":
                                        sourceView.saveLBooks()
                                    default:
                                        break
                                    }
                                }
                            }
                            
                            
                        }
                    }
                }
                
            }
        
        })
        
    }
    

    
    func saveFirebook(uid:String,cat:String) -> Books {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let storageRef = Storage.storage().reference()
        

        var key:String!
        print("saving "+firKey!)
        
        if (isbn != nil && isbn != "") {
            firKey = isbn
        }
        if firKey == "nil" {
            key = ref.child("users").child(uid).child(cat).childByAutoId().key
            firKey = key
        } else {
            key = firKey
        }
        
        
        if let img = photo {
            let imgRef = storageRef.child(uid+"/"+key)
            var data = NSData()
            data = UIImageJPEGRepresentation(img, 0.5) as! NSData
            imgRef.putData(data as Data)
        }
        
        
        ref.child("users").child(uid).child(cat).child(key).child("title").setValue(title)
        ref.child("users").child(uid).child(cat).child(key).child("author").setValue(author)
        ref.child("users").child(uid).child(cat).child(key).child("rating").setValue(rating)
        ref.child("users").child(uid).child(cat).child(key).child("photo").setValue(uid+"/"+key)
        ref.child("users").child(uid).child(cat).child(key).child("describeText").setValue(describeText)
        ref.child("users").child(uid).child(cat).child(key).child("owner").setValue(owner)
        ref.child("users").child(uid).child(cat).child(key).child("returnDate").setValue(nil)
        ref.child("users").child(uid).child(cat).child(key).child("publishedDate").setValue(publishedDate)
        ref.child("users").child(uid).child(cat).child(key).child("isbn").setValue(isbn)
        
        if cat != "books" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let returnDateStr = formatter.string(from: returnDate!)
            ref.child("users").child(uid).child(cat).child(key).child("returnDate").setValue(returnDateStr)
        }
        ref.child("users").child(uid).child(cat).child(key).child("dateAdded").setValue(dateAdded)
        ref.child("users").child(uid).child(cat).child(key).child("publisher").setValue(publisher)
        ref.child("users").child(uid).child(cat).child(key).child("category").setValue(category)
        ref.child("users").child(uid).child(cat).child(key).child("firKey").setValue(firKey)
        
        return self
    }
    
//    func setFIRKey(uid:String?) {
//        firKey = uid
//    }
    
    func saveFireBorrow(uid:String, bday:Int) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let storageRef = Storage.storage().reference()
        
        
        let key = ref.child("users").child(uid).child("borrow").childByAutoId().key
        if let img = photo {
            let imgRef = storageRef.child(uid+"/"+key)
            var data = NSData()
            data = UIImageJPEGRepresentation(img, 0.5) as! NSData

            imgRef.putData(data as Data, metadata: nil, completion: { (StorageMedia, Error) in
                
                ref.child("users").child(uid).child("borrow").child(key).child("title").setValue(self.title)
                ref.child("users").child(uid).child("borrow").child(key).child("author").setValue(self.self.author)
                ref.child("users").child(uid).child("borrow").child(key).child("rating").setValue(self.rating)
                ref.child("users").child(uid).child("borrow").child(key).child("photo").setValue(uid+"/"+key)
                ref.child("users").child(uid).child("borrow").child(key).child("describeText").setValue(self.describeText)
                ref.child("users").child(uid).child("borrow").child(key).child("owner").setValue(me?.name)
                ref.child("users").child(uid).child("borrow").child(key).child("returnDate").setValue(bday)
                ref.child("users").child(uid).child("borrow").child(key).child("publishedDate").setValue(self.self.publishedDate)
                ref.child("users").child(uid).child("borrow").child(key).child("isbn").setValue(self.isbn)
                ref.child("users").child(uid).child("borrow").child(key).child("dateAdded").setValue(self.dateAdded)
                ref.child("users").child(uid).child("borrow").child(key).child("publisher").setValue(self.publisher)
                ref.child("users").child(uid).child("borrow").child(key).child("category").setValue(self.category)
                
                ref.child("users").child(uid).child("borrowAlert").childByAutoId().setValue(1)
            })
          
        }

    }
    
    static func getCatCount(srcBks:[Books]) -> [String:Int]{
        var cat = [String:Int]()
        cat = [:]
        
        for i in srcBks {
            for j in i.category! {
                if cat[j] == nil {
                    cat[j] = 1
                } else {
                    cat[j] = cat[j]! + 1
                }
            }
        }
        return cat
    }
    
 
}

