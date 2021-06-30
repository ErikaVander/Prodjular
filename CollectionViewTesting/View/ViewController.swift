//
//  ViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/9/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource
{

	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var stackViewHorizontalCenterConstraint: UIView!
	
    var selectedDate = Date()
	var userSelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
		
		monthLabel.text = monthString(date: selectedDate)
		yearLabel.text = yearString(date: selectedDate)
		collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.frame.size.height)
        setCellViews()
		
		fillMonth(parDate: selectedDate)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
		//print("ViewWillAppear")
	}
	
	@IBAction func BackSegue(unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
	}

	//Functions to create the calendar and scroll to other months

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentOffset: CGPoint = collectionView.contentOffset
		let contentHeight: CGFloat = collectionView.contentSize.height
		let centerOffsetY: CGFloat = (contentHeight - collectionView.bounds.size.height)/2.0
		let distanceFromCenter: CGFloat = currentOffset.y - centerOffsetY
		
		if (abs(distanceFromCenter) == collectionView.frame.size.height && abs(distanceFromCenter) == distanceFromCenter) {
			
			selectedDate = plusmonth(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			yearLabel.text = yearString(date: selectedDate)
			fillMonth(parDate: selectedDate)
			collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.frame.size.height)
		}
		
		if (abs(distanceFromCenter) == collectionView.frame.size.height && abs(distanceFromCenter) != distanceFromCenter) {
			
			selectedDate = minusMonth(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			yearLabel.text = yearString(date: selectedDate)
			fillMonth(parDate: selectedDate)
			collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.frame.size.height)
		}
	}
	
    //Setting up the Collection view
    
	func setCellViews() {
		let relativeWidth: CGFloat = 5
		let cellWidth = ((collectionView.frame.size.width-(relativeWidth*2))/7)
		let cellHeight = (collectionView.frame.size.height)/7
		
		//print("Height = ")
		//print(cellHeight)
		
		let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		flowLayout.sectionInsetReference = .fromSafeArea
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: relativeWidth, bottom: 0, right: relativeWidth)
		
		collectionView.layer.cornerRadius = 5
	}
	
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if Int(num[indexPath.item]) != nil
		{
			let temp = DateFormatter()
			temp.dateFormat = "yyyy-MM-d"
			let tempDate: String = "\(yearString(date: selectedDate))-\(monthString(date: selectedDate))-\(num[indexPath.item])"
			
			userSelectedDate = temp.date(from: tempDate)!
		}
		tableView.reloadData()
	}
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return num.count
    }
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		cellOne.isUserInteractionEnabled = false
		
		if Int(num[indexPath.item]) != nil
		{
			cellOne.automaticallyUpdatesBackgroundConfiguration = true
			cellOne.isUserInteractionEnabled = true
			
			let _: () = cellOne.selectedBackgroundView = {
				let view = UIView()
				view.layer.cornerRadius = 15
				view.backgroundColor = UIColor.darkGray
	
				return view
			}()
			
			cellOne.selectedBackgroundView!.frame = CGRect(x: (cellOne.frame.width-cellOne.frame.height)/2, y: 0, width: cellOne.frame.height, height: cellOne.frame.height)
		}
		cellOne.label.text = num[indexPath.item]
		
		setCellViews()
		
		return cellOne
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return eventsForDate(parDate: userSelectedDate).count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellOne = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableViewCell
		
		//cellOne.EventLabel.text = eventList[indexPath.item].name
		cellOne.EventLabel.text = eventsForDate(parDate: userSelectedDate)[indexPath.item].name
		//print("reloaded")
		
		let temp = DateFormatter()
		temp.timeStyle = .short
		temp.dateStyle = .none
		
		cellOne.TimeLabel.text = temp.string(from: eventList[indexPath.item].date)
		
		return cellOne
	}
}

