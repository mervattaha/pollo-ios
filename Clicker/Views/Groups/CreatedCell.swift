//
//  CreatedCell.swift
//  Clicker
//
//  Created by Kevin Chan on 3/28/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit

class CreatedCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    var groupsTableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - LAYOUT
    func setupViews() {
        groupsTableView = UITableView()
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        groupsTableView.register(GroupCell.self, forCellReuseIdentifier: "groupCellID")
        addSubview(groupsTableView)
    }
    
    func setupConstraints() {
        groupsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
