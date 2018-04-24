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
    var borrower:String?
    
    private func lendBook(uid:String) {
        book.saveFireBorrow(uid: uid, bday: bday)
        self.navigationController?.popViewController(animated: true)
    }
    
    func bypass() {
        borrower = "DEBUGGER"
        performSegue(withIdentifier: "ShowLend", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //byPasser
        //bypass()
        //byPasserEnd
        
        
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

    
    func gotID(id:String,completion: @escaping () -> Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").child(id).child("name").observeSingleEvent(of: .value) { (snapshot) in
            print("Snapshot:",snapshot.value as! String)
            if (snapshot.value != nil) {
                print("haveSnap")
                self.borrower = snapshot.value as! String
                print("bor",self.borrower!)
            }
            completion()
        }
    }


    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if !object.stringValue!.isEmpty {
                    self.session.stopRunning()
                    lendBook(uid: object.stringValue!)
                    print(object.stringValue!)
                    gotID(id: object.stringValue!) {
                        if let tabBarController = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController {
                            tabBarController.selectedIndex = 2
                            let currentNavigationController = tabBarController.selectedViewController as! UINavigationController
                            let currentViewController = currentNavigationController.topViewController! as! BorrowTableViewController
                            self.book.owner = self.borrower!
                            var dc = DateComponents()
                            let today = Date()
                            dc.day = self.bday
                            
                            self.book.returnDate = Calendar.current.date(byAdding: dc, to: today)
                            currentViewController.state = "lend"
                            currentViewController.navigationItem.title = "Lend"
                            
                            currentViewController.lbooks = currentViewController.loadLBooks()!
                            self.book = self.book.saveFirebook(uid: (me?.UID)!, cat: "lbooks")
                            currentViewController.lbooks.append(self.book)
                            currentViewController.books = currentViewController.lbooks
                            currentViewController.saveBooks()
                            currentViewController.tableView.reloadData()
                            self.navigationController?.pushViewController(currentViewController, animated: true)
//                            currentViewController.performSegue(withIdentifier: "ShowLend", sender: self)
                        }
                    }
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
            book.owner = borrower!
            var dc = DateComponents()
            let today = Date()
            dc.day = bday
            
            book.returnDate = Calendar.current.date(byAdding: dc, to: today)
           let tar = segue.destination as! BorrowTableViewController
            tar.state = "lend"
            tar.navigationItem.title = "Lend"
            tar.navigationController?.isNavigationBarHidden = false
           tar.lbooks = tar.loadLBooks()!
           tar.lbooks.append(book)
           tar.books = tar.lbooks
           tar.saveBooks()
           tar.tableView.reloadData()
            
           
            
            
            
        default:
            print(segue.identifier)
            //fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    


}
