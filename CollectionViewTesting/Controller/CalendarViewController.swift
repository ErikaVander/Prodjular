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
var previouslySelectedCellIndexPath: IndexPath?

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
		
		DatabaseManager.shared.delegate = self
		
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
			
			let dateToSelectPlusSeven = 7+weekDay(date: firstDayOfMonth(date: selectedDate))+dayOfMonth(date: selectedDate)
			
			self.collectionView.selectItem(at: IndexPath(item: (49+dateToSelectPlusSeven-1), section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.init(rawValue: UInt(dateToSelectPlusSeven)))
			
			previouslySelectedCellIndexPath = self.collectionView.indexPathsForSelectedItems?.first
		})
		
	}
	///Get all colors made by the user and stored on firebase by the current user.
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
	func observeUserSettings() {
		let settingsRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("userSettings")
		
		settingsRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let dict = childSnapshot.value as? [String: Any],
				   let autoBreakLength = dict["autoBreakLength"] as? Float,
				   let autoPrepLength = dict["autoPrepLength"] as? Float,
				   let addNewDirection = dict["addNewDirection"] as? String,
				   let autoWorkDays = dict["autoWorkDays"] as? [String]
				{
					currentUserSettings = SettingsHelper.init(autoBreakLength: autoBreakLength, autoPrepLength: autoPrepLength, addNewDirection: addNewDirection, autoWorkDays: autoWorkDays)
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

///Maybe use this in the future to print out wether or not the bannerView wass successful in recieving ads.
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
		cellOne.currentDateIndicatorView.isHidden = true
		cellOne.label.textColor = .white
		cellOne.theDotViewBackgroundView.isHidden = true
		for subviews in cellOne.theDotViewBackgroundView.subviews {
			subviews.removeFromSuperview()
		}
		
		if Int(num[indexPath.item]) != nil {
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
					
					cellOne.currentDateIndicatorView.layer.borderColor = UIColor.white.cgColor
					cellOne.currentDateIndicatorView.layer.borderWidth = 2
					cellOne.currentDateIndicatorView.layer.cornerRadius = 5
					cellOne.currentDateIndicatorView.isHidden = false
				}
			} else {
				cellOne.cellDate = plusmonth(date: theDate)
			}
			
			if(eventsForDate(parDate: theDate).count != 0 && cellOne.cellDate == theDate) {
				cellOne.theDotViewBackgroundView.isHidden = false
				
				for events in eventsForDate(parDate: theDate) {
					let dotViewWidth: CGFloat = 4
					let dotViewHeight: CGFloat = 4
					
					let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotViewWidth, height: dotViewHeight))
					
					dotView.backgroundColor = UIColor(named: "\(events.tagColor!)")
					dotView.layer.cornerRadius = dotViewWidth/3

					cellOne.theDotViewBackgroundView.addSubview(dotView)
					
					cellOne.theDotViewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
					dotView.translatesAutoresizingMaskIntoConstraints = false
					
					if formatterTwo.string(from: theDate) == formatterTwo.string(from: selectedDate) {
						cellOne.changeBackgroundDarkGrey()
						previouslySelectedCellIndexPath = indexPath
					} else {
						cellOne.changeBackgroundBlack()
					}
					cellOne.theDotViewBackgroundView.layer.cornerRadius = 4
					
					//If statement for setting up theDotViewBackgroundView
					var widthMultiplier: CGFloat = 0
					if eventsForDate(parDate: theDate).count <= 4 {
						widthMultiplier = CGFloat(eventsForDate(parDate: theDate).count)
						
						let theDotViewBackgroundBottomConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.bottomAnchor.constraint(equalTo: cellOne.label.bottomAnchor, constant: 7)
						theDotViewBackgroundBottomConstraint.isActive = true
						theDotViewBackgroundBottomConstraint.identifier = "theDotViewBackground-Bottom"
						
						let theDotViewBackgroundViewHeightConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.heightAnchor.constraint(equalTo: dotView.heightAnchor, constant: dotViewHeight)
						theDotViewBackgroundViewHeightConstraint.isActive = true
						theDotViewBackgroundViewHeightConstraint.identifier = "theDotViewBackgroundView-Height-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.centerYAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.centerYAnchor)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
						
					} else {
						widthMultiplier = 4
						
						let theDotViewBackgroundBottomConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.bottomAnchor.constraint(equalTo: cellOne.label.bottomAnchor, constant: 7)
						theDotViewBackgroundBottomConstraint.isActive = true
						theDotViewBackgroundBottomConstraint.identifier = "theDotViewBackground-Bottom"
						
						let theDotViewBackgroundViewHeightConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.heightAnchor.constraint(equalTo: dotView.heightAnchor, multiplier: 2, constant: (dotViewHeight*2)-2)
						theDotViewBackgroundViewHeightConstraint.isActive = true
						theDotViewBackgroundViewHeightConstraint.identifier = "theDotViewBackgroundView-Height-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.bottomAnchor, constant: -2)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
					}
					
					let dotViewWidthConstraint = dotView.widthAnchor.constraint(equalToConstant: dotViewWidth)
					dotViewWidthConstraint.isActive = true
					dotViewWidthConstraint.identifier = "dotView-Width-Constraint"
					dotView.heightAnchor.constraint(equalToConstant: 4).isActive = true
					
					let dotViewHeightConstaint = dotView.heightAnchor.constraint(equalToConstant: dotViewHeight)
					dotViewHeightConstaint.isActive = true
					dotViewHeightConstaint.identifier = "dotView-Height-Constraint"
					
					let theDotViewBackgroundViewWidthConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.widthAnchor.constraint(equalTo: dotView.widthAnchor, multiplier: CGFloat(widthMultiplier), constant: 2*CGFloat((widthMultiplier+1)))
					theDotViewBackgroundViewWidthConstraint.isActive = true
					theDotViewBackgroundViewWidthConstraint.identifier = "theDotViewBackgroundView-Width-Constraint"
					
					//For non-centered: cellOne.theDotViewBackgroundView.leadingAnchor.constraint(equalTo: cellOne.leadingAnchor, constant: 7)
					let theDotViewBackgroundViewLeadingConstraint: NSLayoutConstraint = cellOne.theDotViewBackgroundView.centerXAnchor.constraint(equalTo: cellOne.centerXAnchor, constant: 0)
					theDotViewBackgroundViewLeadingConstraint.isActive = true
					theDotViewBackgroundViewLeadingConstraint.identifier = "theDotViewBackgroundView-Leading-Constraint"
					
					//If Statement to determine the leading constraint of dotView.
					if cellOne.theDotViewBackgroundView.subviews.count == 1 {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.leadingAnchor, constant: 2)
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
					} else if cellOne.theDotViewBackgroundView.subviews.count <= 4 {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews[0].leadingAnchor, constant: CGFloat((cellOne.theDotViewBackgroundView.subviews.count)-1)*(dotView.frame.width+2))
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
					} else if cellOne.theDotViewBackgroundView.subviews.count == 5 {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews.first!.leadingAnchor, constant: -1)
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews.first!.topAnchor, constant: -2)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
						
					} else {
						let dotViewLeadingConstraint: NSLayoutConstraint = dotView.leadingAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews[3].leadingAnchor, constant: 1)
						dotViewLeadingConstraint.isActive = true
						dotViewLeadingConstraint.identifier = "dotView-X-Constraint"
						
						let dotViewYConstraint: NSLayoutConstraint = dotView.bottomAnchor.constraint(equalTo: cellOne.theDotViewBackgroundView.subviews.first!.topAnchor, constant: -2)
						dotViewYConstraint.isActive = true
						dotViewYConstraint.identifier = "dotView-Y-Constraint"
						
					}
				}
			}
			let _: () = cellOne.selectedBackgroundView = {
				let view = UIView()
				view.layer.cornerRadius = 5
				view.backgroundColor = UIColor.darkGray
				
				return view
			}()
			
			cellOne.selectedBackgroundView!.frame = CGRect(x: (cellOne.frame.width-cellOne.frame.height)/2, y: 0, width: cellOne.frame.height, height: cellOne.frame.height)
		}
		
		cellOne.label.text = num[indexPath.item]
		
		return cellOne
	}
}

//MARK: ColectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate {
	///The logit for enabling infinite scrolling.
	func scroll() {
		collectionView.scrollToItem(at: IndexPath(item: 50, section: 0), at: .top, animated: false)
		collectionView.reloadData()
	}
	
	///enabling infinite scroll by calling the scroll() function.
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if(collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 0, section: 0)) {
			selectedDate = minusMonth(date: selectedDate)
			fillMonth(parDate: selectedDate)
			scroll()
			yearLabel.text = yearString(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			selectCellAfterScroll()
			
		} else if collectionView.indexPathsForVisibleItems[0] == IndexPath.init(item: 105, section: 0){
			selectedDate = plusmonth(date: selectedDate)
			fillMonth(parDate: selectedDate)
			scroll()
			yearLabel.text = yearString(date: selectedDate)
			monthLabel.text = monthString(date: selectedDate)
			selectCellAfterScroll()
		}
	}
	
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
	
	///Checks to see if the value contained in cellOne.label.text is an integer. If true it updates the previously selected cell and the newly selected cell so that theDotViewBackGrouldView of CollectionViewCell's background color is equal to the background of the cell.
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		if(Int(cellOne.label.text!) != nil) {
			selectCell(indexPath: indexPath)
			collectionView.reloadItems(at: [indexPath, previouslySelectedCellIndexPath!])
			//collectionView.reloadItems(at: [previouslySelectedCellIndexPath!])
			return true
		} else {
			return false
		}
	}
	
	///Logic for updating userSelectedDate after a new cell is selected by user. This method then reloads the tableView data if data exists, otherwise it informs the user that no events are scheduled for the newly selected date.
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
	
	///selects the required cell. if the selectedDate is within the current month, the current date is selected using currentDateAndTime(). Otherwise the first day of the currently displayed month is selected. This method then calls selectCell() to update the selectedDate and reload the tableView data or show that there are no events scheduled on the newly selected date.
	func selectCellAfterScroll() {
		if firstDayOfMonth(date: selectedDate) == firstDayOfMonth(date: currentDateAndTime()) {
			let dateToSelectPlusSeven = 7+weekDay(date: firstDayOfMonth(date: currentDateAndTime()))+dayOfMonth(date: currentDateAndTime())
			
			collectionView.selectItem(at: IndexPath(item: 49+dateToSelectPlusSeven-1, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.init(rawValue: UInt(dateToSelectPlusSeven)))
			
			selectCell(indexPath: (IndexPath(item: 49+dateToSelectPlusSeven-1, section: 0)))
		} else {
			let dateToSelectPlusSeven = 7+weekDay(date: firstDayOfMonth(date: selectedDate))
			
			collectionView.selectItem(at: IndexPath(item: (49+dateToSelectPlusSeven), section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.init(rawValue: UInt(dateToSelectPlusSeven)))
			
			selectCell(indexPath: (collectionView.indexPathsForSelectedItems?.first)!)
		}
	}
}

//MARK: TableViewDataSource

extension CalendarViewController: UITableViewDataSource {
	///Determines the number of rows in each section of the tableView which is 	determined by the function eventsForDate which returns all the events that are associated with any givin date.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		eventsForTableViewCell = eventsForDate(parDate: selectedDate)
		
		if eventsForDate(parDate: selectedDate).isEmpty == false {
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
			
			noEventsScheduledLabel.textColor = UIColor.placeholderText
			noEventsScheduledLabel.text = "no events scheduled"
			
			cellOne.TimeLabel.text = ""
			
		} else {
			
			noEventsScheduledLabel.text = ""
			
			cellOne.EventLabel.textColor = UIColor.label
			cellOne.EventLabel.text = eventsForTableViewCell[indexPath.item].nameOfEvent
			
			let temp = DateFormatter()
			temp.timeStyle = .short
			temp.dateStyle = .none
			
			cellOne.TimeLabel.text = temp.string(from: eventsForTableViewCell[indexPath.item].date)
			
		}
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

extension NSLayoutConstraint {
	override public var description: String {
		let id = identifier ?? ""
		return "--id: \(id), constant: \(constant)" //you may print whatever you want here
	}
}

