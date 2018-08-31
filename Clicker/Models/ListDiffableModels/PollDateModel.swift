//
//  PollsDateModel.swift
//  Clicker
//
//  Created by Kevin Chan on 8/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Foundation
import IGListKit

class PollDateModel {
    
    var date: String
    var poll: Poll
    let identifier = UUID().uuidString
    
    init(date: String, poll: Poll) {
        self.date = date
        self.poll = poll
    }
    
}

extension PollDateModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? PollDateModel else { return false }
        return identifier == object.identifier
    }
}
