//
//  QuestionSectionController.swift
//  Clicker
//
//  Created by Kevin Chan on 8/31/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit

class QuestionSectionController: ListSectionController {
    
    // MARK: - Data vars
    var questionModel: QuestionModel!
    var userRole: UserRole!
    
    // MARK: - Constants
    let questionLabelVerticalPadding: CGFloat = 10
    
    init(userRole: UserRole) {
        self.userRole = userRole
    }
    
    // MARK: - ListSectionController overrides
    override func sizeForItem(at index: Int) -> CGSize {
        guard let containerSize = collectionContext?.containerSize else {
            return .zero
        }
        let questionLabelWidth = containerSize.width - LayoutConstants.cardHorizontalPadding * 2
        let cellHeight = questionModel.question.height(withConstrainedWidth: questionLabelWidth, font: ._20HeavyFont) + questionLabelVerticalPadding
        return CGSize(width: containerSize.width, height: cellHeight)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: QuestionCell.self, for: self, at: index) as! QuestionCell
        cell.configure(for: questionModel, userRole: userRole)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    override func didUpdate(to object: Any) {
        questionModel = object as? QuestionModel
    }
    
}
