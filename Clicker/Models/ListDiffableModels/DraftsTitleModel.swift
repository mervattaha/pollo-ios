//
//  DraftsTitleModel.swift
//  Clicker
//
//  Created by Kevin Chan on 12/6/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Foundation
import IGListKit

class DraftsTitleModel {

    var numDrafts: Int
    let identifier = UUID().uuidString

    init(numDrafts: Int) {
        self.numDrafts = numDrafts
    }

}

extension DraftsTitleModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? DraftsTitleModel else { return false }
        return identifier == object.identifier
    }

}
