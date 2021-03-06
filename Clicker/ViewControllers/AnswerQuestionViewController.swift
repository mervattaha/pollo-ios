//
//  AnswerQuestionViewController.swift
//  Clicker
//
//  Created by Keivan Shahida on 2/14/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

class AnswerQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var codeBarButtonItem: UIBarButtonItem!
    var endSessionBarButtonItem: UIBarButtonItem!
    var questionLabel: UILabel!
    var answerRecordedLabel: UILabel!
    var submitAnswerButton: UIButton!
    var session: Session!
    var poll: Poll!
    var pollCode: String!
    var question: Question!
    
    var selectedOptionIndex: Int?
    var optionTableView: UITableView!
    
    var freeResponseTextField: UITextField!
    
    
    //MARK: - INITIALIZATION
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clickerBackground
        UINavigationBar.appearance().barTintColor = .clickerGreen
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - SUBMIT
    @objc func submitAnswer() {
        if (question.options.count == 0 && freeResponseTextField.text != nil && freeResponseTextField.text != "") {
            // FR QUESTION
            // SHOW ANSWER RECORDED LABEL
            answerRecordedLabel.alpha = 1
            submitAnswerButton.backgroundColor = .clickerLightGray
            
            // SUBMIT FR ANSWER
            let answer: [String:Any] = [
                "deviceId": Device.id,
                "question": question.id,
                "choice": freeResponseTextField.text!,
                "text": freeResponseTextField.text!
            ]
            session.socket.emit("server/question/tally", with: [answer])
            
        }
        
        guard let index = selectedOptionIndex else { return }
        
        // SUBMIT MC ANSWER
        let answer: [String:Any] = [
            "deviceId": Device.id,
            "question": question.id,
            "choice": intToMCOption(index),
            "text": question.options[index]
        ]
        session.socket.emit("server/question/tally", with: [answer])
        // SHOW ANSWER RECORDED LABEL
        answerRecordedLabel.alpha = 1
        // RESET
        selectedOptionIndex = nil
        submitAnswerButton.backgroundColor = .clickerLightGray
    }
    
    // MARK: - TEXTFIELD
    @objc func beganTypingResponse(_ textField: UITextField) {
        if (textField.text != nil && textField.text != "") {
            submitAnswerButton.backgroundColor = .clickerBlue
        } else {
            submitAnswerButton.backgroundColor = .clickerLightGray
        }
    }
    
    // MARK: - LAYOUT
    func setupViews() {
        
        questionLabel = UILabel()
        questionLabel.text = question.text
        questionLabel.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        questionLabel.textColor = .clickerBlack
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.numberOfLines = 0
        view.addSubview(questionLabel)
        
        if (question.options.count > 0) {
            // MC QUESTION
            optionTableView = UITableView()
            optionTableView.delegate = self
            optionTableView.dataSource = self
            optionTableView.separatorStyle = .none
            optionTableView.clipsToBounds = true
            optionTableView.isScrollEnabled = false
            optionTableView.register(AnswerMCCell.self, forCellReuseIdentifier: "answerMCCellID")
            optionTableView.backgroundColor = .clear
            view.addSubview(optionTableView)
        } else {
            // FR QUESTION
            freeResponseTextField = UITextField()
            freeResponseTextField.font = UIFont._16RegularFont
            freeResponseTextField.placeholder = "Type response..."
            freeResponseTextField.layer.sublayerTransform = CATransform3DMakeTranslation(18, 0, 0)
            freeResponseTextField.backgroundColor = .white
            freeResponseTextField.addTarget(self, action: #selector(beganTypingResponse), for: .editingChanged)
            view.addSubview(freeResponseTextField)
        }
        
        answerRecordedLabel = UILabel()
        answerRecordedLabel.backgroundColor = .clickerBackground
        answerRecordedLabel.textAlignment = .center
        answerRecordedLabel.text = "Answer recorded. Select again to edit answer."
        answerRecordedLabel.font = UIFont.systemFont(ofSize: 14)
        answerRecordedLabel.alpha = 0
        view.addSubview(answerRecordedLabel)
        
        submitAnswerButton = UIButton()
        submitAnswerButton.backgroundColor = .clickerLightGray
        submitAnswerButton.layer.cornerRadius = 8
        submitAnswerButton.setTitle("Submit", for: .normal)
        submitAnswerButton.setTitleColor(.white, for: .normal)
        submitAnswerButton.titleLabel?.font = UIFont._18SemiboldFont
        submitAnswerButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        view.addSubview(submitAnswerButton)
        view.bringSubview(toFront: submitAnswerButton)
    }
    
    func setupConstraints() {
        questionLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: view.frame.width * 0.92, height: view.frame.height * 0.09))
            make.centerX.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(18)
        }
        
        if (question.options.count > 0) {
            // MC QUESTION
            optionTableView.snp.updateConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.top.equalTo(questionLabel.snp.bottom).offset(18)
                make.bottom.equalTo(answerRecordedLabel.snp.top).offset(-18)
            }
        } else {
            // FR QUESTION
            freeResponseTextField.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(54)
                make.top.equalTo(questionLabel.snp.bottom).offset(18)
            }
        }
        
        answerRecordedLabel.snp.updateConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(19)
            make.bottom.equalTo(submitAnswerButton.snp.top).offset(-18)
            make.centerX.equalToSuperview()
        }
        
        submitAnswerButton.snp.updateConstraints { make in
            make.width.equalTo(answerRecordedLabel.snp.width)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-18)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-18)
            }
        }
    }
 
    // MARK: - KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - TABLEVIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerMCCellID", for: indexPath) as! AnswerMCCell
        cell.choiceTag = indexPath.row
        cell.optionLabel.text = question.options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedOptionIndex == nil) {
            submitAnswerButton.backgroundColor = .clickerBlue
        }
        selectedOptionIndex = indexPath.row
    }
    
    // MARK: - SESSION
    @objc func endSession() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

