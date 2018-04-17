//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//
import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    var video = AVCaptureVideoPreviewLayer()
    let qrType = [AVMetadataObject.ObjectType.qr]
    //Session
    let session = AVCaptureSession()
    
    var book : Books!
    var bday = 14
    
    
    private func lendBook(uid:String) {
        book.saveFireBorrow(uid: uid, bday: bday)
        self.navigationController?.popViewController(animated: true)
    }
    
    
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
                    lendBook(uid: object.stringValue!)
                    self.session.stopRunning()
                    performSegue(withIdentifier: "ShowLend", sender: self)
                } else {
                    let scanAlert = UIAlertController(title: "Book not available", message: "The information of the book was not found in the database", preferredStyle: .alert)
                    scanAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(scanAlert, animated: true, completion: nil)
                    }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            
        case "ShowLend":
           let tar = segue.destination as! BorrowTableViewController
            tar.state = "lend"
           
           tar.saveLendBook(book:book)
        default:
            print(segue.identifier)
            //fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    


}
