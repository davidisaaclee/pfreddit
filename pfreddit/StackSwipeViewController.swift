//
//  StackSwipeViewController.swift
//  pfreddit
//
//  Created by David Lee on 11/17/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class StackSwipeViewController: UIViewController {
	
	@IBInspectable var swipeThreshold: CGFloat = 200
	@IBInspectable var swipeVelocityThreshold: CGFloat = 1000
	
	var delegate: StackSwipeDelegate? {
		didSet {
			if delegate != nil {
				reloadDataFromDelegate(delegate!)
			}
		}
	}
	
	var activeViewControllers: [UIViewController] = []
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func reload() {
		if self.delegate != nil {
			reloadDataFromDelegate(self.delegate!)
		}
	}
	
	func reloadStackViewsWith(topView: UIViewController?, nextView: UIViewController?) -> () {
		activeViewControllers.forEach {
			$0.removeFromParentViewController()
			$0.view.removeFromSuperview()
		}
		
		activeViewControllers = []
		[nextView, topView]
			.flatMap { $0 }
			.forEach(pushCardViewController)
	}
	
	func reloadDataFromDelegate(d: StackSwipeDelegate) {
		if d.baseView != nil {
			view.addSubview(d.baseView!)
		}
		reloadStackViewsWith(d.topViewController, nextView: d.nextViewController)
	}
	
	func pushCardViewController(vc: UIViewController) {
		activeViewControllers.append(vc)
		addChildViewController(vc)
		vc.view.frame = view.frame
		view.addSubview(vc.view)
		vc.didMoveToParentViewController(self)
	}
	
	// MARK: - Touch interaction
	
	private var activeTouches: Dictionary<Int, (NSTimeInterval, CGPoint)> = [:]
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		activeTouches[touch.hash] = (touch.timestamp, touch.locationInView(self.view))
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let aTouch = touches.first {
			let pt = aTouch.locationInView(self.view)
			let prevPt = aTouch.previousLocationInView(self.view)
			let delta = CGPoint(x: pt.x - prevPt.x, y: pt.y - prevPt.y)
			
			if let topVC = activeViewControllers.last {
				var newFrame = topVC.view.frame
				newFrame.origin.x += delta.x
				topVC.view.frame = newFrame
			}
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		guard let startData = activeTouches[touch.hash] else {
			print("Could not find touch in activeTouches dictionary.")
			return
		}
		
		let deltaTime = touch.timestamp - startData.0
		let displacement = touch.locationInView(self.view).x - startData.1.x
		
		let velocity = displacement / CGFloat.init(deltaTime)
		
		if let topVC = activeViewControllers.last {
			let vcOffset = topVC.view.frame.origin.x
			switch true {
			case (vcOffset < -swipeThreshold), (velocity < -swipeVelocityThreshold):
				swipe(topVC, isSwipingLeft: true)
			case (vcOffset > swipeThreshold), (velocity > swipeVelocityThreshold):
				swipe(topVC, isSwipingLeft: false)
			default:
				unswipe(topVC)
			}
			
//			if vcOffset < -swipeThreshold {
//				swipe(topVC, isSwipingLeft: true)
//			} else if vcOffset > swipeThreshold {
//				swipe(topVC, isSwipingLeft: false)
//			} else if velocity > swipeVelocityThreshold {
//				swipe(
//			} else if velocity < -swipeVelocityThreshold {
//				
//			} else {
//				unswipe(topVC)
//			}
		}
	}


	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	
	func popCardViewController() {
		if let vc = activeViewControllers.last {
			activeViewControllers.popLast()
			vc.removeFromParentViewController()
			vc.view.removeFromSuperview()
		}
	}
	
	
	func swipe(toSwipe: UIViewController, isSwipingLeft: Bool) {
		UIView.animateWithDuration(0.1, animations: {
			if isSwipingLeft {
				toSwipe.view.frame.origin.x = 0 - toSwipe.view.frame.width
			} else {
				toSwipe.view.frame.origin.x = self.view.frame.width
			}
		}, completion: { (didComplete: Bool) -> () in
			if didComplete {
				self.popCardViewController()
				if self.delegate != nil {
					if isSwipingLeft {
						self.delegate!.didSwipeLeft()
					} else {
						self.delegate!.didSwipeRight()
					}
					
					self.reloadDataFromDelegate(self.delegate!)
				}
			}
		})
	}
	
	func unswipe (toSwipe: UIViewController) {
		UIView.animateWithDuration(0.1, animations: {
			toSwipe.view.frame.origin.x = 0
		})
	}
}



protocol StackSwipeDelegate {
	// What to show if no views in the stack.
	var baseView: UIView? { get }
	
	// The view currently on the top of the stack.
	var topViewController: UIViewController? { get }
	
	// The next view in the stack.
	var nextViewController: UIViewController? { get }
	
	// Checks if an interaction at the specified point should allow swiping.
	func isSwipeableAtPoint(point: CGPoint) -> Bool
	
	func didSwipeLeft()
	
	func didSwipeRight()
}