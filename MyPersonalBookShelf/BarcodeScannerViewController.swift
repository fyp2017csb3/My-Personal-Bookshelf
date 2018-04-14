//
//  BarcodeScannerViewController.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 18/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: Properties
    var video = AVCaptureVideoPreviewLayer()
    let barcodeType = [AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code39Mod43, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.aztec, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.itf14, AVMetadataObject.ObjectType.interleaved2of5, AVMetadataObject.ObjectType.dataMatrix]
    
    //Struct of google book
    struct TopTier : Codable {
        var kind: String
        var totalItems: Int
        var items: [Item]
    }
    struct Item: Codable {
        var kind: String
        var id: String
        var etag: String
        var selfLink: String
        var volumeInfo: VolumeInfo
    }
    struct VolumeInfo: Codable {
        var title: String
        var subtitle: String?
        var authors: Array<String>?
        var description: String?
        var imageLinks: ImageLinks?
        var publishedDate: String?
        var industryIdentifiers: [ISBN]
        var publisher: String?
        var categories: Array<String>?
    }
    
    struct ISBN: Codable {
        var type: String?
        var identifier: String?
    }
    
    struct ImageLinks: Codable {
        var smallThumbnail: String?
        var thumbnail: String?
    }
    
    var book: Books?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Session
        let session = AVCaptureSession()
        
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
        output.metadataObjectTypes = barcodeType
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                //Check if barcode
                if object.type == AVMetadataObject.ObjectType.ean8 || object.type == AVMetadataObject.ObjectType.ean13
                {
                    let alert = UIAlertController(title: "Barcode", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { (nil) in
                        if !object.stringValue!.isEmpty {
                            let isbnInput = object.stringValue!
                            if self.searchByISBN(isbn: isbnInput) {
                                self.performSegue(withIdentifier: "unwindToInput", sender: self)
                            } else {
                                let scanAlert = UIAlertController(title: "Book not available", message: "The information of the book was not found in the database", preferredStyle: .alert)
                                scanAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                                self.present(scanAlert, animated: true, completion: nil)
                            }
                        }}))
                    
                    present(alert, animated: true, completion: nil)
                    /*if !object.stringValue!.isEmpty {
                     let isbnInput = object.stringValue!
                     if self.searchByISBN(isbn: isbnInput) {
                     self.performSegue(withIdentifier: "unwindToInput", sender: self)
                     } else {
                     let scanAlert = UIAlertController(title: "Book not available", message: "The information of the book was not found in the database", preferredStyle: .alert)
                     scanAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                     self.present(scanAlert, animated: true, completion: nil)
                     }
                     }*/
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ManualInputViewController {
            destination.manualSearchData = book
        }
    }
    
    //MARK: Private Function
    private func searchByISBN(isbn: String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var title = ""
        var author = ""
        var image = #imageLiteral(resourceName: "defaultBookImage")
        var describeText = ""
        var publishedDate = ""
        var baseIsbn = ""
        var dateAdded = ""
        var publisher = ""
        var category = [String]()
        
        var topTierData = [TopTier]()
        
        let jsonURL = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn
        print(jsonURL)
        let url = URL(string: jsonURL)
        
        let dataTask = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            else{
                do{
                    //Decode JSON
                    let jsonDecoder = JSONDecoder()
                    topTierData = try [jsonDecoder.decode(TopTier.self, from: data!)]
                    
                    //Check book title
                    print(topTierData[0].items[0].volumeInfo.title)
                    
                    title = topTierData[0].items[0].volumeInfo.title
                    if topTierData[0].items[0].volumeInfo.authors != nil {
                        author = topTierData[0].items[0].volumeInfo.authors![0]
                    }
                    
                    //Download Image
                    if topTierData[0].items[0].volumeInfo.imageLinks != nil {
                        if let imageLink = topTierData[0].items[0].volumeInfo.imageLinks!.thumbnail {
                            image = self.downloadImage(link: imageLink)
                        }
                    }
                    
                    //Description
                    if topTierData[0].items[0].volumeInfo.description != nil {
                        describeText = topTierData[0].items[0].volumeInfo.description!
                    }
                    
                    //PublishedDate
                    if topTierData[0].items[0].volumeInfo.publishedDate != nil {
                        publishedDate = topTierData[0].items[0].volumeInfo.publishedDate!
                    }
                    
                    //ISBN
                    
                    //dateAdded
                    
                    //publisher
                    if let checkedPublisher = topTierData[0].items[0].volumeInfo.publisher{
                        publisher = checkedPublisher
                    }
                    
                    //cateogry
                    if let checkedCategory = topTierData[0].items[0].volumeInfo.categories{
                        if !checkedCategory.isEmpty {
                            for i in 0..<checkedCategory.count {
                                category.append(checkedCategory[i])
                            }
                        }
                    }
                }
                catch
                {
                    print("Cannot decode the top tier data of the book.")
                }
                
                
                self.book = Books(title: title, author: author, photo: image, rating: 0, describeText: describeText, owner: nil, returnDate: nil, publishedDate: publishedDate, isbn: isbn, dateAdded: self.getTime(), publisher: publisher, category: category)
                sem.signal()
            }
            } as URLSessionTask
        
        dataTask.resume()
        
        sem.wait()
        if self.book?.title == nil {
            print("Enter alert")
            return false
        }
        print("URLSession Completed")
        return true
    }
    
    private func downloadImage(link: String) -> UIImage {
        let imgURL = NSURL(string: link)
        let imgData = NSData.init(contentsOf: imgURL! as URL)
        let image = UIImage(data: imgData! as Data)
        
        return image!
    }
    
    private func getTime() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        let timeStr = formatter.string(from: Date())
        return timeStr
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

