//
//  StackViewNavigation.swift
//  StackViewNavigation
//
//  Created by ZeroJianMBP on 2017/10/19.
//  Copyright © 2017年 ZeroJian. All rights reserved.
//

import Foundation
import SnapKit

public enum StackViewNavigationOperation: Int {
	case none
	case push
	case pop
}

class StackViewNavigation: ViewSwitchAnimation {
	
	enum ViewStatus {
		case didShow, willHidden
	}
	
	var views: [UIView] = []
	
	var isAnimation: Bool = false
	
	var topView: UIView
	
	var rootView: UIView
	
	// 用来临时保存上一个 topView
	var lastTopView: UIView
		
	fileprivate(set) weak var superViewController: UIViewController?
	
	var superView: UIView
	
	var nextViewAnimationAction: ((UIView, Bool) -> Void)?
	
	var bottomInster: CGFloat = 0
	
	var topInster: CGFloat = 0
	
	var superViewHeight: CGFloat = 0
	
	var nextViewDidShowAction: ((UIView, UIView) -> Void)?
	
	var topViewWillHiddenAction: ((UIView, UIView) -> Void)?
	
	fileprivate var animationDuration: TimeInterval = 0.4
	
	init(viewController:UIViewController, rootView: UIView) {
		self.superViewController = viewController
		self.superView = viewController.view
		self.superViewHeight = viewController.view.bounds.height
		self.rootView = rootView
		self.topView = rootView
		self.lastTopView = rootView
		views.append(rootView)
	}
	
	/// push 到某个 view
	///
	/// - Parameters:
	///   - view: view
	///   - animated: 动画
	func pushView(_ view: UIView, animated: Bool) -> Bool {
				
//		if App.configuration == .debug {
			self.showDebugPage(nextView: view)
//		}
		
		let success = viewAnimation(operation: .push, nextView: view, animated: animated) { (finished) in
			if finished {
				self.views.append(view)
			}
		}
		return success
	}
	
	/// 从当前视图弹出
	///
	/// - Parameter animated: 动画
	/// - Returns: 返回被弹出的 view
	func popView(animated: Bool) -> UIView? {
		
		guard views.count - 2 >= 0 else {
			print("popView failure, 已经是 rootView")
			return nil
		}
		
		let nextView = views[views.count - 2]
		
		let success = viewAnimation(operation: .pop, nextView: nextView, animated: animated) { (finished) in
			self.views.removeLast()
		}
		
		return success ? topView : nil
	}
	
	
	/// 弹出视图到某个 view
	///
	/// - Parameters:
	///   - view: view
	///   - animated: 动画
	/// - Returns: 返回被弹出的 views
	func popToView(_ view: UIView, animated: Bool) -> [UIView]? {
		
		guard let index = views.index(of: view) else {
			print("PopToView failure, 无法找到当前 view")
			return nil
		}
		
		guard views.last != view else {
			print("PopToView failure, 和当前 topView 是同一个 view")
			return nil
		}
		
		let viewsSlice = views[0...index]
		let popedSlice = views[(index + 1)...]
		
		let success = viewAnimation(operation: .pop, nextView: view, animated: animated) { (finished) in
			if finished {
				self.views = Array(viewsSlice)
			}
		}
		
		return success ? Array(popedSlice) : nil
	}
	
	
	/// 弹出视图到 stack 根视图
	///
	/// - Parameter animated: 动画
	/// - Returns: 返回被弹出的 views
	func popToRootView(animated: Bool) -> [UIView]? {
		
		guard rootView != topView else {
			print("popToRootView failure, 和当前 topView 是同一个 view")
			return nil
		}
		
		var popedView = views
		popedView.removeFirst()
		
		let success = viewAnimation(operation: .pop, nextView: rootView, animated: animated) { (finished) in
						if finished {
							self.views = [self.rootView]
						}
					}
		
		return success ? popedView : nil
	}
	
	
	/// 弹出视图到一个新的 stack root view
	///
	/// - Parameters:
	///   - view: view
	///   - animated: 动画
	/// - Returns: 返回上一个 rootView 和 弹出的 views
	func popToNewRootView(view: UIView, animated: Bool) -> (UIView?, [UIView]?) {
		
		guard view != topView else {
			print("popToNewRootView failure, 和当前 topView 是同一个 view")
			return (nil, nil)
		}
		
		guard !isAnimation else {
			print("popToNewRootView failure, 前一个动画还未结束")
			return (nil, nil)
		}
		
		rootView = view
		let lastRootView = views.removeFirst()
		views.insert(view, at: 0)
		
		return (lastRootView, popToRootView(animated: animated))
	}
}

extension StackViewNavigation {
	
	fileprivate func viewAnimation(operation: StackViewNavigationOperation, nextView: UIView, animated: Bool, completion: ((Bool) -> Void)?) -> Bool {
		
		guard !isAnimation else {
			print("veiwAnimation failure, 前一个动画还未结束")
			return false
		}
				
		topViewWillHiddenAction?(topView, nextView)
		
		isAnimation = true
		
		animation(operation: operation, topView: topView, nextView: nextView, animated: animated) { (finished) in
			self.topView = nextView
			self.isAnimation = false
			completion?(finished)
			self.nextViewDidShowAction?(self.lastTopView, nextView)
			self.lastTopView = nextView
		}
		
		return true
	}
}

extension StackViewNavigation {
	
	func showDebugPage(nextView: UIView) {
		
		let nextPage = views.count + 1
		let label = UILabel()
		label.textColor = .black
		label.font = UIFont.systemFont(ofSize: 16)
		label.text = "Debug: 第 \(nextPage) 页"
		
		label.frame = CGRect(x: 10, y: 100, width: 150, height: 30)
		nextView.addSubview(label)
	}
	
}

protocol ViewSwitchAnimation {
	var superView: UIView { get set }
	var superViewHeight: CGFloat { get set }
	var nextViewAnimationAction: ((UIView, Bool) -> Void)? { get set }
	var bottomInster: CGFloat { get set }
	var topInster: CGFloat { get set }
}

extension ViewSwitchAnimation {
	
	func animation(operation: StackViewNavigationOperation, topView: UIView, nextView: UIView, animated: Bool,completion: ((Bool) -> Void)?) {
		
		superView.addSubview(nextView)
		
		var nextViewInsetWidth: CGFloat = superView.bounds.width
		var topViewInsetWidth: CGFloat = superView.bounds.width
		
		switch operation {
		case .pop:
			nextViewInsetWidth = -superView.bounds.width
			topViewInsetWidth = superView.bounds.width

			
		case .push:
			nextViewInsetWidth = superView.bounds.width
			topViewInsetWidth = -superView.bounds.width
			
		default:
			return
		}
		
		nextView.snp.remakeConstraints { (maker) in
			maker.width.equalToSuperview()
			maker.top.equalToSuperview().inset(topInster)
			maker.bottom.equalToSuperview().inset(bottomInster)
			maker.centerX.equalToSuperview().inset(nextViewInsetWidth)
		}
		
		superView.layoutIfNeeded()
		
		topView.snp.remakeConstraints { (maker) in
			maker.top.equalToSuperview().inset(topInster)
			maker.width.equalToSuperview()
			maker.height.equalTo(topView.bounds.height)
			maker.centerX.equalToSuperview().inset(topViewInsetWidth)
		}
		
		nextView.snp.remakeConstraints({ (maker) in
			maker.width.equalToSuperview()
			maker.top.equalToSuperview().inset(topInster)
			maker.bottom.equalToSuperview().inset(bottomInster)
			maker.centerX.equalToSuperview()
		})
		
		if !animated {
			superView.layoutIfNeeded()
			nextViewAnimationAction?(nextView, false)
			topView.removeFromSuperview()
			completion?(true)
			return
		}
		
		UIView.animate(withDuration: 0.3, animations: {
			self.superView.layoutIfNeeded()
			self.nextViewAnimationAction?(nextView, true)
		}) { (finished) in
			topView.removeFromSuperview()
			completion?(finished)
		}
	}
	
}
