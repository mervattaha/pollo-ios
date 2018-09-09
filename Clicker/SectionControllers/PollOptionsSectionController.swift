//
//  PollOptionsModel.swift
//  Clicker
//
//  Created by Kevin Chan on 9/7/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit

protocol PollOptionsSectionControllerDelegate {
    
    var cardControllerState: CardControllerState { get }
    var userRole: UserRole { get }
    
}

class PollOptionsSectionController: ListSectionController {
    
    // MARK: - Data vars
    var delegate: PollOptionsSectionControllerDelegate!
    var pollOptionsModel: PollOptionsModel!
    
    // MARK: - Constants
    let maximumNumberVisibleOptions = 6
    
    init(delegate: PollOptionsSectionControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - ListSectionController overrides
    override func sizeForItem(at index: Int) -> CGSize {
        guard let containerSize = collectionContext?.containerSize else {
            return .zero
        }
        return CGSize(width: containerSize.width, height: calculatePollOptionsCellHeight(for: pollOptionsModel))
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: PollOptionsCell.self, for: self, at: index) as! PollOptionsCell
        cell.configure(for: pollOptionsModel, delegate: self)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        pollOptionsModel = object as? PollOptionsModel
    }
    
    // MARK: - Helpers
    private func calculatePollOptionsCellHeight(for pollOptionsModel: PollOptionsModel) -> CGFloat {
        let verticalPadding: CGFloat = LayoutConstants.pollOptionsVerticalPadding * 2
        var numOptions: Int = 0
        switch pollOptionsModel.type {
        case .mcResult(resultModels: let mcResultModels):
            numOptions = min(mcResultModels.count, maximumNumberVisibleOptions)
        case .mcChoice(choiceModels: let mcChoiceModels):
            numOptions = min(mcChoiceModels.count, maximumNumberVisibleOptions)
        }
        let optionsHeight: CGFloat = CGFloat(numOptions) * LayoutConstants.horizontalOptionCellHeight
        return verticalPadding + optionsHeight
    }
    
}

extension PollOptionsSectionController: PollOptionsCellDelegate {
    
    var cardControllerState: CardControllerState {
        return delegate.cardControllerState
    }
    
    var userRole: UserRole {
        return delegate.userRole
    }

}
