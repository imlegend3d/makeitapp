//
//  Category.swift
//  
//
//  Created by David on 2019-04-03.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
    
    @objc dynamic var order = 0
}
