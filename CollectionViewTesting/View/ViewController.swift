//
//  ViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/9/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{

	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet var stackViewHorizontalCenterConstraint: UIView!
	
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setCellViews()
        
        //fillTitlesF(month: "Jan")
        fillMonth()
    }
    
    //Setting stackViewConstraints
//	func setStackView()
//	{
//		stackViewHorizontalCenterConstraint.constraintsAffectingLayout(for: NSLayoutConstraint)
//	}
    
    
    //Functions to create the calendar and scroll to other months
    
	func fillMonth()
	{
		num.removeAll()
		
		let daysInMonth = numDaysInMonth(date: selectedDate)
		let firstDayMonth = firstDayOfMonth(date: selectedDate)
		let startingSpaces = weekDay(date: firstDayMonth)
		
		
		
		num.append("SU")
		num.append("MO")
		num.append("TU")
		num.append("WE")
		num.append("TH")
		num.append("FR")
		num.append("SA")
		
		var count: Int = 1
		
		while (count < 42)
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
		
		monthLabel.text = monthString(date: selectedDate)
		yearLabel.text = yearString(date: selectedDate)
		collectionView.reloadData()
		
		//print(daysInMonth)
		//print(firstDayMonth)
		//print(startingSpaces)
		//        print(selectedDate)
		//        print(num)
		print("done with fillMonth")
	}
    
    func fillNextMonth()
    {
        selectedDate = minusMonth(date: selectedDate)
        fillMonth()
    }
    
    func fillPreviousMonth()
    {
        selectedDate = plusmonth(date: selectedDate)
        fillMonth()
    }
    
    
	@IBAction func swipeRightCollectionView(_ sender: UISwipeGestureRecognizer) {
		selectedDate = minusMonth(date: selectedDate)
		fillMonth()
		print("Swiped")
	}
	@IBAction func swipeLeftCollectionView(_ sender: UISwipeGestureRecognizer) {
		selectedDate = plusmonth(date: selectedDate)
		fillMonth()
		print("Swiped")
	}
	
    
    //Setting up the Collection view
    
	func setCellViews() {
		let width = (collectionView.frame.size.width)/7
		let height = (collectionView.frame.size.height)/7
		
		print("Height = ")
		print(height)
		
		let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		flowLayout.itemSize = CGSize(width: width, height: height)
		
		collectionView.layer.cornerRadius = 5
	}
//    func setCellViews() {
//        let width = (collectionView.frame.size.width)/9
//        let height = (collectionView.frame.size.height - 2)/5
//
//        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        flowLayout.itemSize = CGSize(width: width, height: height)
//
//        collectionView.layer.cornerRadius = 5
//    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return num.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		cellOne.label.text = num[indexPath.item]
		
		return cellOne
    }

}

