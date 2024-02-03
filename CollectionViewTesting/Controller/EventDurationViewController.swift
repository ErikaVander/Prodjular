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
		
		scroll()
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
	
	///This function will scroll to the center cell (cell 1) when called.
	func scroll() {
		EventDurationTableViewContainerCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
		print("Scrolling")
	}
	
	///Logic for allowing infinite scrolling.
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		//Variables that contain the mid x and mid y coordinates of EventDurationTableViewContainerCollectionView
		let midX = EventDurationTableViewContainerCollectionView.frame.midX
		let midY = EventDurationTableViewContainerCollectionView.frame.midY
		
		//This variable makes it so that infinite scroll actually works. It keeps track of which cell is actually touching the midpoint in EventDurationTableViewContainerCollectionView
		let midIndexPath = EventDurationTableViewContainerCollectionView.indexPathForItem(at: CGPoint(x: midX, y: midY))
		
		//If the cell that is touching the midpoint is 0 or 2, call scroll() to change it to 1 allowing for infinite scrolling.
		if(midIndexPath == IndexPath.init(item: 0, section: 0)) {
			//minus a week on selected date
			scroll()
		} else if (midIndexPath == IndexPath.init(item: 2, section: 0)) {
			//plus a week on selected date
			scroll()
		}
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
