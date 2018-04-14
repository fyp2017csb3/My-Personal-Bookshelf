//
//  Books.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log

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
        
        self.init(title: title, author: author!, photo: photo, rating: rating, describeText: describeText, owner: owner, returnDate: returnDate, publishedDate: publishedDate, isbn: isbn, dateAdded: dateAdded, publisher: publisher, category: category!)
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
    }
    
    //MARK: Initialization
    init?(title: String, author: String, photo: UIImage?, rating: Int, describeText: String?, owner:String?, returnDate: Date?, publishedDate: String?, isbn: String?, dateAdded: String?, publisher: String?, category: Array<String>){
        
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
    }
    func setReturnDate(returnDate: Date?) {
        self.returnDate = returnDate
    }
    
}
