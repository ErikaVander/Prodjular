//
//  CollectionViewCellForEventDuration.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/1/24.
//

import UIKit

class CollectionViewCellForEventDuration: UICollectionViewCell {

	@IBOutlet weak var dayOfTheWeekCollectionView: UICollectionView!
	@IBOutlet weak var viewForAccurateCalc: UIView!
	@IBOutlet weak var eventDurationTableView: UITableView!
	
	let hourSegmentLineTrailingConstraint = 0
	let hourSegmentSegmentorDistribution = 46
	let hourLabelTrailingConstraint = 15
	let eventDurationTableViewCellHeight = 45
	
	var classIndex = 0
	
	
	
	var customGesture : CustomGestureRecognizer!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		print("awakeFromNib")
		
		eventDurationTableView.register(UINib(nibName: "EventDurationTableViewCell", bundle: nil), forCellReuseIdentifier: "eventDurationTableViewCell")
		
		dayOfTheWeekCollectionView.register(UINib(nibName: "weekNumberForEventDuration", bundle: nil), forCellWithReuseIdentifier: "weekNumberForEventDuration")
		
		eventDurationTableView.dataSource = self
		eventDurationTableView.delegate = self
		
		dayOfTheWeekCollectionView.delegate = self
		dayOfTheWeekCollectionView.dataSource = self
		
		eventDurationTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .middle, animated: false)
		eventDurationTableView.scrollToRow(at: IndexPath(item: 2, section: 0), at: .middle, animated: false)
		eventDurationTableView.scrollToRow(at: IndexPath(item: 1, section: 0), at: .middle, animated: false)
		
		//giving value to customGesture after intialization at the tap of file
		//Calling method handleTap after tap is recognized
		customGesture = CustomGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		customGesture.delegate = self
		
		//Adding GestureRecognizer to table view after setting customGesture.delegate = self
		eventDurationTableView.addGestureRecognizer(customGesture)
		eventDurationTableView.setZoomScale(2, animated: true)
		
		fillWeek(parDate: selectedDate)
	}
	
	//The method called when customGestureRecognizer enters .possible or .began (don't know which)
	@objc func handleTap(_ sender: CustomGestureRecognizer) {
		//Width correction only needs to be 1.0 because you handle all other lineSegmentSegmentor widths with the line
		//let howMany = locationOfTouchX - locationOfTouchX.truncatingRemainer(dividingBy: viewForAccurateCalc.frame.width/6)
		//This is because viewForAccurateCalc.frame.width/6 takes into account all the rest of the lineSegmentSegmentor widths.
		let widthCorrection : CGFloat = 1.0
		
		if sender.state == .changed {
			//If tableView is not bouncing after scrolling out of bounds. This is checked by a method down below
			if (isTableBouncing() == false) {
				//If tableView has been pressed for more than .5 seconds and the finger has not been moved significantly
				//See customGesture file for more info.
				if sender.strokePhase == .longPressed {
					//Since tableView is scrolling at the same time as this customGesture is going, the
					//tableView's scroll must be cancled before procceeding.
					eventDurationTableView.panGestureRecognizer.state = .cancelled
					//Getting an accurate origin for view_2 requires that locationOfTouchX be 28 less than
					//sender.initialTouchPoint.x. This allows for an accurate calculation of howMany.
					let locationOfTouchX = sender.initialTouchPoint.x - 28
					//howMany calculates which weekday the view_2 should be created under. If it should be created
					//under Monday it will be 0.0, if Tuesday than 47 more than 0.0, if Wednsday 47 more than 47 etc...
					//47 is the distance from one hourSegmentSegmentor to another. If -28 is not done above, this value
					//would not be accurate.
					let howManyX = locationOfTouchX - locationOfTouchX.truncatingRemainder(dividingBy: viewForAccurateCalc.frame.width/6)
					
					let locationOfTouchY = sender.initialTouchPoint.y
					let howManyY : CGFloat = locationOfTouchY - locationOfTouchY.truncatingRemainder(dividingBy: eventDurationTableView.rowHeight)
					let yCorrection = 0.5
					
					//Make the phone vibrate
					UINotificationFeedbackGenerator().notificationOccurred(.warning)
					
					//Create view_2 which is the square that represents an event's time and day. the numer 28 is the
					//distance from the origin.x of the table view to the origin.x of the viewForAccurateCalc. The
					//Width is equal to 46 (the distance from .trailing of one hourSegmentSegmentor to .leading of another)
					//minus the width of an hourSegmentSegmentor*2.
					let view_2 = UIView(frame: CGRect(x: 28 + howManyX + widthCorrection, y: howManyY + yCorrection, width: 46.0 - (widthCorrection * 2), height: (CGFloat(eventDurationTableViewCellHeight)/4.0) - 1))
					
					view_2.backgroundColor = .lightGray
					view_2.layer.cornerRadius = 5
					//AddingView_2 to tableView
					sender.view?.addSubview(view_2)
				}
				//If the user has pressed and held for more than 0.5 seconds, they can start adjusting the height of view_2.
				if sender.strokePhase == .downStroke {
					let locationOfTouchX = sender.initialTouchPoint.x - 28
					let howManyX = locationOfTouchX - locationOfTouchX.truncatingRemainder(dividingBy: viewForAccurateCalc.frame.width/6)
					var howManyH : Int = Int((((sender.trackedTouch?.location(in: sender.view).y)! - sender.initialTouchPoint.y)/(CGFloat(eventDurationTableViewCellHeight) / 4.0)))
					
					let locationOfTouchY = sender.initialTouchPoint.y
					let howManyY : CGFloat = locationOfTouchY - locationOfTouchY.truncatingRemainder(dividingBy: CGFloat(eventDurationTableViewCellHeight) / 4.0)
					let yCorrection = 0.5//(1 + (Int(locationOfTouchY) / tableViewCellHeight))
					print(eventDurationTableView.rowHeight)
					print(eventDurationTableViewCellHeight)
					print(eventDurationTableViewCellHeight*24)
					
					if howManyH <= 0 {
						howManyH = 1
					}
					if howManyH > 0 {
						if (howManyH != sender.howManyHPrev) {
							sender.howManyHPrev = howManyH
							UINotificationFeedbackGenerator().notificationOccurred(.success)
						}
					}
					
					sender.view?.subviews.last!.frame = CGRect(x: 28 + howManyX + widthCorrection, y: howManyY + CGFloat(yCorrection), width: 46 - (widthCorrection * 2), height: ((CGFloat(eventDurationTableViewCellHeight)/4.0) * CGFloat(howManyH))-1)
				}
			}
		}
	}
	
}

extension CollectionViewCellForEventDuration: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellOne = tableView.dequeueReusableCell(withIdentifier: "eventDurationTableViewCell", for: indexPath) as! EventDurationTableViewCell
		
		if indexPath.item < 12 {
			cellOne.eventDurationHourLabel.text = String(indexPath.item + 1)
		} else {
			cellOne.eventDurationHourLabel.text = String(indexPath.item - 11)
		}
		cellOne.eventDurationHourLabel.font = cellOne.eventDurationHourLabel.font?.withSize(12)
		
		return cellOne
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 24
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(eventDurationTableViewCellHeight)
	}
	
	func isTableBouncing() -> Bool {
		let topInsetForBouncing = eventDurationTableView.safeAreaInsets.top != 0.0 ? -eventDurationTableView.safeAreaInsets.top : 0.0
		let isBouncingTop: Bool = eventDurationTableView.contentOffset.y < topInsetForBouncing - eventDurationTableView.contentInset.top
		let bottomInsetForBouncing = eventDurationTableView.safeAreaInsets.bottom
		let threshold: CGFloat
		if eventDurationTableView.contentSize.height > eventDurationTableView.frame.size.height {
			threshold = (eventDurationTableView.contentSize.height - eventDurationTableView.frame.size.height + eventDurationTableView.contentInset.bottom + bottomInsetForBouncing)
		} else {
			threshold = topInsetForBouncing
		}
		let isBouncingBottom: Bool = eventDurationTableView.contentOffset.y > threshold
		
		if isBouncingTop == true || isBouncingBottom == true {
			return true
		}
		return false
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollPosition = eventDurationTableView.contentOffset
//		if(scrollPosition.y.truncatingRemainder(dividingBy: eventDurationTableView.frame.height+1) != 0) {
//			eventDurationTableView.scrollToNearestSelectedRow(at: .top, animated: true)
//		}
		print(scrollPosition.y)
	}
	
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		
	}
	
}

extension CollectionViewCellForEventDuration : UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

extension CollectionViewCellForEventDuration : UICollectionViewDelegate {
	
}

extension CollectionViewCellForEventDuration : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 7
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "weekNumberForEventDuration", for: indexPath) as! weekNumberForEventDuration
		
		if(classIndex == 1) {
			cellOne.label.text = numWeek[indexPath.item + 7]
		} else if (classIndex == 0) {
			cellOne.label.text = numWeek[indexPath.item]
		} else {
			cellOne.label.text = numWeek[indexPath.item + 14]
		}
		
		return cellOne
		
	}
	
	
}

extension CollectionViewCellForEventDuration : UICollectionViewDelegateFlowLayout {
	///setting the width and height of the EventDurationCollectionView
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		//let widthValue = collectionView.frame.width/7
		
		//print("WidthValue = ", widthValue)
		
		return CGSize(width: 46.8, height: dayOfTheWeekCollectionView.frame.height)
	}
}
