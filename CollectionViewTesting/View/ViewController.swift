//
//  ViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/9/21.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseDatabase
import FirebaseCore

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource
{
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var stackViewHorizontalCenterConstraint: UIView!
	@IBOutlet weak var bannerView: GADBannerView!
	
	var ref: DatabaseReference!
	
    var selectedDate = Date()
	var userSelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		ref = Database.database().reference()
		
		ref.child("users").child("aoeu").observeSingleEvent(of: .value, with: {
			(snapshot) in
			let value = snapshot.value as? NSDictionary
			let username = value?["username"] as? String ?? " "
			print(username)
		}) { (error) in
			print(error.localizedDescription)
		}
		
		bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
		//bannerView.adUnitID = "ca-app-pub-6071058575504654/8848691990"
		bannerView.rootViewController = self
		bannerView.load(GADRequest())
		
		bannerView.delegate = self
        
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
	
	//BackSegue after creating a new event
	@IBAction func BackSegue(unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
	}
	
	//CollectionView functions:
		//Infinite scrolling enabler for month Calendar
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
		
		//Setting up how each cell in the month Calendar will look
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
		
		//The number of sections in the month collectionView calendar
		func numberOfSections(in collectionView: UICollectionView) -> Int {
			return 1
		}
		
		//The number of items in each section is determined by the lengthe of nums[] which keeps track of the content that will be added to the collectionView
		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return num.count
		}
		
		//Updating userSelectedDate after a new cell is selected by the user
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
		
		//Makes sure that only cells containing numbers can be selected by the user. Sets the default background view for selected cells. Sets each cells label to the elements within nums[] which keeps track of the content that will be added to the collectionView.
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
	
	//TableView functions
		//Determines the number of rows in each section of the tableView which is determined by the function eventsForDate which returns all the events that are associated with any givin date.
		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return eventsForDate(parDate: userSelectedDate).count
		}
		
		//Sets each row in the tableView after each reload of data.
		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cellOne = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableViewCell
			
			cellOne.EventLabel.text = eventsForDate(parDate: userSelectedDate)[indexPath.item].name
			//print("reloaded")
			
			let temp = DateFormatter()
			temp.timeStyle = .short
			temp.dateStyle = .none
			
			cellOne.TimeLabel.text = temp.string(from: eventList[indexPath.item].date)
			
			return cellOne
		}
}

extension ViewController: GADBannerViewDelegate {
	
	/*func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		print("recieved ad")
	}
	private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequest) {
		print(error)
	}*/
}
