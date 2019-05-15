//
//  ContactCell.swift
//  makeitapp
//
//  Created by David on 2019-05-15.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import ChameleonFramework

class ContactCell: UITableViewCell {
    
    var link: ContactsViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //backgroundColor = FlatPurple()
        
        let shareListBtn = UIButton(type: .system)
        shareListBtn.setImage(UIImage(named: "file2"), for: .normal)
        shareListBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
       // shareListBtn.tintColor = FlatYellow()
        shareListBtn.addTarget(self, action: #selector(shareList), for: .touchUpInside)
        
        accessoryView = shareListBtn
        
        }
    
    @objc private func shareList(){
        
        link?.shareListWithFriends(cell: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
