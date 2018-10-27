//
//  DateCell.swift
//  Clicker
//
//  Created by Kevin Chan on 8/31/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit
import SnapKit
import SwiftyJSON
import UIKit

protocol CardCellDelegate {
    
    var userRole: UserRole { get }

    func cardCellDidSubmitChoice(cardCell: CardCell, choice: String)
    func cardCellDidUpvote(cardCell: CardCell, answerId: String)
    func cardCellDidEndPoll(cardCell: CardCell, poll: Poll)
    func cardCellDidShareResults(cardCell: CardCell, poll: Poll)

}

class CardCell: UICollectionViewCell {
    
    // MARK: - View vars
    var shadowView: UIView!
    var collectionView: UICollectionView!
    var questionButton: UIButton!
    var timerLabel: UILabel!
    
    // MARK: - Data vars
    var delegate: CardCellDelegate!
    var poll: Poll!
    var adapter: ListAdapter!
    var topHamburgerCardModel: HamburgerCardModel!
    var questionModel: QuestionModel!
    var frInputModel: FRInputModel!
    var separatorLineModel: SeparatorLineModel!
    var pollOptionsModel: PollOptionsModel!
    var miscellaneousModel: PollMiscellaneousModel!
    var bottomHamburgerCardModel: HamburgerCardModel!
    var collectionViewRightPadding: CGFloat!
    var timer: Timer?
    
    // MARK: - Constants
    let collectionViewHorizontalPadding: CGFloat = 5.0
    let questionButtonFontSize: CGFloat = 16.0
    let questionButtonCornerRadius: CGFloat = 23.0
    let questionButtonBorderWidth: CGFloat = 1.0
    let questionButtonWidth: CGFloat = 170.0
    let questionButtonHeight: CGFloat = 47.0
    let questionButtonBottomPadding: CGFloat = 5.0
    let timerLabelFontSize: CGFloat = 14.0
    let timerLabelBottomPadding: CGFloat =  16.0
    let endPollText = "End Poll"
    let shareResultsText = "Share Results"
    let initialTimerLabelText = "00:00"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        topHamburgerCardModel = HamburgerCardModel(state: .top)
        frInputModel = FRInputModel()
        separatorLineModel = SeparatorLineModel(state: .card)
        bottomHamburgerCardModel = HamburgerCardModel(state: .bottom)
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.endEditing(true)
    }
    
    
    // MARK: - Layout
    func setupViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.backgroundColor = .clear
        contentView.addSubview(collectionView)
        
        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: nil)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        questionButton = UIButton()
        questionButton.titleLabel?.font = UIFont.systemFont(ofSize: questionButtonFontSize, weight: .semibold)
        questionButton.setTitleColor(.white, for: .normal)
        questionButton.layer.cornerRadius = questionButtonCornerRadius
        questionButton.layer.borderWidth = questionButtonBorderWidth
        questionButton.layer.borderColor = UIColor.white.cgColor
        questionButton.isHidden = true
        questionButton.addTarget(self, action: #selector(questionButtonTapped), for: .touchUpInside)
        contentView.addSubview(questionButton)
        
        timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: timerLabelFontSize, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.isHidden = true
        contentView.addSubview(timerLabel)
    }
    
    override func updateConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(collectionViewHorizontalPadding)
            make.trailing.equalToSuperview().inset(collectionViewHorizontalPadding)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(timerLabelBottomPadding)
        }
        
        questionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(timerLabel.snp.top).offset(questionButtonBottomPadding * -1)
            make.width.equalTo(questionButtonWidth)
            make.height.equalTo(questionButtonHeight)
        }
        super.updateConstraints()
    }
    
    // MARK: - Configure
    func configure(with delegate: CardCellDelegate, poll: Poll, userRole: UserRole) {
        self.delegate = delegate
        self.poll = poll
        let isMember = userRole == .member
        questionButton.isHidden = poll.state == .shared || isMember
        timerLabel.isHidden = !(poll.state == .live) || isMember
        if poll.state == .live {
            questionButton.setTitle(endPollText, for: .normal)
            setTimerText()
            runTimer()
        } else if poll.state == .ended {
            questionButton.setTitle(shareResultsText, for: .normal)
        }
        
        questionModel = QuestionModel(question: poll.text)
        pollOptionsModel = buildPollOptionsModel(from: poll, userRole: userRole)
        miscellaneousModel = PollMiscellaneousModel(questionType: poll.questionType, pollState: poll.state, totalVotes: poll.getTotalResults())
        adapter.performUpdates(animated: false, completion: nil)
    }

    // MARK: - Updates
    func update(with poll: Poll) {
        switch pollOptionsModel.type {
        case .mcResult(resultModels: _), .frOption(optionModels: _):
            guard let pollOptionsSectionController = adapter.sectionController(for: pollOptionsModel) as? PollOptionsSectionController else { return }
            let updatedPollOptionsModelType = buildPollOptionsModelType(from: poll, userRole: userRole)
            // Make sure to call update before updating pollOptionsMOdel.type so that the
            // we don't change the previous pollOptionsModel in pollOptionsSectionController.
            pollOptionsSectionController.update(with: updatedPollOptionsModelType)
            pollOptionsModel.type = updatedPollOptionsModelType
            miscellaneousModel = PollMiscellaneousModel(questionType: poll.questionType, pollState: poll.state, totalVotes: poll.getTotalResults())
            DispatchQueue.main.async {
                self.adapter.performUpdates(animated: false, completion: nil)
            }
        default:
            return
        }
    }
    
    // MARK: - Actions
    @objc func questionButtonTapped() {
        if poll.state == .live {
            poll.state = .ended
            questionButton.setTitle(shareResultsText, for: .normal)
            timerLabel.isHidden = true
            miscellaneousModel = PollMiscellaneousModel(questionType: poll.questionType, pollState: .ended, totalVotes: miscellaneousModel.totalVotes)
            adapter.performUpdates(animated: false, completion: nil)
            delegate.cardCellDidEndPoll(cardCell: self, poll: poll)
        } else if poll.state == .ended {
            poll.state = .shared
            questionButton.isHidden = true
            miscellaneousModel = PollMiscellaneousModel(questionType: poll.questionType, pollState: .shared, totalVotes: miscellaneousModel.totalVotes)
            adapter.performUpdates(animated: false, completion: nil)
            delegate.cardCellDidShareResults(cardCell: self, poll: poll)
        }
    }
    
    @objc func setTimerText() {
        guard let start = poll.startTime else {
            self.timerLabel.text = self.initialTimerLabelText
            return
        }
        let elapsedSeconds = Int(NSDate().timeIntervalSince1970 - start)
        if (elapsedSeconds < 10) {
            timerLabel.text = "00:0\(elapsedSeconds)"
        } else if (elapsedSeconds < 60) {
            timerLabel.text = "00:\(elapsedSeconds)"
        } else {
            let minutes = Int(elapsedSeconds / 60)
            let seconds = elapsedSeconds - minutes * 60
            if (elapsedSeconds < 600) {
                if (seconds < 10) {
                    timerLabel.text = "0\(minutes):0\(seconds)"
                } else {
                    timerLabel.text = "0\(minutes):\(seconds)"
                }
            } else {
                if (seconds < 10) {
                    timerLabel.text = "\(minutes):0\(seconds)"
                } else {
                    timerLabel.text = "\(minutes):\(seconds)"
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func runTimer() {
        if let t = timer {
            t.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setTimerText), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CardCell: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let questionModel = questionModel, let pollOptionsModel = pollOptionsModel, let miscellaneousModel = miscellaneousModel else { return [] }
        var objects: [ListDiffable] = []
        objects.append(topHamburgerCardModel)
        objects.append(questionModel)
        if userRole == .member && poll.questionType == .freeResponse && poll.state == .live {
            objects.append(frInputModel)
        }
        if userRole == .admin {
            objects.append(miscellaneousModel)
        }
        objects.append(separatorLineModel)
        objects.append(pollOptionsModel)
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is QuestionModel {
            return QuestionSectionController()
        } else if object is FRInputModel {
            return FRInputSectionController(delegate: self)
        } else if object is PollOptionsModel {
            return PollOptionsSectionController(delegate: self)
        } else if object is PollMiscellaneousModel {
            return PollMiscellaneousSectionController()
        } else if object is HamburgerCardModel {
            return HamburgerCardSectionController()
        } else {
            return SeparatorLineSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension CardCell: FRInputSectionControllerDelegate {
    
    func frInputSectionControllerSubmittedResponse(sectionController: FRInputSectionController, response: String) {
        guard let pollOptionsModel = pollOptionsModel else { return }
        switch pollOptionsModel.type {
        case .frOption(optionModels: var frOptionModels):
            delegate.cardCellDidSubmitChoice(cardCell: self, choice: response)
        default:
            return
        }
    }
    
    // MARK: - Helpers
    private func checkIfResponseIsNew(for response: String, frOptionModels: [FROptionModel]) -> Bool {
        return frOptionModels.first { (frOptionModel) -> Bool in
            return response == frOptionModel.option
            } == nil
    }
    
    private func indexOfFROptionModel(for answer: String, frOptionModels: [FROptionModel]) -> Int? {
        let indexOptionPair = frOptionModels.enumerated().first { (index, frOptionModel) -> Bool in
            return answer == frOptionModel.option
        }
        return indexOptionPair?.offset
    }
    
    private func addFRResponseToPoll(response: String, poll: Poll) {
        poll.options = [response]
        poll.results[response] = [
            ParserKeys.textKey: response,
            ParserKeys.countKey: 1
        ]
    }
}

extension CardCell: PollOptionsSectionControllerDelegate {
    
    var userRole: UserRole {
        return delegate.userRole
    }
    
    func pollOptionsSectionControllerDidSubmitChoice(sectionController: PollOptionsSectionController, choice: String) {
        delegate.cardCellDidSubmitChoice(cardCell: self, choice: choice)
    }

    func pollOptionsSectionControllerDidUpvote(sectionController: PollOptionsSectionController, answerId: String) {
        delegate.cardCellDidUpvote(cardCell: self, answerId: answerId)
    }
    
}
