//
//  AskQuestionModel.swift
//  Clicker
//
//  Created by Kevin Chan on 12/6/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit

class AskQuestionModel: ListDiffable {

    var currentQuestion: String?
    let identifier = UUID().uuidString

    init(currentQuestion: String?) {
        self.currentQuestion = currentQuestion
    }

    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? AskQuestionModel else { return false }
        return identifier == object.identifier
    }

}
