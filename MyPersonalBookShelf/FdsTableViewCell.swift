//
//  BooksTableViewCell.swift
//  MyPersonalBookShelf
//
//  Created by FYP on 10/1/2018.
//  Copyright © 2018 FYP. All rights reserved.
//

import UIKit

class FdsTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

