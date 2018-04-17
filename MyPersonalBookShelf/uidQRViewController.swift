//
//  uidQRViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 17/4/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit

class uidQRViewController: UIViewController {
    @IBOutlet weak var qrImage: UIImageView!
    
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = uid.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        let image = UIImage(ciImage: (filter?.outputImage)!)
        
        qrImage.image = image

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
