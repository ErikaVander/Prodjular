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

var isLoggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
var selectedDate = currentDateAndTime()
let dateFormatter = DateFormatter()
var eventsForTableViewCell = [ProjdularEvent]()
var initialLoadingOfData = true

class CalendarViewController: UIViewController {
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var stackViewHorizontalCenterConstraint: UIView!
	@IBOutlet weak var bannerView: GADBannerView!
	@IBOutlet weak var noEventsScheduledLabel: UILabel!
	
	var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
		
		print("--currentDate = \(currentDateAndTime())")
		Database.database().isPersistenceEnabled = true
		print("--observing events from viewDidLoad")
		observeEvents()
		
		///Checking to see if a user is signed in. If not, shows the sign-in screen
		FirebaseAuth.Auth.auth().addStateDidChangeListener{ auth, user in
			if user != nil && user?.isEmailVerified == true {
				print("-- User: \(Auth.auth().currentUser?.email ?? "Was a nil value") --")
				isLoggedIn = true
				
			} else {
				self.showLogIn()
				print("-- No user is signed in. --")
			}
		}
		
		///bannerAd view setup
		bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
		//bannerView.adUnitID = "ca-app-pub-6071058575504654/8848691990"
		bannerView.rootViewController = self
		bannerView.load(GADRequest())
		bannerView.delegate = self
        
		///Setting up the collectionView delegate and datasource
        collectionView.delegate = self
        collectionView.dataSource = self
		
		///Setting up the tableView delegate and datasource
		tableView.delegate = self
		tableView.dataSource = self
		
		///Setting the month and year label
		monthLabel.text = monthString(date: selectedDate)
		yearLabel.text = yearString(date: selectedDate)
        setCollectionViewLayout()
		
		DatabaseManager.shared.delegate = self
		
		fillMonth(parDate: selectedDate)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
}

//MARK: FirebaseRealtimeDatabase
extension CalendarViewController {
	///Getting all the events created by the user and storing them in eventList so that the table view can display them.
	func observeEvents() {
		let eventRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("events")
		
		eventRef.observe(.value, with: { snapshot in
			
			var tempEvents = [ProjdularEvent]()
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let date = dict["date"] as? String,
				   let nameOfEvent = dict["name"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let tagColor = dict["tagColor"] as? String
				{
					//let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
					
					let event = ProjdularEvent(id: id, nameOfEvent: nameOfEvent, date: dateFormatter.date(from: date), tagName: tagName, tagColor: tagColor)
					
					tempEvents.append(event)
				}
			}
			eventList = tempEvents
			//print("--eventsForDate: \(eventsForDate(parDate: selectedDate)) selectedDate: \(selectedDate))")
			if(initialLoadingOfData == true) {
				self.tableView.reloadData()
				initialLoadingOfData = false
			}
			self.collectionView.reloadData()
			///Selecting the current date
			//let date = selectedDate
			
			//print("--Date() = \(Date())")
			//print("--date = \(date)")
			//let date = dateFromNumbers(date: "9 16, 2021")
			
			//self.selectDayOfMonth(theDateHorizontal: weekDay(date: date), theDateVertical: ((calendar.component(.day, from: date) + (weekDay(date: firstDayOfMonth(date: date)) + 1)) / 7))
			//self.selectDayOfMonth(at: 7 + weekDay(date: firstDayOfMonth(date: date))+dayOfMonth(date: date))
		})
		
	}
	
	func observeColors() {
		let eventRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("colors")
		
		eventRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let dict = childSnapshot.value as? [String: Any],
				   let name = dict["name"] as? String,
				   let redValue = dict["redValue"] as? Float,
				   let blueValue = dict["blueValue"] as? Float,
				   let greenValue = dict["greenValue"] as? Float
				{
					ColorsArray.append(Colors(name: name, redValue: redValue, blueValue: blueValue, greenValue: greenValue))
				}
			}
		})
	}
}

//MARK: Navigation
extension CalendarViewController {
	///Logic to show the login page.
	func showLogIn() {
		let vc = storyboard?.instantiateViewController(identifier: "LogInViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
	
	///BackSegue after creating a new event
	@IBAction func BackSegue(unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
	}
}

extension CalendarViewController: GADBannerViewDelegate {
	
	/*func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		print("recieved ad")
	}
	private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequest) {
		print(error)
	}*/
}


//MARK: CollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
	
	///The number of sections in the month collectionView calendar
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	///The number of items in each section is determined by the lengthe of nums[] which keeps track of the content that will be added to the collectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return num.count
	}

	///Makes sure that only cells containing numbers can be selected by the user. Sets the default background view for selected cells. Sets each cells label to the elements within nums[] which keeps track of the content that will be added to the collectionView. Creates dotViews for cells that have events.
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		cellOne.isUserInteractionEnabled = false
		//cellOne.dotView.isHidden = true
		cellOne.currentDateIndicatorView.isHidden = true
		for theView in cellOne.StackViewForDotViews.subviews {
			theView.removeFromSuperview()
			cellOne.StackViewForDotViews.removeArrangedSubview(theView)
		}
		
		if Int(num[indexPath.item]) != nil {
			cellOne.label.textColor = .white
			cellOne.automaticallyUpdatesBackgroundConfiguration = true
			cellOne.isUserInteractionEnabled = true
			
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MMM"
			
			let formatterTwo = DateFormatter()
			formatterTwo.dateFormat = "yyyy-MMM-dd"
			
			let firstPartOfDate = "\(String(describing: yearLabel.text!))-\(String(describing: monthLabel.text!))"
			let dateString = "\(firstPartOfDate)-\(num[indexPath.item])"
			
			let theDate = formatterTwo.date(from: dateString) ?? formatterTwo.date(from: "2020-August-21")!
			
			if indexPath.item <= 49 {
				cellOne.cellDate = minusMonth(date: theDate)
			} else if indexPath.item <= 98 {
				cellOne.cellDate = theDate
				
				if(formatterTwo.string(from: theDate) == formatterTwo.string(from: currentDateAndTime())){
					print("--\(formatterTwo.string(from: theDate))  \(formatterTwo.string(from: currentDateAndTime()))")
					print("--indexPath: \(indexPath.item)")
					cellOne.label.textColor = UIColor(named: "MyRed")
					
					cellOne.currentDateIndicatorView.layer.borderColor = UIColor.white.cgColor
					cellOne.currentDateIndicatorView.layer.borderWidth = 2
					cellOne.currentDateIndicatorView.layer.cornerRadius = 5
					cellOne.currentDateIndicatorView.isHidden = false
				}
			} else {
				cellOne.cellDate = plusmonth(date: theDate)
			}
			
			let _: () = cellOne.selectedBackgroundView = {
				let view = UIView()
				view.layer.cornerRadius = 5
				view.backgroundColor = UIColor.darkGray
				
				return view
			}()
			
			if(eventsForDate(parDate: theDate).count != 0 && cellOne.cellDate == theDate) {
				
				for events in eventsForDate(parDate: theDate) {
					let theDotViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: Int(cellOne.StackViewForDotViews.frame.width)/eventsForDate(parDate: theDate).count, height: 4))
					let dotView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
					
					dotView.layer.borderWidth = 2
					dotView.layer.borderColor = UIColor.black.cgColor
					dotView.backgroundColor = UIColor(named: "\(events.tagColor!)")
					dotView.layer.cornerRadius = 3.5

					cellOne.StackViewForDotViews.addArrangedSubview(theDotViewContainer)
					cellOne.StackViewForDotViews.alignment = .fill
					cellOne.StackViewForDotViews.distribution = .fillEqually
					cellOne.StackViewForDotViews.spacing = 0
					
					theDotViewContainer.addSubview(dotView)
					dotView.center = theDotViewContainer.center
					
					if eventsForDate(parDate: theDate).count == 2 {
						if(eventsForDate(parDate: theDate)[0] == events)
						{
							dotView.center.x = theDotViewContainer.center.x+2.5
						} else {
							dotView.center.x = theDotViewContainer.center.x-2.5
						}
					}
				}
			}
			cellOne.selectedBackgroundView!.frame = CGRect(x: (cellOne.frame.width-cellOne.frame.height)/2, y: 0, width: cellOne.frame.height, height: cellOne.frame.height)
		}
		
		cellOne.label.text = num[indexPath.item]
		
		return cellOne
	}
}

//MARK: ColectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate {
	func scroll() {
		collectionView.scrollToItem(at: IndexPath(item: 50, section: 0), at: .top, animated: false)
		collectionView.reloadData()
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		print("--indexPathForVisibleItems: \(collectionView.indexPathsForVisibleItems[0].item)")
		if(collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 0, section: 0)) {
			print("up")
			selectedDate = minusMonth(date: selectedDate)
			fillMonth(parDate: selectedDate)
			scroll()
			yearLabel.text = yearString(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			
		} else if collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 105, section: 0){
			print("down")
			selectedDate = plusmonth(date: selectedDate)
			fillMonth(parDate: selectedDate)
			scroll()
			yearLabel.text = yearString(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
		}
	}
	
	///Infinite scrolling enabler for month Calendar
	/*func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentOffset: CGPoint = collectionView.contentOffset
		let contentHeight: CGFloat = collectionView.contentSize.height
		let centerOffsetY: CGFloat = (contentHeight - collectionView.bounds.size.height)/2.0
		let distanceFromCenter: CGFloat = currentOffset.y - centerOffsetY
		
		if (abs(distanceFromCenter) == collectionView.frame.size.height && abs(distanceFromCenter) == distanceFromCenter) {
			
			if calendar.component(.month, from: plusmonth(date: selectedDate)) == calendar.component(.month, from: Date()) {
				
				selectDayOfMonth(theDateHorizontal: weekDay(date: Date()), theDateVertical: (calendar.component(.day, from: Date()) + (weekDay(date: firstDayOfMonth(date: Date())) + 1)) / 7)
				
			} else {
				
				selectDayOfMonth(theDateHorizontal: (weekDay(date: plusmonth(date: firstDayOfMonth(date: selectedDate)))), theDateVertical: 0)
				
			}
			
			selectedDate = plusmonth(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			yearLabel.text = yearString(date: selectedDate)
			fillMonth(parDate: selectedDate)
			selectCell(indexPath: (collectionView.indexPathsForSelectedItems?.first)!)
			collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.frame.size.height)
			
			print("                       --Swiped down--")
		}
		
		if (abs(distanceFromCenter) == collectionView.frame.size.height && abs(distanceFromCenter) != distanceFromCenter) {
			
			if calendar.component(.month, from: minusMonth(date: selectedDate)) == calendar.component(.month, from: Date()) {
				
				selectDayOfMonth(theDateHorizontal: weekDay(date: Date()), theDateVertical: (calendar.component(.day, from: Date()) + (weekDay(date: firstDayOfMonth(date: Date())) + 1)) / 7)
				
			} else {
				
				selectDayOfMonth(theDateHorizontal: (weekDay(date: minusMonth(date: firstDayOfMonth(date: selectedDate)))), theDateVertical: 0)
				
			}
			
			selectedDate = minusMonth(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			yearLabel.text = yearString(date: selectedDate)
			fillMonth(parDate: selectedDate)
			selectCell(indexPath: (collectionView.indexPathsForSelectedItems?.first)!)
			collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.frame.size.height)
			
			print("                       --Swiped up--")
		}
	}
	
	///Get the indexPath for a certain location in the collectionView. Virtical direction 0 = first virtical row that has numbers stored. Horizontal direction 0 = Sunday. Swipe Up minusMonth, Swipe Down plusMonth.
	func getIndexPathOfCollectionViewCGPoint(theDateHorizontal: Int, theDateVertical: Int) -> IndexPath {
		
		let relativeWidth: CGFloat = 5
		let cellWidth = ((collectionView.frame.size.width-(relativeWidth*2))/7)
		let cellHeight = (collectionView.frame.size.height)/7
		
		//print("--cell Width: \(cellWidth)")
		
		let point = CGPoint(x: cellWidth*CGFloat(theDateHorizontal) + (cellWidth/2), y: (cellHeight * 8) + (cellHeight/2) + (cellHeight * CGFloat(theDateVertical)))
		
		let indexPath = collectionView.indexPathForItem(at: point)!
		
		return indexPath
	}
	
	func getIndexPathsForVisibleItems(at: Int) -> IndexPath {
		return collectionView.indexPathsForVisibleItems[at]
	}*/
	
	///Setting up how each cell in the month Calendar will look
	func setCollectionViewLayout() {
		let relativeWidth: CGFloat = 5
		let cellWidth = ((collectionView.frame.size.width-(relativeWidth*2))/7)
		let cellHeight = (collectionView.frame.size.height)/7
		
		let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		flowLayout.sectionInsetReference = .fromSafeArea
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: relativeWidth, bottom: 0, right: relativeWidth)
		flowLayout.minimumLineSpacing = 0
		flowLayout.minimumInteritemSpacing = 0
		
		collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.frame.size.height)
		collectionView.layer.cornerRadius = 5
		collectionView.isPagingEnabled = true

	}
	
	///Selecting a specific day of the month using CGPoint. CGPoint is calculated using the collectionViewCell's width and height to determine the indexPath.
	/*func selectDayOfMonth(theDateHorizontal: Int, theDateVertical: Int /*at: Int*/) {
		
		let indexPath = getIndexPathOfCollectionViewCGPoint(theDateHorizontal: theDateHorizontal, theDateVertical: theDateVertical)
		/*print("--indexPathsForVisibleItems.count: \(collectionView.indexPathsForVisibleItems.count)")
		let indexPath = getIndexPathsForVisibleItems(at: at)*/
		
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		cellOne.currentDateIndicatorView.layer.borderWidth = 3
		cellOne.currentDateIndicatorView.layer.borderColor = UIColor.white.cgColor
		
		cellOne.isSelected = true
		
		collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.init(rawValue: UInt((7 + weekDay(date: firstDayOfMonth(date: selectedDate))))))
		
		//print("--selectFirstDayOfMonth: \(selectedDate)--")
	}*/

	
	///Updating userSelectedDate after a new cell is selected by the user
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("--indexPathsForVisibleItems.count: \(collectionView.indexPathsForVisibleItems.count)")
		selectCell(indexPath: indexPath)
	}
	
	///Logic for updating userSelectedDate after a new cell is selected by user
	func selectCell(indexPath: IndexPath) {
		if Int(num[indexPath.item]) != nil
		{
			selectedDate = dateFromNumbers(date: "\(monthString(date: selectedDate)) \(num[indexPath.item]), \(yearString(date: selectedDate))")
		}
		tableView.reloadData()
		if(tableView.numberOfRows(inSection: 0) == 0) {
			noEventsScheduledLabel.text = "no events scheduled"
		}
	}
}

//MARK: TableViewDataSource

extension CalendarViewController: UITableViewDataSource {
	///Determines the number of rows in each section of the tableView which is 	determined by the function eventsForDate which returns all the events that are associated with any givin date.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		eventsForTableViewCell = eventsForDate(parDate: selectedDate)
		
		if eventsForDate(parDate: selectedDate).isEmpty == false {
			print("--events for date == false")
			return eventsForTableViewCell.count
		} else {
			return 0
		}
		
	}
	
	///Sets each row in the tableView after each reload of data.
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellOne = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableViewCell
		
		eventsForTableViewCell = eventsForDate(parDate: selectedDate)
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			print("--eventsForTableViewCell.isEmpty = true")
			
			noEventsScheduledLabel.textColor = UIColor.placeholderText
			noEventsScheduledLabel.text = "no events scheduled"
			
			//cellOne.EventLabel.textColor = UIColor.placeholderText
			//cellOne.EventLabel.text = "no events scheduled"
			cellOne.TimeLabel.text = ""
			
		} else {
			print("--eventsForTableViewCell.isEmpty = false")
			
			noEventsScheduledLabel.text = ""
			
			cellOne.EventLabel.textColor = UIColor.label
			cellOne.EventLabel.text = eventsForTableViewCell[indexPath.item].nameOfEvent
			
			let temp = DateFormatter()
			temp.timeStyle = .short
			temp.dateStyle = .none
			
			cellOne.TimeLabel.text = temp.string(from: eventsForTableViewCell[indexPath.item].date)
			
		}
		
		print("HelloThisIsForPersonalAccessTokenStuff")
		return cellOne
	}
}

//MARK: TableViewDelegate

extension CalendarViewController: UITableViewDelegate, DatabaseManagerDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: DatabaseManager, indexPath: IndexPath) {
		DispatchQueue.main.async {
			
			eventsForTableViewCell.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .fade)
			
			if(self.tableView.numberOfRows(inSection: 0) == 0) {
				self.noEventsScheduledLabel.text = "no events scheduled"
			}
		}
		
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if eventsForTableViewCell.isEmpty == true && indexPath.item == 0 {
			return false
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			DatabaseManager.shared.deleteEvent(with: eventsForTableViewCell[indexPath.item], indexPath: indexPath)
		}
	}
}
