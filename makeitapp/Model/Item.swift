//
//  Item.swift
//  makeitapp
//
//  Created by David on 2019-04-03.
//  Copyright © 2019 David. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var color: String = ""
    @objc dynamic var order = 0
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
