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
        
//        let data = uid.data(using: .ascii, allowLossyConversion: false)
//        let filter = CIFilter(name: "CIQRCodeGenerator")
//        filter?.setValue(data, forKey: "inputMessage")
//
//        let image = UIImage(ciImage: (filter?.outputImage)!)
        let size = CGSize(width: 240, height: 240)

        let image = convertTextToQRCode(text: uid, withSize: size)
        
        
        qrImage.image = image

        // Do any additional setup after loading the view.
    }
    
    func convertTextToQRCode(text: String, withSize size: CGSize) -> UIImage {
        
        let data = text.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("L", forKey: "inputCorrectionLevel")
        
        let qrcodeCIImage = filter.outputImage!
        
        let cgImage = CIContext(options:nil).createCGImage(qrcodeCIImage, from: qrcodeCIImage.extent)
        UIGraphicsBeginImageContext(CGSize(width: size.width * UIScreen.main.scale, height:size.height * UIScreen.main.scale))
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .none
        
        context?.draw(cgImage!, in: CGRect(x: 0.0,y: 0.0,width: context!.boundingBoxOfClipPath.width,height: context!.boundingBoxOfClipPath.height))
        
        let preImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let qrCodeImage = UIImage(cgImage: (preImage?.cgImage!)!, scale: 1.0/UIScreen.main.scale, orientation: .downMirrored)
        
        return qrCodeImage
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
