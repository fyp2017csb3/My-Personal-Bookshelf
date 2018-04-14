//
//  GoogleBook.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 8/2/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit

class GoogleBook {
    
    var book: Books?
    
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
    
    //MARK: Functions
/*  func searchByTitle(title: String) -> Array<Books> {
        let searchResult: Array<Books>?
        let sem = DispatchSemaphore(value: 0)
        var titleResult = ""
        var author = ""
        var image = #imageLiteral(resourceName: "defaultBookImage")
        var describeText = ""
        
        var topTierData = [TopTier]()
        
        let jsonURL = "https://www.googleapis.com/books/v1/volumes?q=intitle:" + title
        print(jsonURL)
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
                    
                    titleResult = topTierData[0].items[0].volumeInfo.title
                    
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
                
                
                self.book = Books(title: title, author: author, photo: image, rating: 3, describeText: describeText)
                sem.signal()
            }
            } as URLSessionTask
        
        dataTask.resume()
        
        sem.wait()
        if self.book?.title == nil {
            print("Enter alert")
        }
        print("URLSession Completed")
    }
    
    func searchByISBN(isbn: String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var title = ""
        var author = ""
        var image = #imageLiteral(resourceName: "defaultBookImage")
        var describeText = ""
        
        var topTierData = [TopTier]()
        
        let jsonURL = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn
        print(jsonURL)
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
                
                
                self.book = Books(title: title, author: author, photo: image, rating: 3, describeText: describeText)
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
    } */
}
