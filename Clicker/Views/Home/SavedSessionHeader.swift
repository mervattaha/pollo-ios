//
//  SavedSessionHeader.swift
//  Clicker
//
//  Created by Kevin Chan on 2/14/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

class SavedSessionHeader: UITableViewHeaderFooterView {
    
    var headerLabel: UILabel!
    
    // MARK: - INITIALIZATION
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        headerLabel = UILabel()
        headerLabel.text = "Saved Sessions"
        headerLabel.font = UIFont._16SemiboldFont
        headerLabel.textColor = UIColor.clickerMediumGray
        addSubview(headerLabel)
        
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        headerLabel.snp.makeConstraints { make in
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
