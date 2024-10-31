//
//  ViewController.swift
//  TestingDragAndDrop
//
//  Created by Vanderhoff on 3/9/22.
//

import UIKit

class EventDurationViewController: UIViewController {
	
	
	@IBOutlet weak var EventDurationTableViewContainerCollectionView: UICollectionView!
	
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var mondayLabel: UILabel!
	@IBOutlet weak var tuesdayLabel: UILabel!
	@IBOutlet weak var wednesdayLabel: UILabel!
	@IBOutlet weak var thursdayLabel: UILabel!
	@IBOutlet weak var fridayLabel: UILabel!
	@IBOutlet weak var saturdayLabel: UILabel!
	@IBOutlet weak var sundayLabel: UILabel!
	
	public var positionOfCellOneScroll = CGPoint(x: 0.0, y: 0.0)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		EventDurationTableViewContainerCollectionView.register(UINib(nibName: "CollectionViewCellForEventDuration", bundle: nil), forCellWithReuseIdentifier: "cellForEventDuration")
		
		EventDurationTableViewContainerCollectionView.delegate = self
		EventDurationTableViewContainerCollectionView.dataSource = self
		
		fillWeek(parDate: selectedDate)
		
		//Change month string to match current viewed month
		monthLabel.text = monthString(date: firstDayOfWeek(date: selectedDate))
		//If the month changes in the middle of the week, add the other month to the string also
		if(monthString(date: firstDayOfWeek(date: selectedDate)) != monthString(date: lastDayOfWeek(date: selectedDate))) {
			monthLabel.text = monthLabel.text! + " - " +  monthString(date: lastDayOfWeek(date: selectedDate))
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
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
	}
	
	///Logic for allowing infinite scrolling.
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		//This variable makes it so that infinite scroll actually works. It keeps track of which cell is actually touching the midpoint in EventDurationTableViewContainerCollectionView
//		let midIndexPath = EventDurationTableViewContainerCollectionView.indexPathForItem(at: CGPoint(x: midX, y: midY))
		let midIndexPath2 = EventDurationTableViewContainerCollectionView.indexPathsForVisibleItems

		let midIndexPath = midIndexPath2.last
		//If the index that is at the end of the array midIndexPath2 is [0, 2], then it will scroll to the right, otherwise it will scroll to the left.
		if(midIndexPath == IndexPath.init(item: 2, section: 0)) {
			//plus a week on selected date
			selectedDate = plusWeek(date: selectedDate)
			fillWeek(parDate: selectedDate)
			reloadData()
			//Change month string to match current viewed month
			monthLabel.text = monthString(date: firstDayOfWeek(date: selectedDate))
			//If the month changes in the middle of the week, add the other month to the string also
			if(monthString(date: firstDayOfWeek(date: selectedDate)) != monthString(date: lastDayOfWeek(date: selectedDate))) {
				monthLabel.text = monthLabel.text! + " - " +  monthString(date: lastDayOfWeek(date: selectedDate))
			}
			scroll()
		} else if (midIndexPath == IndexPath.init(item: 0, section: 0)) {
			//minus a week on selected date
			selectedDate = minusWeek(date: selectedDate)
			fillWeek(parDate: selectedDate)
			reloadData()
			//Change month string to match current viewed month
			monthLabel.text = monthString(date: firstDayOfWeek(date: selectedDate))
			//If the month changes in the middle of the week, add the other month to the string also
			if(monthString(date: firstDayOfWeek(date: selectedDate)) != monthString(date: lastDayOfWeek(date: selectedDate))) {
				monthLabel.text = monthLabel.text! + " - " +  monthString(date: lastDayOfWeek(date: selectedDate))
			}
			scroll()
		}
	}
	
	///This function will make the scroll position in the vertical direction the same for all table views within the collection view.
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		(cell as! CollectionViewCellForEventDuration).eventDurationTableView.contentOffset.y = -5
		(cell as! CollectionViewCellForEventDuration).eventDurationTableView.contentOffset.y = scrollPosition.y
		//print((cell as! CollectionViewCellForEventDuration).eventDurationTableView.contentOffset.y)
	}
	
	///Reloading data of EventDurationTableViewContainerCollectionView after scrolling.
	func reloadData() {
		EventDurationTableViewContainerCollectionView.reloadData()
	}
}

//MARK: - EventDurationViewControllerDataSource
extension EventDurationViewController : UICollectionViewDataSource {
	///Setting how many cells are in each section of the EventDurationCollectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}
	
	///Creating the cells of the EventDurationCollectionView using the reusable cell defined in CollectionViewCellForEventDuration. Also reloading data after scrolling.
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cellForEventDuration", for: indexPath) as! CollectionViewCellForEventDuration
		
		cellOne.classIndex = indexPath.item
		//Reload the dayOfTheWeekCollectionView, after putting updated dates in numWeek array, after scrolling. This allows infinite scroll to work
		cellOne.dayOfTheWeekCollectionView.reloadData()
		
		//allow the user to scroll.
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
//	@IBAction func back(_ sender: Any) {
//		self.dismiss(animated: true, completion: nil)
//	}
}
