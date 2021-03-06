//
//  EmptyStateModel.swift
//  Clicker
//
//  Created by Kevin Chan on 8/30/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Foundation
import IGListKit

enum EmptyStateType {
    case pollsViewController(pollType: PollType)
    case cardController(userRole: UserRole)
    case draftsViewController(delegate: EmptyStateCellDelegate)
}

class EmptyStateModel {
    
    var type: EmptyStateType
    let identifier = UUID().uuidString
    
    init(type: EmptyStateType) {
        self.type = type
    }

}

extension EmptyStateModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? EmptyStateModel else { return false }
        return identifier == object.identifier
    }
    
}
