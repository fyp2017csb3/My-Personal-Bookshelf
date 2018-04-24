//
//  QRViewController.swift
//  MyPersonalBookShelf
//
//  Created by haruka on 3/4/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import Firebase

class QRViewController: UIViewController {
    
    var bbook : Books?
    var rdays = 14
    
    @IBAction func test(_ sender: Any) {

    }
    @IBOutlet weak var QRImg: UIImageView!
    
    @IBAction func back(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.removeAllObservers()
        dismiss(animated:  true, completion: nil)
    }
    override func viewDidLoad() {
        
        let uid = me?.UID
        let data = uid?.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let img = UIImage(ciImage: (filter?.outputImage)!)
        QRImg.image = img
        var bkimg:UIImage?
        
        
        
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        
        ref.child("users").child((me?.UID)!).child("borrowAlert").observeSingleEvent(of: .childAdded) { (snap1) in
            ref.child("users").child((me?.UID)!).child("borrow").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children{
                
                
                if let imgURL = (child as! DataSnapshot).childSnapshot(forPath: "photo").value as? String {
                    let storageRef = Storage.storage().reference()
                    storageRef.child(imgURL).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                        if let datax = data {
                            bkimg = UIImage(data: datax)
                        }
                        
                        
                        let bk = Books(
                            title: (child as! DataSnapshot).childSnapshot(forPath: "title").value as! String,
                            author: (child as! DataSnapshot).childSnapshot(forPath: "author").value as! String,
                            photo:bkimg,
                            rating: (child as! DataSnapshot).childSnapshot(forPath: "rating").value as! Int,
                            describeText: (child as! DataSnapshot).childSnapshot(forPath: "describeText").value as? String,
                            owner: (child as! DataSnapshot).childSnapshot(forPath: "owner").value as? String,
                            returnDate: Date(),
                            publishedDate: (child as! DataSnapshot).childSnapshot(forPath: "publishedDate").value as? String,
                            isbn: (child as! DataSnapshot).childSnapshot(forPath: "isbn").value as? String,
                            dateAdded: (child as! DataSnapshot).childSnapshot(forPath: "dateAdded").value as? String,
                            publisher: (child as! DataSnapshot).childSnapshot(forPath: "publisher").value as? String,
                            category: (child as! DataSnapshot).childSnapshot(forPath: "category").value as! [String],
                            firKey:"nil"
                        )
                        self.rdays = (child as! DataSnapshot).childSnapshot(forPath: "returnDate").value as! Int
                        self.bbook = bk
                        self.performSegue(withIdentifier: "ManualBorrow", sender: self)
                        ref.removeAllObservers()
                        ref.child("users").child((me?.UID)!).child("borrowAlert").setValue(nil)
                        ref.child("users").child((me?.UID)!).child("borrow").setValue(nil)
                        
                        
                    })
                }
                else {
                    
                    
                    let bk = Books(
                        title: (child as! DataSnapshot).childSnapshot(forPath: "title").value as! String,
                        author: (child as! DataSnapshot).childSnapshot(forPath: "author").value as! String,
                        photo:bkimg,
                        rating: (child as! DataSnapshot).childSnapshot(forPath: "rating").value as! Int,
                        describeText: (child as! DataSnapshot).childSnapshot(forPath: "describeText").value as? String,
                        owner: (child as! DataSnapshot).childSnapshot(forPath: "owner").value as? String,
                        returnDate: Date(),
                        publishedDate: (child as! DataSnapshot).childSnapshot(forPath: "publishedDate").value as? String,
                        isbn: (child as! DataSnapshot).childSnapshot(forPath: "isbn").value as? String,
                        dateAdded: (child as! DataSnapshot).childSnapshot(forPath: "dateAdded").value as? String,
                        publisher: (child as! DataSnapshot).childSnapshot(forPath: "publisher").value as? String,
                        category: (child as! DataSnapshot).childSnapshot(forPath: "category").value as! [String],
                        firKey:"nil"
                    )
                    self.rdays = (child as! DataSnapshot).childSnapshot(forPath: "returnDate").value as! Int
                    self.bbook = bk
                    self.performSegue(withIdentifier: "ManualBorrow", sender: self)
                    ref.removeAllObservers()
                    ref.child("users").child((me?.UID)!).child("borrowAlert").setValue(nil)
                    ref.child("users").child((me?.UID)!).child("borrow").setValue(nil)
                }
                
            }
                
            })
        }
        
        //if uid deleted back()
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func unwindToBookList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? ManualInputViewController, let book = sourceViewController.book {

            
                bbook = book

        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        case "ManualBorrow":
            guard let bookDetailViewController = segue.destination as? ManualInputViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            bookDetailViewController.state = "borrow"
            bookDetailViewController.book = bbook
            bookDetailViewController.rdays = rdays
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

}
