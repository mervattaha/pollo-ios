//
//  DeletePollViewController.swift
//  Clicker
//
//  Created by Kevin Chan on 5/1/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit

protocol EditNameViewControllerDelegate {
    func editNameViewControllerDidUpdateName()
}

class EditNameViewController: UIViewController {
    
    // MARK: - View vars
    var nameTextField: UITextField!
    var saveButton: UIButton!
    
    // MARK: - Data vars
    var delegate: EditNameViewControllerDelegate!
    var session: Session!

    // MARK: - Constants
    let edgePadding = 18
    let nameTextFieldHeight = 50
    let nameTextFieldTopPadding: CGFloat = 26
    let nameTextFieldWidthScale: CGFloat = 0.9
    let saveButtonWidthScale: CGFloat = 0.5
    let saveButtonHeight: CGFloat = 48
    let saveButtonBottomPadding: CGFloat = 16
    
    init(delegate: EditNameViewControllerDelegate, session: Session) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.session = session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clickerWhite
        self.title = "Edit Name"
        
        // Add Keyboard Handlers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        nameTextField = UITextField()
        nameTextField.placeholder = session.name
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.clickerGrey5.cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: edgePadding, height: nameTextFieldHeight))
        nameTextField.leftViewMode = .always
        nameTextField.becomeFirstResponder()
        view.addSubview(nameTextField)
        
        saveButton = UIButton()
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .clickerBlue
        saveButton.layer.cornerRadius = 25
        saveButton.addTarget(self, action: #selector(saveBtnPressed), for: .touchUpInside)
        view.addSubview(saveButton)
        
    }
    
    func setupConstraints() {
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(nameTextFieldTopPadding)
            make.width.equalToSuperview().multipliedBy(nameTextFieldWidthScale)
            make.height.equalTo(nameTextFieldHeight)
            make.centerX.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(saveButtonWidthScale)
            make.height.equalTo(saveButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(saveButtonBottomPadding)
        }
    }
    
    @objc func saveBtnPressed() {
        if let newName = nameTextField.text {
            if (newName != "") {
                UpdateSession(id: session.id, name: newName, code: session.code).make()
                    .done { code in
                        self.delegate.editNameViewControllerDidUpdateName()
                        self.dismiss(animated: true, completion: nil)
                    }.catch { error in
                        print("error: ", error)
                }
            }
        }
    }
    
    @objc func backCancelBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func exitBtnPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupNavBar() {
        let backImage = UIImage(named: "blackBack")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .done, target: self, action: #selector(backCancelBtnPressed))
        
        let exitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        exitButton.setImage(#imageLiteral(resourceName: "exit"), for: .normal)
        exitButton.addTarget(self, action: #selector(exitBtnPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: exitButton)
    }
    
    // MARK: - KEYBOARD
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.window?.frame.origin.y = -1 * keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.window?.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
