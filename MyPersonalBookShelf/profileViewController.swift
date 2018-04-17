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
    @IBOutlet weak var proPic: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBAction func qrButton(_ sender: Any) {
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
    
    @IBAction func pass(_ sender: Any) {
        let alert = UIAlertController(title: "Add Friend", message: "Passing data from old devices will erase all current data", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.

        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak alert] (_) in
            User.setUserID(newID: self.id.text!)
            me = User.getUser()
            alert?.dismiss(animated: true, completion: nil)
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
        if(id.isHidden) {
            idBtn.setTitle("Hide UID", for: .normal)
            id.isHidden = false
            passBtn.isHidden = false
        }
        else {
            idBtn.setTitle("Show UID", for: .normal)
            id.isHidden = true
            passBtn.isHidden = true
        }
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
