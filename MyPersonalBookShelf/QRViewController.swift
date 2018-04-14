//
//  QRViewController.swift
//  MyPersonalBookShelf
//
//  Created by haruka on 3/4/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {
    
    var bbook : Books?
    
    @IBOutlet weak var QRImg: UIImageView!
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated:  true, completion: nil)
    }
    override func viewDidLoad() {
        
        let uid = me?.UID
        let data = uid?.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let img = UIImage(ciImage: (filter?.outputImage)!)
        QRImg.image = img
        
        //upload uid to firebase
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
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

}
