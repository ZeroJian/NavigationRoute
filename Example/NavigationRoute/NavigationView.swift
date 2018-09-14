//
//  NavigationView.swift
//  NavigationRoute_Example
//
//  Created by ZeroJianMBP on 2018/9/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import NavigationRoute

class NavigationView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	var backButton: UIButton!
	
	var rightButton: UIButton!
	
	var backButtonAction: ((UIButton) -> Void)?
	
	var rightButtonAction: ((UIButton) -> Void)?
	
	var titleLabel: UILabel!
	
	/// nil == hidden
	func updateRightButton(title: String?, action: ((UIButton) -> Void)? = nil) {
		if let title = title {
			rightButton.setTitle(title, for: .normal)
			rightButton.isHidden = false
			rightButtonAction = action
		} else {
			rightButton.isHidden = true
		}
	}
	
	func setupView() {
		
		
		let titleLabel = UILabel()
		titleLabel.text = "CustomView"
		addSubview(titleLabel)
		titleLabel.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
		}
		
		self.titleLabel = titleLabel
		
		let backButton = UIButton()
		backButton.setTitle("Back To Root", for: .normal)
		addSubview(backButton)
		
		backButton.snp.makeConstraints { (maker) in
			maker.centerY.equalToSuperview()
			maker.left.equalToSuperview().inset(10)
			maker.width.equalTo(150)
		}
		backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
		self.backButton = backButton
		
		
		let rightButton = UIButton()
		rightButton.isHidden = true
		addSubview(rightButton)
		rightButton.snp.makeConstraints { (maker) in
			maker.centerY.equalToSuperview()
			maker.right.equalToSuperview().inset(10)
		}
		rightButton.addTarget(self, action: #selector(rightButtonClicked), for: .touchUpInside)
		self.rightButton = rightButton
	}
	
	
	@objc func backButtonClicked(sender: UIButton) {
		
		backButtonAction?(sender)
		
	}
	
	@objc func rightButtonClicked(sender: UIButton) {
		rightButtonAction?(sender)
	}

}
