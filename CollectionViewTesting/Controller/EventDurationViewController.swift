//
//  ViewController.swift
//  TestingDragAndDrop
//
//  Created by Vanderhoff on 3/9/22.
//

import UIKit

class EventDurationViewController: UIViewController {
	
	
	@IBOutlet weak var EventDurationTableViewContainerCollectionView: UICollectionView!
	
	@IBOutlet weak var dayOfTheWeekCollectionView: UICollectionView!
	
	@IBOutlet weak var mondayLabel: UILabel!
	@IBOutlet weak var tuesdayLabel: UILabel!
	@IBOutlet weak var wednesdayLabel: UILabel!
	@IBOutlet weak var thursdayLabel: UILabel!
	@IBOutlet weak var fridayLabel: UILabel!
	@IBOutlet weak var saturdayLabel: UILabel!
	@IBOutlet weak var sundayLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		EventDurationTableViewContainerCollectionView.register(UINib(nibName: "CollectionViewCellForEventDuration", bundle: nil), forCellWithReuseIdentifier: "cellForEventDuration")
		
		EventDurationTableViewContainerCollectionView.delegate = self
		EventDurationTableViewContainerCollectionView.dataSource = self
	}
}

//MARK: - EventDurationViewController constraints
extension EventDurationViewController {
	func constrainWeekdayLabels() {
		sundayLabel.trailingAnchor.constraint(equalTo: EventDurationTableViewContainerCollectionView.trailingAnchor, constant: 23).isActive = true
	}
}

//MARK: - EventDuariotViewControllerDelegate
extension EventDurationViewController : UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

//MARK: - EventDurationViewControllerDataSource
extension EventDurationViewController : UICollectionViewDataSource {
	///Setting how many cells are in each section of the EventDurationCollectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}
	
	///Creating the cells of the EventDurationCollectionView using the reusable cell defined in CollectionViewCellForEventDuration
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cellForEventDuration", for: indexPath)
		
		cellOne.isUserInteractionEnabled = true
		return cellOne
	}
	
}


extension EventDurationViewController : UICollectionViewDelegateFlowLayout {
	///setting the width and height of the EventDurationCollectionView
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: EventDurationTableViewContainerCollectionView.frame.width, height: EventDurationTableViewContainerCollectionView.frame.height)
	}
}

extension EventDurationViewController : UICollectionViewDelegate {
	
}

//MARK: - Navigation
extension EventDurationViewController {
	///Goes back to the settings page
	@IBAction func back(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}
