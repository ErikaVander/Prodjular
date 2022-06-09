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
	@IBOutlet weak var addButton: UIButton!
	
	var ref: DatabaseReference!
	
	var menuItems: [UIAction] {
		return [
			UIAction(title: "add Event", image: nil, handler: { (action) in
				self.showEventViewController()
			}),
			UIAction(title: "add Project", image: nil, handler: { (action) in
				self.showEventDurationViewController()
			}),
			UIAction(title: "add Prep to existing Project", image: nil, handler: { (action) in
				alertUser(view: self, title: "not yet available", content: "this feature is not yet available", dismissView: false)
			})
		]
	}
	var addMenu: UIMenu {
		return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Configuring addButton so that it shows the UIMenu when clicked
		addButton.menu = addMenu
		addButton.showsMenuAsPrimaryAction = true
		
		//Registering xib files
		collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
		tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableCell")

		print("--currentDate = \(currentDateAndTime())")
		Database.database().isPersistenceEnabled = true
		
		
		///Checking to see if a user is signed in. If not, shows the sign-in screen
		FirebaseAuth.Auth.auth().addStateDidChangeListener{ auth, user in
			if user != nil && user?.isEmailVerified == true {
				print("-- User: \(Auth.auth().currentUser?.email ?? "Was a nil value") --")
				isLoggedIn = true
				self.observeEvents()
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
		
		tableView.estimatedRowHeight = 100
		tableView.rowHeight = UITableView.automaticDimension
		
		tableView.reloadData()

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
}

extension NSLayoutConstraint {
	override public var description: String {
		let id = identifier ?? ""
		return "--id: \(id), constant: \(constant)" //you may print whatever you want here
	}
}
