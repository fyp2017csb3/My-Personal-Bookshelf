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
    
    @IBOutlet weak var ownerField: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var borrowLabel1: UILabel!
    @IBOutlet weak var borrowLabel2: UILabel!
    @IBOutlet weak var borrowDays: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var book: Books?
    
    var manualSearchData: Books?
    var reader = me
    var state = "read"
    var saveBtnTemp : UIBarButtonItem?
    var borrowBtnTemp : UIBarButtonItem?
    
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
    
    @IBAction func unwindToInput(segue: UIStoryboardSegue) {
        if let bookTitle = manualSearchData?.title {
            titleTextField.text = bookTitle
        }
        if let bookAuthor = manualSearchData?.author {
            authorTextField.text = bookAuthor
        }
        
        if let bookPhoto = manualSearchData?.photo {
            bookImage.image = bookPhoto
        }
        
        if let describeText = manualSearchData?.describeText {
            descriptionTextField.text = describeText
        }
        
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
         self.navigationItem.rightBarButtonItems?.removeAll()
        if (state == "read") {
            ratingInput.isHidden = false
            ratingLabel.isHidden = false
            ownerField.isHidden = true
            borrowDays.isHidden = true
            borrowLabel1.isHidden = true
            borrowLabel2.isHidden = true

            self.navigationItem.rightBarButtonItems?.append(saveBtnTemp!)
        } else {
            ratingInput.isHidden = true
            ratingLabel.isHidden = true
            ownerField.isHidden = false
            borrowDays.isHidden = false
            borrowLabel1.isHidden = false
            borrowLabel2.isHidden = false
            self.navigationItem.rightBarButtonItems?.append(borrowBtnTemp!)
            if (state == "lend") {
                ownerField.text = "Lend to"
            }
        
        }
        
        //Scroll
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+400)
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode(rawValue: 1)!
        
        //handle input
        titleTextField.delegate = self
        authorTextField.delegate = self
        
        if let book = book {
            navigationItem.title = book.title
            titleTextField.text = book.title
            authorTextField.text = book.author
            bookImage.image = book.photo
            ratingInput.rating = book.rating
            descriptionTextField.text = book.describeText
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        guard let button = sender as? UIBarButtonItem, button === saveButton || button === borrowButton
            else {
            os_log("The save button was not pressed", log: OSLog.default, type:.debug)
            return
        }
        
        let title = titleTextField.text ?? ""
        let author = authorTextField.text ?? ""
        let photo = bookImage.image
        let rating = ratingInput.rating
        let describeText = descriptionTextField.text ?? ""
        let owner = ownerField.text
        
        var dc = DateComponents()
        let today = Date()
        if let addDay = Int(borrowDays.text!) {
           dc.day = addDay
        } else {
           dc.day = 14
        }
        
        let returnDate = Calendar.current.date(byAdding: dc, to: today)
        
        
        book = Books(title: title, author: author, photo: photo, rating: rating, describeText: describeText, owner:owner, returnDate:returnDate)
        
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
