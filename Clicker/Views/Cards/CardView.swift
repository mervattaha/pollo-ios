//
//  CardView.swift
//  Clicker
//
//  Created by Kevin Chan on 5/6/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

protocol CardDelegate {
    func questionBtnPressed()
    func emitTally(answer: [String:Any])
}

class CardView: UIView, UITableViewDelegate, UITableViewDataSource, LiveOptionCellDelegate {
    
    var choice: Int?
    var totalNumResults: Int = 0
    let textFieldPadding = 18
    let textFieldHeight = 48
    var highlightColor: UIColor!
    
    var questionLabel: UILabel!
    var responseTextField: UITextField!
    var resultsTableView: UITableView!
    var graphicView: UIImageView!
    var visibilityLabel: UILabel!
    var totalResultsLabel: UILabel!
    var questionButton: UIButton!
    var infoLabel: UILabel!
    
    var cardDelegate: CardDelegate!
    var userRole: UserRole!
    var cardType: CardType!
    var questionType: QuestionType!
    var poll: Poll!
    var cardHeight: Int!
    var cardHeightConstraint: Constraint!
    
    let resultIdentifier = "resultCellID"
    let resultFRIdentifier = "resultFRCellID"
    let optionIdentifier = "optionCellID"
    
    // Expanded Card views
    var moreOptionsLabel: UILabel!
    var seeAllButton: UIButton!
    
    init(frame: CGRect, userRole: UserRole, cardDelegate: CardDelegate) {
        super.init(frame: frame)
        
        self.userRole = userRole
        self.cardDelegate = cardDelegate
        
        layer.cornerRadius = 15
        layer.borderColor = UIColor.clickerBorder.cgColor
        layer.borderWidth = 1
        layer.shadowRadius = 2.5
        backgroundColor = .clickerNavBarLightGrey
        
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        questionLabel = UILabel()
        questionLabel.font = ._22SemiboldFont
        questionLabel.textColor = .clickerBlack
        questionLabel.textAlignment = .left
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.numberOfLines = 0
        addSubview(questionLabel)
        
        resultsTableView = UITableView()
        resultsTableView.backgroundColor = .clear
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.separatorStyle = .none
        resultsTableView.isScrollEnabled = false
        resultsTableView.register(ResultCell.self, forCellReuseIdentifier: resultIdentifier)
        resultsTableView.register(ResultFRCell.self, forCellReuseIdentifier: resultFRIdentifier)
        resultsTableView.register(LiveOptionCell.self, forCellReuseIdentifier: optionIdentifier)
        addSubview(resultsTableView)
        
        if (userRole == .admin) {
            setupAdminViews()
            setupAdminConstraints()
        } else { // member
            setupMemberViews()
            setupMemberConstraints()
        }
        
        totalResultsLabel = UILabel()
        totalResultsLabel.text = "\(totalNumResults) votes"
        totalResultsLabel.font = ._12MediumFont
        totalResultsLabel.textAlignment = .right
        totalResultsLabel.textColor = .clickerMediumGray
        addSubview(totalResultsLabel)
        
    }
    
    func setupAdminViews() {
        visibilityLabel = UILabel()
        visibilityLabel.font = ._12MediumFont
        visibilityLabel.textAlignment = .left
        visibilityLabel.textColor = .clickerMediumGray
        addSubview(visibilityLabel)
        
        questionButton = UIButton()
        questionButton.titleLabel?.font = ._16SemiboldFont
        questionButton.titleLabel?.textAlignment = .center
        questionButton.layer.cornerRadius = 25.5
        questionButton.layer.borderWidth = 1.5
        questionButton.addTarget(self, action: #selector(questionAction), for: .touchUpInside)
        addSubview(questionButton)
        
        graphicView = UIImageView()
        addSubview(graphicView)
    }
    
    func setupAdminConstraints() {
        visibilityLabel.snp.makeConstraints{ make in
            make.left.equalTo(graphicView.snp.right).offset(4)
            make.width.equalTo(200)
            make.height.equalTo(14.5)
        }
        
        graphicView.snp.makeConstraints { make in
            make.width.height.equalTo(14.5)
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(visibilityLabel.snp.centerY)
        }
        
        questionButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(47)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        totalResultsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(visibilityLabel.snp.centerY)
        }
    }
    
    func setupMemberViews() {
        if (questionType == .freeResponse) {
            responseTextField = UITextField()
            responseTextField.layer.cornerRadius = 45
            responseTextField.placeholder = "Type a response"
            responseTextField.font = ._16MediumFont
            responseTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: textFieldPadding, height: textFieldHeight))
            responseTextField.leftViewMode = .always
            addSubview(responseTextField)
        }
        
        infoLabel = UILabel()
        infoLabel.font = ._12SemiboldFont
        addSubview(infoLabel)
    }
    
    func setupMemberConstraints() {
        if (questionType == .freeResponse) {
            responseTextField.snp.makeConstraints { make in
                make.top.equalTo(questionLabel.snp.bottom).offset(13.5)
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.9)
                make.height.equalTo(textFieldHeight)
            }
        }
        
        infoLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(15)
        }
        
        totalResultsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel.snp.centerY)
        }
    }
    
    func setupConstraints() {
        questionLabel.snp.makeConstraints{ make in
            questionLabel.sizeToFit()
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(17)
        }
        
        resultsTableView.snp.makeConstraints{ make in
            if (questionType == .freeResponse && userRole == .member) {
                make.top.equalTo(responseTextField.snp.bottom).offset(18)
            } else {
                make.top.equalTo(questionLabel.snp.bottom).offset(13.5)
            }
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(206)
        }
        
        totalResultsLabel.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-22.5)
            make.width.equalTo(50)
            make.height.equalTo(14.5)
        }
        
        if (userRole == .admin) {
            setupAdminConstraints()
        } else {
            setupMemberConstraints()
        }
    }
    
    func setupOverflow(numOptions: Int) {
        if (numOptions <= 4) {
            return
        }
        moreOptionsLabel = UILabel()
        moreOptionsLabel.text = "\(numOptions - 4) more options..."
        moreOptionsLabel.font = UIFont._12SemiboldFont
        moreOptionsLabel.textColor = .clickerDeepBlack
        addSubview(moreOptionsLabel)
        
        moreOptionsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(resultsTableView.snp.bottom).offset(9)
        }
        
        seeAllButton = UIButton()
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(.clickerBlue, for: .normal)
        seeAllButton.titleLabel?.font = UIFont._12SemiboldFont
        seeAllButton.addTarget(self, action: #selector(seeAllAction), for: .touchUpInside)
        addSubview(seeAllButton)
        
        seeAllButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(moreOptionsLabel.snp.centerY)
        }
    }
    
    func setupCard() {
        switch cardType {
        case .live:
            setupLive()
        case .ended:
            setupEnded()
        default: // shared
            setupShared()
        }
        setupOverflow(numOptions: (poll.options?.count)!)
    }
    
    func setupLive() {
        if (userRole == .admin) {
            visibilityLabel.text = "Only you can see these results"
            
            questionButton.setTitle("End Question", for: .normal)
            questionButton.backgroundColor = .clear
            questionButton.setTitleColor(.clickerDeepBlack, for: .normal)
            questionButton.layer.borderColor = UIColor.clickerDeepBlack.cgColor
            
            graphicView.image = #imageLiteral(resourceName: "solo_eye")
            
            visibilityLabel.snp.makeConstraints { make in
                make.bottom.equalTo(questionButton.snp.top).offset(-15)
            }
        } else {
            infoLabel.textColor = .clickerMediumGray
        }
    }
    
    func setupEnded() {
        if (userRole == .admin) {
            questionButton.setTitle("Share Results", for: .normal)
            questionButton.backgroundColor = .clickerGreen
            questionButton.setTitleColor(.white, for: .normal)
            questionButton.layer.borderColor = UIColor.clickerGreen.cgColor
            
            highlightColor = .clickerMint
            
            resultsTableView.reloadData()
            
            visibilityLabel.snp.makeConstraints { make in
                make.bottom.equalTo(questionButton.snp.top).offset(-15)
            }
        } else {
            infoLabel.textColor = .clickerDeepBlack
            infoLabel.text = "Poll has closed"
        }
    }
    
    func setupShared() {
        if (userRole == .admin) {
            if (questionButton.isDescendant(of: self)) {
                questionButton.removeFromSuperview()
            }
            visibilityLabel.text = "Shared with group"
            
            graphicView.image = #imageLiteral(resourceName: "results_shared")
            
            visibilityLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-20)
            }
            
        } else {
            infoLabel.textColor = .clickerDeepBlack
            infoLabel.text = "Poll has closed"
        }
    }
    
    // MARK - TABLEVIEW
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ADMIN
        if (userRole == .admin) {
            if (questionType == .freeResponse) {
                let cell = tableView.dequeueReusableCell(withIdentifier: resultFRIdentifier, for: indexPath) as! ResultFRCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: resultIdentifier, for: indexPath) as! ResultCell
                cell.choiceTag = indexPath.row
                cell.selectionStyle = .none
                cell.highlightView.backgroundColor = highlightColor
                
                // UPDATE HIGHLIGHT VIEW WIDTH
                let mcOption: String = intToMCOption(indexPath.row)
                var count: Int = 0
                if let choiceInfo = poll.results![mcOption] as? [String:Any] {
                    cell.optionLabel.text = choiceInfo["text"] as? String
                    count = choiceInfo["count"] as! Int
                    cell.numberLabel.text = "\(count)"
                }
                
                if (totalNumResults > 0) {
                    let percentWidth = CGFloat(Float(count) / Float(totalNumResults))
                    let totalWidth = cell.frame.width
                    cell.highlightWidthConstraint.update(offset: percentWidth * totalWidth)
                } else {
                    cell.highlightWidthConstraint.update(offset: 0)
                }
                return cell
            }
        }
        // MEMBER
        if (questionType == .freeResponse) {
            let cell = tableView.dequeueReusableCell(withIdentifier: resultFRIdentifier, for: indexPath) as! ResultFRCell
            cell.configure()
            return cell
        } else {
            switch cardType {
            case .live, .ended:
                let cell = tableView.dequeueReusableCell(withIdentifier: optionIdentifier, for: indexPath) as! LiveOptionCell
                cell.buttonView.setTitle(poll.options?[indexPath.row], for: .normal)
                cell.delegate = self
                cell.index = indexPath.row
                cell.chosen = (choice == indexPath.row)
                cell.setColors(isLive: poll.isLive)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: resultIdentifier, for: indexPath) as! ResultCell
                cell.choiceTag = indexPath.row
                cell.optionLabel.text = poll.options?[indexPath.row]
                cell.selectionStyle = .none
                cell.highlightView.backgroundColor = .clickerMint
                
                // UPDATE HIGHLIGHT VIEW WIDTH
                let mcOption: String = intToMCOption(indexPath.row)
                guard let info = poll.results![mcOption] as? [String:Any], let count = info["count"] as? Int else {
                    return cell
                }
                cell.numberLabel.text = "\(count)"
                let totalNumResults = poll.getTotalResults()
                if (totalNumResults > 0) {
                    let percentWidth = CGFloat(Float(count) / Float(totalNumResults))
                    let totalWidth = cell.frame.width
                    cell.highlightWidthConstraint.update(offset: percentWidth * totalWidth)
                } else {
                    cell.highlightWidthConstraint.update(offset: 0)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min((poll.options?.count)!, 4)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    // MARK - OptionViewDelegate
    func choose(_ choice: Int) {
        if (poll.isLive) {
            let answer: [String:Any] = [
                "googleId": User.currentUser?.id,
                "poll": poll.id,
                "choice": intToMCOption(choice),
                "text": poll.options![choice]
            ]
            cardDelegate.emitTally(answer: answer)
            self.choice = choice
            resultsTableView.reloadData()
            infoLabel.text = "Vote Sumbitted"
        }
    }
    
    // MARK: ACTIONS
    
    @objc func seeAllAction() {
        print("see all")
    }

    @objc func questionAction() {
        cardDelegate.questionBtnPressed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
