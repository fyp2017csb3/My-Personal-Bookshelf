//
//  ManualInputViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 11/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log
import Social

class ManualInputViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var authorTextField: UITextView!
    @IBOutlet weak var ratingInput: RatingControl!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var publishedDateTextField: UITextView!
    @IBOutlet weak var isbnTextField: UITextView!
    @IBOutlet weak var dateAddedTextField: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var borrowButton: UIBarButtonItem!
    @IBOutlet weak var categoryTextField: UITextView!
    @IBOutlet weak var publisherTextField: UITextView!
    
    @IBOutlet weak var ownerField: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var borrowLabel1: UILabel!
    @IBOutlet weak var borrowLabel2: UILabel!
    @IBOutlet weak var borrowDays: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var book: Books?
    var firKey = "nil"
    var rdays: Int!
    
    var manualSearchData: Books?
    var reader = me
    var state = "read"
    var saveBtnTemp : UIBarButtonItem?
    var borrowBtnTemp : UIBarButtonItem?
    var borrower:String?
    
    @IBOutlet weak var ownerLbl: UILabel!
    //MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let addMode = presentedViewController is UINavigationController
        
        if addMode {
            dismiss(animated: true, completion: nil)
        }
            
        else if let editMode = navigationController {
            //Show
            editMode.popViewController(animated: true)
            //Modally
            dismiss(animated: true, completion: nil)
        }
            
        else {
            fatalError("The InputViewController is not inside a naviagation controller.")
        }
    }
    
    //Take data from ISBN search
    @IBAction func unwindToInput(segue: UIStoryboardSegue) {
        if let bookTitle = manualSearchData?.title {
            titleTextField.text = bookTitle
            titleTextField.textColor = UIColor.black
        }
        if let bookAuthor = manualSearchData?.author {
            authorTextField.text = bookAuthor
            authorTextField.textColor = UIColor.black
        }
        
        if let bookPhoto = manualSearchData?.photo {
            bookImage.image = bookPhoto
        }
        
        if let describeText = manualSearchData?.describeText {
            descriptionTextField.text = describeText
        }
        
        if let publishedDate = manualSearchData?.publishedDate {
            publishedDateTextField.text = publishedDate
        }
        
        if let isbn = manualSearchData?.isbn {
            isbnTextField.text = isbn
        }
        
        if let dateAdded = manualSearchData?.dateAdded {
            dateAddedTextField.text = dateAdded
        }
        
        if let category = manualSearchData?.category {
            if !category.isEmpty {
                for i in 0..<category.count {
                    if i != 0 {
                        categoryTextField.text = categoryTextField.text + ", "
                    }
                    categoryTextField.text = categoryTextField.text + category[i]
                }
            }
        }
        
        if let publisher = manualSearchData?.publisher {
            publisherTextField.text = publisher
        }
        
        print("manualData firekey = " + (manualSearchData?.firKey)!)
        if let firKey = manualSearchData?.firKey {
            self.firKey = firKey
        }
        print("manualbook = " + firKey)
        
        updateSaveButtonState()
    }
    
    @IBAction func shareButton(_ sender: Any) {
        if (reader == me) {
            
        let alert = UIAlertController(title: "Share this book!", message: "", preferredStyle: .actionSheet)
        
        //Facebook
        let actionFacebook = UIAlertAction(title: "Share on Facebook", style: .default) { (action) in
            //Check if Facebook is connected
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
            {
                let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
                
                post.setInitialText("Book to share: " + self.titleTextField.text + " by: " + self.authorTextField.text )
                post.add(self.bookImage.image)
                
                self.present(post, animated: true, completion: nil)
            } else {
                self.shareAlert(service: "Facebook")
            }
        }
        
        //Twitter
        let actionTwitter = UIAlertAction(title: "Share on Twitter", style: .default) { (action) in
            //Check if Twitter is connected
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
            {
                let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
                
                 post.setInitialText("Book to share: " + self.titleTextField.text + " by: " + self.authorTextField.text )
                post.add(self.bookImage.image)
                
                self.present(post, animated: true, completion: nil)
            } else {
                self.shareAlert(service: "Twitter")
            }
        }
        
        //Lend
        let actionLend = UIAlertAction(title: "Lend this book!", style: .default) { (action) in
            self.lendBook()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        
        
        alert.addAction(actionFacebook)
        alert.addAction(actionTwitter)
        alert.addAction(actionLend)
        alert.addAction(actionCancel)
        
        
        self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Borrow this book!", message: "", preferredStyle: .actionSheet)
            
            let actionRequest = UIAlertAction(title: "Request book through Whatsapp", style: .default) { (action) in
                //share msg to whatsapp
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(actionRequest)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    

    private func lendBook() {
        let alert = UIAlertController(title: "Lend this book!", message: "", preferredStyle: .actionSheet)
        
        let actionScan = UIAlertAction(title: "Scan borrower's ID", style: .default) { (action) in
            //jump to qr scanner
            let alert2 = UIAlertController(title: "Lend for how many days?", message: nil, preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert2.addTextField { (textField) in
                textField.text = "14"
            }
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert2.textFields![0]
                
                self.performSegue(withIdentifier: "ShowQRScanner", sender: textField.text)
                
            }))
            alert2.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                alert2.dismiss(animated: true, completion: nil)
            }))
            self.present(alert2, animated: true, completion: nil)
            
        }
        let actionSave = UIAlertAction(title: "Save manually", style: .default) { (action) in
            self.state = "lend"
           self.viewDidLoad()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(actionScan)
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func shareAlert(service: String) {
        let alert = UIAlertController(title: "Error", message: "Not connected to \(service)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
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
        
        bookImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickPhoto(_ sender: UITapGestureRecognizer) {
        
        titleTextField.resignFirstResponder()
        authorTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (saveBtnTemp == nil) {
        saveBtnTemp = saveButton
        borrowBtnTemp = borrowButton
        }
        print("Firekey :", book?.firKey)
        print(state)
         self.navigationItem.rightBarButtonItems?.removeAll()
        if (state == "read") {
            ratingInput.isHidden = false
            ratingLabel.isHidden = false
            ownerField.isHidden = true
            ownerLbl.isHidden = true
            borrowDays.isHidden = true
            borrowLabel1.isHidden = true
            borrowLabel2.isHidden = true

            self.navigationItem.rightBarButtonItems?.append(saveBtnTemp!)
        } else {
            ratingInput.isHidden = true
            ratingLabel.isHidden = true
            ownerField.isHidden = false
            ownerLbl.isHidden = false
            borrowDays.isHidden = false
            borrowLabel1.isHidden = false
            borrowLabel2.isHidden = false
            self.navigationItem.rightBarButtonItems?.append(borrowBtnTemp!)
            if (state == "lend") {
                ownerLbl.text = "Lend to:"
            } else {
                ownerLbl.text = "Owned by:"
            }
            if (reader != me) {
                self.navigationItem.rightBarButtonItems?.removeAll()
            }
        
        }
        
        //Scroll
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+400)
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode(rawValue: 1)!
        
        //handle input
        titleTextField.delegate = self
        authorTextField.delegate = self
        ownerField.delegate = self
        
        if let book = book {
            navigationItem.title = book.title
            titleTextField.text = book.title
            authorTextField.text = book.author
            bookImage.image = book.photo
            ratingInput.rating = book.rating
            if (state == "borrow") {
                ownerLbl.text = "Owned by:"
                ownerField.text = book.owner != nil ? book.owner! : nil
            } else {
                ownerLbl.text = "Lent to:"
                ownerField.text = book.owner != nil ? book.owner! : nil
            }
            
            descriptionTextField.text = book.describeText
            publishedDateTextField.text = book.publishedDate
            isbnTextField.text = book.isbn
            dateAddedTextField.text = book.dateAdded
            publisherTextField.text = book.publisher
            if let category = book.category {
                if !category.isEmpty {
                    for i in 0..<category.count {
                        if i != 0 {
                            categoryTextField.text = categoryTextField.text + ", "
                        }
                        categoryTextField.text = categoryTextField.text + category[i]
                    }
                }
            }
        }

        // Do any additional setup after loading the view.
        if (reader != me) {
            let tb = toolBar.items
            let tbiShare = toolBar.items![5]
            let tbiSpace = toolBar.items![6]
            
            toolBar.items![0] = tbiSpace
            toolBar.items![1] = tbiSpace
            toolBar.items![2] = tbiSpace
            toolBar.items![3] = tbiShare
            toolBar.items![4] = tbiSpace
            toolBar.items![5] = tbiSpace
            toolBar.items![6] = tbiSpace
        }
        
        //text view placeholder
        if titleTextField.text == "Title" {
            //print("textField.text = " + titleTextField.text)
            titleTextField.textColor = UIColor.lightGray
        }
        
        if authorTextField.text == "Author" {
            authorTextField.textColor = UIColor.lightGray
        }
        
        if (dateAddedTextField.text == nil || dateAddedTextField.text == "") {
            dateAddedTextField.text = getTime()
        }
        
        if (ownerField.text == "Owner") {
            ownerField.textColor = UIColor.lightGray
        }
        if (rdays == nil) {
            if let date2 = book?.returnDate {
                rdays = Calendar.current.dateComponents([.day], from: Date(), to: date2).day!
            }
            rdays = 0
        }
        borrowDays.text = String(rdays)
        
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Save button
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        if(!(titleTextField.text?.isEmpty)!){
            navigationItem.title = titleTextField.text
        }
    }
    
    //MARK: Private function
    private func updateSaveButtonState() {
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == titleTextField {
                textView.text = "Title"
                textView.textColor = UIColor.lightGray
            }
            if textView == authorTextField {
                textView.text = "Author"
                textView.textColor = UIColor.lightGray
            }
            
            if textView == ownerField {
                textView.text = "Owner"
                textView.textColor = UIColor.lightGray
            }
        }
    }
    
    private func getTime() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        let timeStr = formatter.string(from: Date())
        return timeStr
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        guard let button = sender as? UIBarButtonItem, button === saveButton || button === borrowButton
            else {
            os_log("The save button was not pressed", log: OSLog.default, type:.debug)
                if let tar = segue.destination as? ManualISBNViewController {
                    tar.state = state
                }
                
                if let tar = segue.destination as? QRScannerController {
                    tar.book = book
                    tar.bday = Int(sender as! String)!
                }
                
            return
        }
        print("save or borrow")
        
        let title = titleTextField.text ?? ""
        let author = authorTextField.text ?? ""
        let photo = bookImage.image
        let rating = ratingInput.rating
        let describeText = descriptionTextField.text ?? ""
        let owner = ownerField.text
        let publishedDate = publishedDateTextField.text ?? ""
        let isbn = isbnTextField.text ?? ""
        let dateAdded = dateAddedTextField.text ?? ""
        let publisher = publisherTextField.text ?? ""
        let category = categoryTextField.text.components(separatedBy: ", ")
        
        var dc = DateComponents()
        let today = Date()
        if let addDay = Int(borrowDays.text!) {
           dc.day = addDay
        } else {
           dc.day = 14
        }
        
        let returnDate = Calendar.current.date(byAdding: dc, to: today)
        
        //print("bookFIR = " + (book?.firKey)!)
        //let bookFIR = book?.firKey
        // print("bookFIR = " + bookFIR!)
        if(book != nil) {
            firKey = (book?.firKey)!
        }
        
        book = Books(title: title, author: author, photo: photo, rating: rating, describeText: describeText, owner: owner, returnDate: returnDate, publishedDate: publishedDate, isbn: isbn, dateAdded: dateAdded, publisher: publisher, category: category,firKey: firKey)
        //book?.setFIRKey(uid: bookFIR)
    }
    
    //Hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }

}
