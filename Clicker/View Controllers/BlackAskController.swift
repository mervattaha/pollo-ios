//
//  BlackViewController.swift
//  Clicker
//
//  Created by eoin on 4/15/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import Presentr

protocol EndPollDelegate {
    func endedPoll()
    func expandView(poll: Poll, socket: Socket) 
}

class BlackAskController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StartPollDelegate, EndPollDelegate, SocketDelegate {
    
    // name vars
    var nameView: NameView!
    
    // empty student vars
    var monkeyView: UIImageView!
    var nothingToSeeLabel: UILabel!
    var waitingLabel: UILabel!
    var downArrowImageView: UIImageView!
    var createPollButton: UIButton!
    
    // admin group vars
    var zoomOutButton: UIButton!
    var mainCollectionView: UICollectionView!
    let emptyAnswerCellIdentifier = "emptyAnswerCellID"
    let askedIdentifer = "askedCardID"
    let answerIdentifier = "answerCardID"
    let answerSharedIdentifier = "answerSharedCardID"
    var verticalCollectionView: UICollectionView!
    var countLabel: UILabel!
    
    // nav bar
    var navigationTitleView: NavigationTitleView!
    var peopleButton: UIButton!
    
    var socket: Socket!
    var sessionId: Int!
    var code: String!
    var name: String!
    var datePollsArr: [(String, [Poll])] = []
    var currentPolls: [Poll] = []
    var currentDatePollsIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clickerDeepBlack
        socket.addDelegate(self)
        setupNavBar()
        setupCreatePollBtn()
        if (datePollsArr.count == 0) {
            setupEmptyStudentPoll()
        } else {
            currentDatePollsIndex = datePollsArr.count - 1
            currentPolls = datePollsArr[currentDatePollsIndex].1
            setupAdminGroup()
        }
        if (name == code) {
            setupName()
        }
    }
   
    // MARK - NAME THE POLL
    
    func setupName() {
        nameView = NameView()
        nameView.sessionId = sessionId
        nameView.code = code
        nameView.name = name
        nameView.delegate = self

        view.addSubview(nameView)

        setupNameConstraints()
    }
    
    func updateNavBar() {
        navigationTitleView.updateViews(name: name, code: code)
    }
    
    func setupNameConstraints() {
        nameView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
    }

    @objc func createPollBtnPressed() {
        let pollBuilderVC = PollBuilderViewController()
        pollBuilderVC.startPollDelegate = self
        let nc = UINavigationController(rootViewController: pollBuilderVC)
        let presenter = Presentr(presentationType: .fullScreen)
        presenter.backgroundOpacity = 0.6
        presenter.roundCorners = true
        presenter.cornerRadius = 15
        presenter.dismissOnSwipe = true
        presenter.dismissOnSwipeDirection = .bottom
        customPresentViewController(presenter, viewController: nc, animated: true, completion: nil)
    }
    
    func setupCreatePollBtn() {
        createPollButton = UIButton()
        createPollButton.setTitle("Create a poll", for: .normal)
        createPollButton.backgroundColor = .clear
        createPollButton.layer.cornerRadius = 24
        createPollButton.layer.borderWidth = 1
        createPollButton.layer.borderColor = UIColor.white.cgColor
        createPollButton.addTarget(self, action: #selector(createPollBtnPressed), for: .touchUpInside)
        view.addSubview(createPollButton)
        
        createPollButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.45)
            make.height.equalToSuperview().multipliedBy(0.08)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-22)
        }
    }
    
    func setupEmptyStudentPoll() {
        setupEmptyStudentPollViews()
        setupEmptyStudentPollConstraints()
    }
    
    func removeEmptyStudentPoll() {
        monkeyView.removeFromSuperview()
        nothingToSeeLabel.removeFromSuperview()
        waitingLabel.removeFromSuperview()
        downArrowImageView.removeFromSuperview()
    }
    
    func setupEmptyStudentPollViews() {
        monkeyView = UIImageView(image: #imageLiteral(resourceName: "monkey_emoji"))
        monkeyView.contentMode = .scaleAspectFit
        view.addSubview(monkeyView)
        
        nothingToSeeLabel = UILabel()
        nothingToSeeLabel.text = "Nothing to see here."
        nothingToSeeLabel.font = ._16SemiboldFont
        nothingToSeeLabel.textColor = .clickerBorder
        nothingToSeeLabel.textAlignment = .center
        view.addSubview(nothingToSeeLabel)
        
        waitingLabel = UILabel()
        waitingLabel.text = "You haven't asked any polls yet!\nTry it out below."
        waitingLabel.font = ._14MediumFont
        waitingLabel.textColor = .clickerMediumGray
        waitingLabel.textAlignment = .center
        waitingLabel.lineBreakMode = .byWordWrapping
        waitingLabel.numberOfLines = 0
        view.addSubview(waitingLabel)
        
        downArrowImageView = UIImageView(image: #imageLiteral(resourceName: "down arrow"))
        downArrowImageView.contentMode = .scaleAspectFit
        view.addSubview(downArrowImageView)
    }
    
    func setupEmptyStudentPollConstraints() {
        monkeyView.snp.makeConstraints { make in
            make.width.equalTo(31)
            make.height.equalTo(34)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(142)
        }
        
        nothingToSeeLabel.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(19)
            make.centerX.equalToSuperview()
            make.top.equalTo(monkeyView.snp.bottom).offset(21)
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.width.equalTo(220)
            make.height.equalTo(36)
            make.centerX.equalToSuperview()
            make.top.equalTo(nothingToSeeLabel.snp.bottom).offset(11)
        }
        
        downArrowImageView.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(createPollButton.snp.top).offset(-20)
        }
    }
    
    func setupAdminGroup() {
        setupAdminGroupViews()
        setupAdminGroupConstraints()
    }
    
    func setupAdminGroupViews() {
        let layout = UICollectionViewFlowLayout()
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        let collectionViewInset = view.frame.width * 0.05
        mainCollectionView.contentInset = UIEdgeInsetsMake(0, collectionViewInset, 0, collectionViewInset)
        mainCollectionView.register(AskedCard.self, forCellWithReuseIdentifier: askedIdentifer)
        mainCollectionView.register(AnswerCard.self, forCellWithReuseIdentifier: answerIdentifier)
        mainCollectionView.register(AnswerSharedCard.self, forCellWithReuseIdentifier: answerSharedIdentifier)
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.isPagingEnabled = true
        view.addSubview(mainCollectionView)
        
        zoomOutButton = UIButton()
        zoomOutButton.setImage(#imageLiteral(resourceName: "zoomout"), for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOutBtnPressed), for: .touchUpInside)
        view.addSubview(zoomOutButton)
        
        countLabel = UILabel()
        let countString = "0/\(currentPolls.count)"
        countLabel.attributedText = getCountLabelAttributedString(countString)
        countLabel.textAlignment = .center
        countLabel.backgroundColor = UIColor.clickerLabelGrey
        countLabel.layer.cornerRadius = 12
        countLabel.clipsToBounds = true
        view.addSubview(countLabel)
    }

    func setupAdminGroupConstraints() {
        mainCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.bottom.equalTo(createPollButton.snp.top).offset(-12)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        zoomOutButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(mainCollectionView.snp.top)
            make.width.height.equalTo(20)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(mainCollectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(42)
            make.height.equalTo(23)
        }
    }
    
    // MARK: - COLLECTIONVIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == verticalCollectionView) {
            return datePollsArr.count
        } else { // mainCollectionView
            return currentPolls.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == verticalCollectionView) {
            // TODO
        }
         // mainCollectionView
        let poll = currentPolls[indexPath.item]
        let numOptions: Int? = poll.options?.count
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: askedIdentifer, for: indexPath) as! AskedCard
        cell.socket = socket
        cell.poll = poll
        cell.endPollDelegate = self
        if (poll.isLive) {
            cell.askedType = .live
        } else if (poll.isShared) {
            cell.askedType = .shared
        } else {
            cell.askedType = .ended
        }
        cell.setup()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == verticalCollectionView) {
            return CGSize()
        } else {
            let poll = currentPolls[indexPath.item]
            if (poll.isShared) {
                return CGSize(width: view.frame.width * 0.9, height: 415)
            } else {
                return CGSize(width: view.frame.width * 0.9, height: 440)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (collectionView == mainCollectionView) {
            // UPDATE COUNT LABEL
            let countString = "\(indexPath.item)/\(currentPolls.count)"
            countLabel.attributedText = getCountLabelAttributedString(countString)
        }
    }
    

    // MARK: UPDATE DATE POLLS ARRAY
    func updateDatePollsArr() {
        GetSortedPolls(id: sessionId).make()
            .done { datePollsArr in
                self.datePollsArr = datePollsArr
                self.currentPolls = datePollsArr[self.currentDatePollsIndex].1
                DispatchQueue.main.async { self.mainCollectionView.reloadData() }
            }.catch { error in
                print(error)
        }
    }
    
    // MARK: SCROLLVIEW METHODS
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView != mainCollectionView) {
            return
        }
        for cell in mainCollectionView.visibleCells {
            let indexPath = mainCollectionView.indexPath(for: cell)
            // Get cell frame
            guard let cellRect = mainCollectionView.layoutAttributesForItem(at: indexPath!)?.frame else {
                return
            }
            // Check if cell is fully visible
            if (mainCollectionView.bounds.contains(cellRect)) {
                let countString = "\(indexPath!.item)/\(currentPolls.count)"
                countLabel.attributedText = getCountLabelAttributedString(countString)
                break
            }
        }
    }
    
    // MARK: GET COUNT LABEL TEXT
    func getCountLabelAttributedString(_ countString: String) -> NSMutableAttributedString {
        let slashIndex = countString.index(of: "/")?.encodedOffset
        let attributedString = NSMutableAttributedString(string: countString, attributes: [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .bold),
            .foregroundColor: UIColor.clickerMediumGray,
            .kern: 0.0
            ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(white: 1.0, alpha: 0.9), range: NSRange(location: 0, length: slashIndex!))
        return attributedString
    }
    
    // MARK - SOCKET DELEGATE
    
    func sessionConnected() { }
    
    func sessionDisconnected() { }
    
    func receivedUserCount(_ count: Int) {
        peopleButton.setTitle("\(count)", for: .normal)
    }
    
    func pollStarted(_ poll: Poll) { }
    
    func pollEnded(_ poll: Poll) { }
    
    func receivedResults(_ currentState: CurrentState) {
        self.datePollsArr[datePollsArr.count - 1].1.last?.results = currentState.results
        DispatchQueue.main.async { self.mainCollectionView.reloadData() }
    }
    
    func saveSession(_ session: Session) { }
    
    func updatedTally(_ currentState: CurrentState) {
        self.datePollsArr[datePollsArr.count - 1].1.last?.results = currentState.results
        DispatchQueue.main.async { self.mainCollectionView.reloadData() }
    }
    
    // MARK: - START POLL DELEGATE
    func startPoll(text: String, type: String, options: [String]) {
        // EMIT START QUESTION
        let socketQuestion: [String:Any] = [
            "text": text,
            "type": type,
            "options": options
        ]
        socket.socket.emit("server/poll/start", with: [socketQuestion])
        let newPoll = Poll(text: text, options: options, isLive: true)
        let arrEmpty = (datePollsArr.count == 0)
        if (arrEmpty) {
            self.datePollsArr.append((getTodaysDate(), [newPoll]))
            self.currentDatePollsIndex = 0
            removeEmptyStudentPoll()
            setupAdminGroup()
        } else {
            self.datePollsArr[currentDatePollsIndex].1.append(newPoll)
        }
        self.currentPolls = self.datePollsArr[currentDatePollsIndex].1
        // HIDE CREATE POLL BUTTON
        createPollButton.alpha = 0
        createPollButton.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if (!arrEmpty) {
                self.mainCollectionView.reloadData()
            }
            let lastIndexPath = IndexPath(item: self.currentPolls.count - 1, section: 0)
            self.mainCollectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: ENDED POLL DELEGATE
    func endedPoll() {
        // SHOW CREATE POLL BUTTON
        createPollButton.alpha = 1
        createPollButton.isUserInteractionEnabled = true
    }
    
    func expandView(poll: Poll, socket: Socket) {
//        let expandedVC = ExpandedViewController()
//        expandedVC.setup()
//        expandedVC.expandedCard.socket = socket
//        socket.addDelegate(expandedVC.expandedCard)
//        expandedVC.expandedCard.poll = poll
//        expandedVC.expandedCard.questionLabel.text = poll.text
//        expandedVC.expandedCard.endPollDelegate = self
//        present(expandedVC, animated: true, completion: nil)
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        // REMOVE BOTTOM SHADOW
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationTitleView = NavigationTitleView()
        navigationTitleView.updateViews(name: name, code: code)
        navigationTitleView.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        self.navigationItem.titleView = navigationTitleView
        
        let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .done, target: self, action: #selector(goBack))
        
        let settingsImage = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
        let settingsBarButton = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: nil)
        
        peopleButton = UIButton()
        peopleButton.setImage(#imageLiteral(resourceName: "person"), for: .normal)
        peopleButton.setTitle("0", for: .normal)
        peopleButton.titleLabel?.font = UIFont._16RegularFont
        peopleButton.sizeToFit()
        let peopleBarButton = UIBarButtonItem(customView: peopleButton)
        self.navigationItem.rightBarButtonItems = [settingsBarButton, peopleBarButton]
    }
    
    
    // MARK: ACTIONS
    @objc func goBack() {
        socket.socket.disconnect()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func zoomOutBtnPressed() {
        // SETUP VERTICAL VIEW
        setupVertical()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // HIDE NAV BAR, SHOW TABBAR
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
