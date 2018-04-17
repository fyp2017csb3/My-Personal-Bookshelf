//
//  User.swift
//  MyPersonalUserhelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit
import os.log

class User: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(UID, forKey: PropertyKey.UID)
        aCoder.encode(photo, forKey: PropertyKey.photo)
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        //Fail if no title
        
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
        let UID = aDecoder.decodeObject(forKey: PropertyKey.UID) as? String
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        self.init(name: name!, UID: UID!, photo: photo)
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let UserArchiveURL = DocumentsDirectory.appendingPathComponent("User")
    static let FdsArchiveURL = DocumentsDirectory.appendingPathComponent("Friends")
    
    //MARK: Properties
    var name: String
    var UID: String
    var photo: UIImage?
    
    struct PropertyKey {
        static let name = "name"
        static let UID = "UID"
        static let photo = "photo"
    }
    
    //MARK: Initialization
    init?(name: String, UID: String, photo: UIImage?){
        
        guard !UID.isEmpty else{
            return nil
        }
        
        
        self.name = name
        self.UID = UID
        self.photo = photo
    }
    
    static func getUser() -> User? {
        if let usr = NSKeyedUnarchiver.unarchiveObject(withFile: User.UserArchiveURL.path) as? User {
            if usr.photo == nil {
                setUserPic(newPic: UIImage(named: "profilePic")!)
            }
            return usr
        }
        else {
            let unq = UIDevice.current.identifierForVendor?.uuidString
            let usr = User(name: "Name",UID: unq!,photo: UIImage(named: "profilePic")!)
            NSKeyedArchiver.archiveRootObject(usr, toFile: User.UserArchiveURL.path)
            return usr
        }
    }
    static func setUserID(newID:String) {
        let usr = NSKeyedUnarchiver.unarchiveObject(withFile: User.UserArchiveURL.path) as? User
        usr?.UID = newID
        NSKeyedArchiver.archiveRootObject(usr, toFile: User.UserArchiveURL.path)
    }
    
    static func setUserName(newName:String) {
        let usr = NSKeyedUnarchiver.unarchiveObject(withFile: User.UserArchiveURL.path) as? User
        usr?.name = newName
        NSKeyedArchiver.archiveRootObject(usr, toFile: User.UserArchiveURL.path)
    }
    
    static func setUserPic(newPic:UIImage) {
        let usr = NSKeyedUnarchiver.unarchiveObject(withFile: User.UserArchiveURL.path) as? User
        usr?.photo = newPic
        NSKeyedArchiver.archiveRootObject(usr, toFile: User.UserArchiveURL.path)
    }

    
}

