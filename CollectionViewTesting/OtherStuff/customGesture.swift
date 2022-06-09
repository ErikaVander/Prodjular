//
//  customGesture.swift
//  TestingDragAndDrop
//
//  Created by Vanderhoff on 4/26/22.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum SymbolPhase {
	case notStarted
	case initialPoint
	case longPress
	case longPressed
	case downStroke
}

class CustomGestureRecognizer : UIGestureRecognizer {
	var strokePhase : SymbolPhase = .notStarted
	var initialTouchPoint : CGPoint = CGPoint.zero
	var initialTouchPointForCalc : CGPoint = CGPoint.zero
	var trackedTouch : UITouch? = nil
	var howManyHPrev = 0
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesBegan(touches, with: event)
		if touches.count != 1 {
			self.state = .failed
		}
		if self.trackedTouch == nil {
			self.trackedTouch = touches.first
			self.strokePhase = .initialPoint
			self.initialTouchPoint = (self.trackedTouch?.location(in: self.view))!
			self.state = .changed
		} else {
			for touch in touches {
				if touch != self.trackedTouch {
					self.ignore(touch, for: event)
				}
			}
		}
		
		var timer = Timer()
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(changeStrokePhase), userInfo: nil, repeats: false)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesMoved(touches, with: event)
		let newTouch = touches.first

		guard newTouch == self.trackedTouch else {
			self.state = .failed
			return
		}

		let newPoint = (newTouch?.location(in: self.view))!
		
		if(self.strokePhase == .initialPoint) {
			if(newPoint.y > (initialTouchPoint.y + 0.5) || newPoint.y < (initialTouchPoint.y - 0.5)) {
				self.state = .failed
			}
		}
		
		if(self.strokePhase == .longPress) {
			if (newPoint.y < (initialTouchPoint.y + 0.5) && newPoint.y > (initialTouchPoint.y - 0.5)) {
				print("Changing to .longPress")
				self.strokePhase = .longPressed
			} else {
				self.state = .failed
			}
		} else if(self.strokePhase == .longPressed || self.strokePhase == .downStroke) {
			self.strokePhase = .downStroke
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesEnded(touches, with: event)
		let newTouch = touches.first
		
		guard newTouch == self.trackedTouch else {
			self.state = .failed
			return
		}
		
		// If the stroke was down up and the final point is
		// below the initial point, the gesture succeeds.
		if self.state == .changed &&
			self.strokePhase == .downStroke {
			self.state = .recognized
			print("Success")
		} else {
			self.state = .failed
		}
	}
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesCancelled(touches, with: event)
		self.state = .cancelled
		reset()
	}
	override func reset() {
		super.reset()
		self.initialTouchPoint = CGPoint.zero
		self.strokePhase = .notStarted
		self.trackedTouch = nil
	}
	
	@objc func changeStrokePhase() {
		self.strokePhase = .longPress
	}
}
