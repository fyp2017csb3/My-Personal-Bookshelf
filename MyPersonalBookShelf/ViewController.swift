//
//  ViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 8/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var book: Books?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let book = book {
            navigationItem.title = book.title
            titleLabel.text = book.title
            authorLabel.text = book.author
            bookImageView.image = book.photo
            ratingControl.rating = book.rating
        }
        
        //updateSaveButtonState()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Image of book
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else
        {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        bookImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectLibImage(_ sender: UITapGestureRecognizer) {
        //Controller for picking image
        let imagePickerController = UIImagePickerController()
        
        //Allow photo to be picked
        imagePickerController.sourceType = .photoLibrary
        
        //Notify view controller when image is picked
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Naviagation
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            os_log("The save button was not pressed", log: OSLog.default, type:.debug)
            return
        }
        
        let title = titleLabel
        let author = authorLabel
        let photo = bookImageView.image
        let rating = ratingControl.rating
        
        book = Books(title: title, author: author, photo: photo, rating: rating)
    }
*/
}

