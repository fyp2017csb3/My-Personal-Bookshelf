//
//  profileViewController.swift
//  MyPersonalBookShelf
//
//  Created by haruka on 15/4/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import Firebase

class profileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var books = [Books]()
    var bbooks = [Books]()
    var lbooks = [Books]()
    var nid = ""
    @IBOutlet weak var proPic: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBAction func qrButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowQR", sender: self)
    }
    
    @IBAction func pickPhoto(_ sender: UITapGestureRecognizer) {
        print("tapping photo")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //Image of book
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else
        {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        proPic.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    func saveBooks() {
        let successfulSave = NSKeyedArchiver.archiveRootObject(books, toFile: Books.ArchiveURL.path)
        print("Synched books")
    }
    func saveBBooks() {
        let successfulSave = NSKeyedArchiver.archiveRootObject(bbooks, toFile: Books.BorrowArchiveURL.path)
        print("Synched bbooks")
    }
    func saveLBooks() {
        let successfulSave = NSKeyedArchiver.archiveRootObject(lbooks, toFile: Books.LendArchiveURL.path)
        print("Synched lbooks")
    }
    
    
    func syncUser() {
        books = []
        bbooks = []
        lbooks = []
        Books.returnFirebook(uid: (me?.UID)!, cat: "books", view: self)
        Books.returnFirebook(uid: (me?.UID)!, cat: "bbooks", view: self)
        Books.returnFirebook(uid: (me?.UID)!, cat: "lbooks", view: self)
        User.getFirFds()



            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
            let currentViewController = storyBoard.instantiateViewController(withIdentifier: "BooksView") as! BooksTableViewController
        
            let currentViewController2 = storyBoard.instantiateViewController(withIdentifier: "FdsView") as! FdsTableViewController

            currentViewController.viewReload()
            currentViewController2.viewDidLoad()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func pass() {
        let alert = UIAlertController(title: "Synchronize", message: "Passing data from old devices will erase all current data", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.

        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak alert] (_) in
            User.setUserID(newID: self.nid)
            me = User.getUser()
            alert?.dismiss(animated: true, completion: nil)
            self.syncUser()
            self.viewDidLoad()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var id: UITextField!
    @IBAction func showHideID(_ sender: Any) {
        let alert = UIAlertController(title: "UID", message: "Type your account ID to retrieve your account data", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = me?.UID
        }
        
        alert.addAction(UIAlertAction(title: "Pass information", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.nid = (textField?.text)!
            
            User.setUserID(newID: self.nid)
            me = User.getUser()
            alert?.dismiss(animated: true, completion: nil)
            self.syncUser()
            self.viewDidLoad()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var idBtn: UIButton!
    @IBOutlet weak var serial: UITextView!
    var hashID :Int!
    @IBAction func saveUser(_ sender: Any) {
        User.setUserPic(newPic: proPic.image!)
        User.setUserName(newName: name.text!)
        me = User.getUser()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let storageRef = Storage.storage().reference()
        ref.child("users").child((me?.UID)!).child("name").setValue(name.text!)
        ref.child("serial").child(String(hashID)).setValue((me?.UID)!)
        let imgURL = (me?.UID)!+"/propic"
        let imgRef = storageRef.child(imgURL)
        var data = NSData()
        data = UIImageJPEGRepresentation(proPic.image!, 0.5) as! NSData
        imgRef.putData(data as Data)
        
        performSegue(withIdentifier: "returnFriendsTableView", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        serial.delegate = self
        
        id.isHidden = true
        passBtn.isHidden = true
        proPic.image = me?.photo
        id.text = me?.UID
        name.text = me?.name
        print("name", name.text)
        hashID = me?.UID.hashValue
        serial.text = String(hashID)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowQR":
            guard let destination = segue.destination as? uidQRViewController else {
                fatalError("Unexpected Destination")
            }
            
            destination.uid = serial.text
            
        case "returnFriendsTableView":
            break
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
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
