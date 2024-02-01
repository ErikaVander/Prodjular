//
//  ViewController.swift
//  TestingDragAndDrop
//
//  Created by Vanderhoff on 3/9/22.
//

import UIKit

class EventDurationViewController: UIViewController {
	
	
	@IBOutlet weak var EventDurationTableViewContainerCollectionView: UICollectionView!
	
	@IBOutlet weak var mondayLabel: UILabel!
	@IBOutlet weak var tuesdayLabel: UILabel!
	@IBOutlet weak var wednesdayLabel: UILabel!
	@IBOutlet weak var thursdayLabel: UILabel!
	@IBOutlet weak var fridayLabel: UILabel!
	@IBOutlet weak var saturdayLabel: UILabel!
	@IBOutlet weak var sundayLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
}

extension EventDurationViewController {
	func constrainWeekdayLabels(utv: UITableView) {
		sundayLabel.trailingAnchor.constraint(equalTo: EventDurationTableViewContainerCollectionView.trailingAnchor, constant: 23).isActive = true
	}
}

extension EventDurationViewController : UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
