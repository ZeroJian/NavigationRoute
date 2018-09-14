//
//  ViewController.swift
//  NavigationRoute
//
//  Created by zerojian on 07/06/2018.
//  Copyright (c) 2018 zerojian. All rights reserved.
//

import UIKit
import NavigationRoute

class ViewController: UIViewController {
	
	
	var page2Views: [UIView] = []

	var color: [UIColor] = [.red, .blue, .gray, .green, .orange, .black, .darkGray, .lightGray]
	
	var navigationView: NavigationView?
	
	var navigationRoute: NavigationRoute!
	
	var animated: Bool = true
	
	var page2Index: Int = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		navigationView = NavigationView()
		navigationView?.backgroundColor = .gray
		view.addSubview(navigationView!)
		
		navigationView?.snp.makeConstraints({ (maker) in
			maker.top.left.right.equalToSuperview()
			maker.height.equalTo(64)
		})
		
		view.layoutSubviews()
		
		navigationView?.setupView()
		
		navigationView?.backButtonAction = { [weak self] _ in
			self?.navigationRoute.popToRootView(animated: self?.animated ?? true)
		}
		
		navigationView?.updateRightButton(title: "animated", action: { (button) in
			self.animated = !self.animated
			let title = self.animated ? "animated" : "No animated"
			button.setTitle(title, for: .normal)
		})
		
		let rootView = UIView()
		rootView.backgroundColor = .white
		let label = UILabel()
		label.text = ""
		label.textColor = .black
		rootView.addSubview(label)
		
		let bottomRightButton = UIButton()
		bottomRightButton.tag = 1001
		bottomRightButton.setTitle("RootView push", for: .normal)
		bottomRightButton.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
		rootView.addSubview(bottomRightButton)
		bottomRightButton.setTitleColor(.blue, for: .normal)
		
		
		bottomRightButton.snp.makeConstraints({ (maker) in
			maker.center.equalToSuperview()
		})
		
		label.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
		}
		
		view.addSubview(rootView)
		rootView.snp.makeConstraints { (maker) in
			maker.top.equalToSuperview().inset(64)
			maker.left.right.bottom.equalToSuperview()
		}
		
		navigationRoute = NavigationRoute(viewController: self, rootView: rootView)
		navigationRoute.topInster = 64
		navigationRoute.setupDelegate()
		navigationRoute.delegate = self
		
		
		color.forEach({
			let view = UIView()
			view.backgroundColor = $0
			
			
			let label = UILabel()
			label.text = "Page2"
			label.textColor = .white
			label.font = UIFont.systemFont(ofSize: 20)
			view.addSubview(label)
			label.snp.makeConstraints({ (maker) in
				maker.top.equalToSuperview().inset(50)
				maker.right.equalToSuperview().inset(30)
			})
			
			let leftButton = UIButton()
			leftButton.setTitle("switch to left", for: .normal)
			leftButton.addTarget(self, action: #selector(switchLeftAction), for: .touchUpInside)
			view.addSubview(leftButton)
			leftButton.snp.makeConstraints({ (maker) in
				maker.centerY.equalToSuperview()
				maker.left.equalToSuperview().inset(30)
			})
			
			
			let rightButton = UIButton()
			rightButton.setTitle("switch to right", for: .normal)
			rightButton.addTarget(self, action: #selector(switchRightAction), for: .touchUpInside)
			view.addSubview(rightButton)
			rightButton.snp.makeConstraints({ (maker) in
				maker.centerY.equalToSuperview()
				maker.right.equalToSuperview().inset(30)
			})
			
			let bottomRightButton = UIButton()
			bottomRightButton.setTitle("push", for: .normal)
			bottomRightButton.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
			view.addSubview(bottomRightButton)
			bottomRightButton.snp.makeConstraints({ (maker) in
				maker.bottom.equalToSuperview().inset(50)
				maker.right.equalToSuperview().inset(30)
			})
			
			let bottomLeftButton = UIButton()
			bottomLeftButton.setTitle("pop", for: .normal)
			bottomLeftButton.addTarget(self, action: #selector(popAction), for: .touchUpInside)
			view.addSubview(bottomLeftButton)
			bottomLeftButton.snp.makeConstraints({ (maker) in
				maker.bottom.equalToSuperview().inset(50)
				maker.left.equalToSuperview().inset(30)
			})
			
			page2Views.append(view)
		})
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	@objc func switchLeftAction() {
		
		
		var switchPage = page2Index
		switchPage -= 1
		
		guard switchPage >= 0, page2Views.count  > switchPage else {
			return
		}
		let view = page2Views[switchPage]
		if navigationRoute.switchTopView(direction: .pop, nextView: view, animated: animated) {
			page2Index -= 1
			
		}
	}
	
	@objc func switchRightAction() {
		
		var switchPage = page2Index
		switchPage += 1
		
		guard switchPage >= 0, page2Views.count > switchPage else {
			return
		}
		let view = page2Views[switchPage]
		
		if navigationRoute.switchTopView(direction: .push, nextView: view, animated: animated) {
			page2Index += 1
			
		}
	}
	
	
	@objc func pushAction(sender: UIButton) {
		
		var view: UIView
		
		if sender.tag == 1001 {
			page2Index = 4
			view = page2Views[page2Index]
			
		} else {
			view = makeView(color: nil)
		}
		
		
		navigationRoute.pushView(view, animated: animated)
	}
	
	@objc func popAction() {
		navigationRoute.popView(animated: animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	func makeView(color: UIColor?) -> UIView {
		
		let view = UIView()
		view.backgroundColor = color
		let leftButton = UIButton()
		leftButton.setTitle("Pop", for: .normal)
		leftButton.setTitleColor(.blue, for: .normal)
		leftButton.addTarget(self, action: #selector(popAction), for: .touchUpInside)
		view.addSubview(leftButton)
		leftButton.snp.makeConstraints({ (maker) in
			maker.centerY.equalToSuperview()
			maker.left.equalToSuperview().inset(30)
		})
		
		
		let rightButton = UIButton()
		rightButton.setTitle("Push", for: .normal)
		rightButton.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
		rightButton.setTitleColor(.blue, for: .normal)

		view.addSubview(rightButton)
		rightButton.snp.makeConstraints({ (maker) in
			maker.centerY.equalToSuperview()
			maker.right.equalToSuperview().inset(30)
		})
		
		
		return view
	}

}

extension ViewController: NavigationRouteDelegate {
	
	func navigationRoute(route: NavigationRoute, nextViewDidShow nextView: UIView, topView: UIView) {
		print("nextViewDidShow")
	}
	
	func navigationRoute(route: NavigationRoute, topViewWillHidden topView: UIView, nextView: UIView) {
		print("topViewWillHidden")
	}
	
	func navigationRoute(route: NavigationRoute, nextViewAnimation nextView: UIView, animated: Bool) {
		print("nextViewAnimation")
	}
	
}

