//
//  uidQRScannerViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 17/4/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import AVFoundation

class uidQRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    var video = AVCaptureVideoPreviewLayer()
    let qrType = [AVMetadataObject.ObjectType.qr]
    //Session
    let session = AVCaptureSession()
    var qrCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Define Capture Device
        let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        if(captureDevice != nil){
            do
            {
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                session.addInput(input)
            }
            catch
            {
                print("Failed to get caputre device input")
            }
        }
        else if(captureDevice == nil) {
            print("captureDevice is nil")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //Set recognizing barcode
        output.metadataObjectTypes = qrType
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if !object.stringValue!.isEmpty {
                    qrCode = object.stringValue!
                    self.session.stopRunning()
                    performSegue(withIdentifier: "unwindToFriendsList", sender: self)
                } else {
                    let scanAlert = UIAlertController(title: "Book not available", message: "The information of the book was not found in the database", preferredStyle: .alert)
                    scanAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(scanAlert, animated: true, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            
        case "unwindToFriendsList":
            let destination = segue.destination as! FdsTableViewController
            destination.qrCode = self.qrCode
            
        default:
            print("Error unwind to friends list")
            //fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
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
