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
		
        setCellViews()
		
        fillMonth()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
		//print("ViewWillAppear")
	}
	
	@IBAction func BackSegue(unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
	}

	//Functions to create the calendar and scroll to other months
    
	func fillMonth()
	{
		num.removeAll()
		var x: Int = 0
		var startDate = minusMonth(date: selectedDate)
		while x < 3 {
			print("x in loop: \(x)")
			let daysInMonth = numDaysInMonth(date: startDate)
			let firstDayMonth = firstDayOfMonth(date: startDate)
			let startingSpaces = weekDay(date: firstDayMonth)
			
			num.append("SU")
			num.append("MO")
			num.append("TU")
			num.append("WE")
			num.append("TH")
			num.append("FR")
			num.append("SA")
			
			var count: Int = 1
			
			while (count < 43)
			{
				if (count <= startingSpaces || count - startingSpaces > daysInMonth)
				{
					num.append("")
				}
				else
				{
					num.append(String(count - startingSpaces))
				}
				count += 1
			}
			x  += 1
			startDate = plusmonth(date: startDate)
		}
		
		monthLabel.text = monthString(date: selectedDate)
		yearLabel.text = yearString(date: selectedDate)
		
		collectionView.isPagingEnabled = false
		collectionView.scrollToItem(at: IndexPath.init(item: 50, section: 0), at: .top, animated: false)
		collectionView.isPagingEnabled = true
		
		collectionView.reloadData()
		
		print("done with fillMonth")
		setCellViews()
	}

	
//    func fillNextMonth()
//    {
//        selectedDate = minusMonth(date: selectedDate)
//        fillMonth()
//    }
//
//    func fillPreviousMonth()
//    {
//        selectedDate = plusmonth(date: selectedDate)
//        fillMonth()
//    }
    
    
	@IBAction func swipeRightCollectionView(_ sender: UISwipeGestureRecognizer) {
		//selectedDate = minusMonth(date: selectedDate)
		//fillMonth()
		//print("Swiped")
	}
	@IBAction func swipeLeftCollectionView(_ sender: UISwipeGestureRecognizer) {
		//selectedDate = plusmonth(date: selectedDate)
		//fillMonth()
		//print("Swiped")
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
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if(indexPath.item == 146) {
			selectedDate = plusmonth(date: selectedDate)
			fillMonth()
		}
		if(indexPath.item == 1) {
			selectedDate = minusMonth(date: selectedDate)
			fillMonth()
		}
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
		print(indexPath.item)
		if Int(num[indexPath.item]) != nil
		{
			cellOne.automaticallyUpdatesBackgroundConfiguration = true
			
			let _: () = cellOne.selectedBackgroundView = {
				let view = UIView()
				view.layer.cornerRadius = 15
				view.backgroundColor = UIColor.darkGray
	
				return view
			}()
			
			cellOne.selectedBackgroundView!.frame = CGRect(x: (cellOne.frame.width-cellOne.frame.height)/2, y: 0, width: cellOne.frame.height, height: cellOne.frame.height)
		}
		cellOne.label.text = num[indexPath.item]
		
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

