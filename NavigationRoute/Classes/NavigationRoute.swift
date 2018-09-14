//
//  NavigationRoute.swift
//  NavigationView
//
//  Created by ZeroJianMBP on 2017/10/22.
//  Copyright © 2017年 ZeroJian. All rights reserved.
//

import UIKit

public protocol NavigationRouteDelegate: class {
	func navigationRoute(route: NavigationRoute, nextViewDidShow nextView: UIView, topView: UIView)
	func navigationRoute(route: NavigationRoute, topViewWillHidden topView: UIView, nextView: UIView)
	func navigationRoute(route: NavigationRoute, nextViewAnimation nextView: UIView, animated: Bool)
}

public class NavigationRoute: ViewSwitchAnimation {
	
	public var superView: UIView
	
	var nextViewAnimationAction: ((UIView, Bool) -> Void)?
		
	public var bottomInster: CGFloat = 0 {
		didSet {
			stackViewNavigation.bottomInster = bottomInster
		}
	}
	
	public var topInster: CGFloat = 0 {
		didSet {
			stackViewNavigation.topInster = topInster
		}
	}
	
	public var isAnimation: Bool {
		return stackViewNavigation.isAnimation
	}
	
	var superViewHeight: CGFloat = 0
	
	fileprivate var stackViewNavigation: StackViewNavigation
	
	public weak var delegate: NavigationRouteDelegate?
	
	public var lastView: UIView  {
		let views = stackViewNavigation.views
		if views.count >= 2 {
			return views[views.count - 2]
		}
		return stackViewNavigation.topView
	}
	
	public init(viewController:UIViewController, rootView: UIView) {
		stackViewNavigation = StackViewNavigation(viewController: viewController, rootView: rootView)
		self.superView = viewController.view
		self.superViewHeight = viewController.view.bounds.height
	}
	
	public func setupDelegate() {
		
		stackViewNavigation.nextViewDidShowAction = { [weak self] (topView, nextView) in
			guard let sself = self else { return }
			sself.delegate?.navigationRoute(route: sself, nextViewDidShow: nextView, topView: topView)
		}
		
		stackViewNavigation.topViewWillHiddenAction = { [weak self] (topView, nextView) in
			guard let sself = self else { return}
			sself.delegate?.navigationRoute(route: sself, topViewWillHidden: topView, nextView: nextView)
		}
		
		stackViewNavigation.nextViewAnimationAction = { [weak self] (nextView, animated) in
			guard let sself = self else { return }
			sself.delegate?.navigationRoute(route: sself, nextViewAnimation: nextView, animated: animated)
		}
		
		nextViewAnimationAction = { [weak self] (nextView, animated) in
			guard let sself = self else { return }
			sself.delegate?.navigationRoute(route: sself, nextViewAnimation: nextView, animated: animated)
		}
	}
	
	public func resetRootView(_ rootView: UIView){
		if stackViewNavigation.views.count > 0{
			stackViewNavigation.views[0] = rootView
		}
		stackViewNavigation.rootView = rootView
	}
	
	public func pushView(_ view: UIView, animated: Bool) -> Bool {
		return stackViewNavigation.pushView(view, animated: animated)
	}
	
	public func popToRootView(animated: Bool) -> Bool {
		return stackViewNavigation.popToRootView(animated: animated) != nil ? true : false
	}
	
	public func popView(animated: Bool) -> Bool {
		return stackViewNavigation.popView(animated: animated) != nil ? true : false
	}
	
	public func popToView(_ view: UIView, animated: Bool) -> Bool {
		return stackViewNavigation.popToView(view, animated: animated) != nil ? true : false
	}
	
	public func switchTopView(direction: StackViewNavigationOperation, nextView: UIView, animated: Bool) -> Bool {
		
		guard !stackViewNavigation.isAnimation else {
			print("switchTopView failure, 前一个动画还未结束")
			return false
		}
		
		guard stackViewNavigation.topView != nextView else {
			print("switchTopView failure, nextView 和 topView 是同一个 view")
			return false
		}
		
		delegate?.navigationRoute(route: self, topViewWillHidden: stackViewNavigation.topView, nextView: nextView)
		
		
		stackViewNavigation.isAnimation = true
		
		animation(operation: direction, topView: stackViewNavigation.topView, nextView: nextView, animated: animated) { (finished) in
			
			self.stackViewNavigation.topView = nextView
			
			self.stackViewNavigation.isAnimation = false
			
			self.stackViewNavigation.views.removeLast()
			// 防止更换的 topView 是 rootView
			if self.stackViewNavigation.views.count == 0 {
				self.stackViewNavigation.rootView = nextView
			}
			self.stackViewNavigation.views.append(nextView)
			
			let lastTopView = self.stackViewNavigation.lastTopView
			self.delegate?.navigationRoute(route: self, nextViewDidShow: nextView, topView: lastTopView)
			self.stackViewNavigation.lastTopView = nextView
		}
		
		return true
	}
}
