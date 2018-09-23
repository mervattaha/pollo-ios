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
    
    func pollOptionsSectionControllerDidSubmitChoice(sectionController: PollOptionsSectionController, choice: String)
    func pollOptionsSectionControllerDidUpvoteChoice(sectionController: PollOptionsSectionController, choice: String)
    
}

class PollOptionsSectionController: ListSectionController {
    
    // MARK: - Data vars
    var delegate: PollOptionsSectionControllerDelegate!
    var pollOptionsModel: PollOptionsModel!
    
    init(delegate: PollOptionsSectionControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - ListSectionController overrides
    override func sizeForItem(at index: Int) -> CGSize {
        guard let containerSize = collectionContext?.containerSize else {
            return .zero
        }
        let cellHeight = calculatePollOptionsCellHeight(for: pollOptionsModel, state: delegate.cardControllerState)
        return CGSize(width: containerSize.width, height: cellHeight)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: PollOptionsCell.self, for: self, at: index) as! PollOptionsCell
        cell.configure(for: pollOptionsModel, delegate: self)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        pollOptionsModel = object as? PollOptionsModel
    }
    
}

extension PollOptionsSectionController: PollOptionsCellDelegate {
    
    var cardControllerState: CardControllerState {
        return delegate.cardControllerState
    }
    
    var userRole: UserRole {
        return delegate.userRole
    }

    func pollOptionsCellDidSubmitChoice(choice: String) {
        delegate.pollOptionsSectionControllerDidSubmitChoice(sectionController: self, choice: choice)
    }
    
    func pollOptionsCellDidUpvoteChoice(choice: String) {
        delegate.pollOptionsSectionControllerDidUpvoteChoice(sectionController: self, choice: choice)
    }
    
}