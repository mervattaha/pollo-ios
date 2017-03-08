//
//  User.swift
//  Clicker
//
//  Created by AE7 on 3/8/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import RealmSwift

class User: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var netid: String = ""
 
    override class func primaryKey() -> String? {
        return "netid"
    }
}
