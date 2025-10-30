//
//  EventVC.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/18/25.
//

import UIKit
import FirebaseAuth

class EventVC: UIViewController {
	var eventID: String?
	var event: ProjdularEvent?
	@IBOutlet weak var eventNameLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var actionView: UIView!
	@IBOutlet weak var submitTimesButton: UIButton!
	@IBOutlet weak var actionLabelButton: UIButton!
	@IBOutlet weak var actionLabelA: UILabel!
	@IBOutlet weak var actionLabelB: UILabel!
	@IBOutlet weak var labelAA: UILabel!
	@IBOutlet weak var labelAB: UILabel!
	@IBOutlet weak var labelBA: UILabel!
	@IBOutlet weak var labelBB: UILabel!
	@IBOutlet weak var labelCA: UILabel!
	@IBOutlet weak var labelCB: UILabel!
	@IBOutlet weak var attendanceButton: UIButton!

	override func viewDidLoad() {
        super.viewDidLoad()
		attendanceButton.isHidden = true
		actionLabelButton.setTitle("", for: .normal)
		setDelegates()
		
		setViews()
    }

	@IBAction func goBack(_ sender: Any) {
		EventService.shared.stopObserving()
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		EventService.shared.stopObserving()
		self.view.window?.rootViewController?.dismiss(animated: true)
	}
	
	@IBAction func actionButtonPressed(_ sender: Any) {
		print("**action button pressed")
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
		if(actionLabelA.text == "Can't attend the event?") {
			
		} else if(actionLabelA.text == "Able to attend?") {
			
		} else if (dateFormatter.string(from: event!.endDate) == "January 1, 2000 at 12:00:00 AM GMT" && event?.type == "week") {
//			let vc = NewGroupViewController(nibName: "NewGroupViewController", bundle: nil)
//			
//			vc.modalPresentationStyle = .fullScreen
//			
//			userGroupService.shared.stopObserving()
//			userPendingGroupService.shared.stopObserving()
//			
//			self.present(vc, animated: true, completion: nil)
//			
//			print("**plus button tapped logic")
		} else if (dateFormatter.string(from: event!.endDate) == "January 1, 2000 at 12:00:00 AM GMT" && event?.type == "month") {
			let vc = MonthVC(nibName: "MonthVC", bundle: nil)
			
			vc.event = event
			vc.eventID = eventID
			EventService.shared.stopObserving()
			
			vc.modalPresentationStyle = .fullScreen
			self.present(vc, animated: true, completion: nil)
			
			print("**action button tapped logic")
		}
	}
	
	func setViews() {
		actionView.layer.cornerRadius = 10
		attendanceButton.layer.cornerRadius = 10
		
		backButton.setTitle("", for: .normal)
		homeButton.setTitle("", for: .normal)
		submitTimesButton.setTitle("", for: .normal)
	}
}

extension EventVC: EventServiceDelegate {
	func logicForDeletingTableViewCell(databaseManager: EventService, indexPath: IndexPath) {
		print("**LogicForDeletingTableViewCell")
	}
	
	func pendingEventListDidLoad(events: [ProjdularEvent]) {
		print("**PendingEventListDidLoad")
	}
	
	func setDelegates() {
		EventService.shared.delegate = self
		EventService.shared.startObservingUserEvents(for: eventID!)
	}
	func eventDidLoad(event: ProjdularEvent) {
		let dateFormatter = DateFormatter()
		self.event = event
		
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
		if(dateFormatter.string(from: event.endDate) != "January 1, 2000 at 12:00:00 AM GMT" && event.eventMembers.first(where: {$0.userID == Auth.auth().currentUser?.uid})?.isAttending == true) {
			let dateFormatterOne = DateFormatter()
			dateFormatterOne.dateFormat = "MMMM d, yyyy"
			let dateFormatterTwo = DateFormatter()
			dateFormatterTwo.dateFormat = "h:mm a"
			
//			let actionViewHeightConstraint: NSLayoutConstraint = actionView.heightAnchor.constraint(equalToConstant: 0)
//			actionViewHeightConstraint.isActive = true
//			actionViewHeightConstraint.identifier = "actionViewHeightConstraint"
			actionView.backgroundColor = UIColor(named: "UIRed")
			eventNameLabel.text = event.nameOfEvent
			actionLabelA.text = "Can't attend the event?"
			actionLabelB.text = "Click to cancel your RSVP."
			labelAA.text = "Time"
			labelAB.text = "\(dateFormatterOne.string(from: event.startDate)) \n\(dateFormatterTwo.string(from: event.startDate)) - \(dateFormatterTwo.string(from: event.endDate))"
			labelBA.text = "Location"
			labelBB.text = "\(event.address)\n\(event.city) \(event.state) \(event.zip)"
			labelCA.text = "Description"
			labelCB.text = event.description!
		} else if (dateFormatter.string(from: event.endDate) != "January 1, 2000 at 12:00:00 AM GMT" && event.eventMembers.first(where: {$0.userID == Auth.auth().currentUser?.uid})?.isAttending == false) {
			let dateFormatterOne = DateFormatter()
			dateFormatterOne.dateFormat = "MMMM d, yyyy"
			let dateFormatterTwo = DateFormatter()
			dateFormatterTwo.dateFormat = "h:mm a"
			
			//			let actionViewHeightConstraint: NSLayoutConstraint = actionView.heightAnchor.constraint(equalToConstant: 0)
			//			actionViewHeightConstraint.isActive = true
			//			actionViewHeightConstraint.identifier = "actionViewHeightConstraint"
			actionView.backgroundColor = .lightGray
			eventNameLabel.text = event.nameOfEvent
			actionLabelA.text = "Able to attend?"
			actionLabelB.text = "Click to RSVP."
			labelAA.text = "Time"
			labelAB.text = "\(dateFormatterOne.string(from: event.startDate)) \n\(dateFormatterTwo.string(from: event.startDate)) - \(dateFormatterTwo.string(from: event.endDate))"
			labelBA.text = "Location"
			labelBB.text = "\(event.address)\n\(event.city) \(event.state) \(event.zip)"
			labelCA.text = "Description"
			labelCB.text = event.description!
		} else if (event.eventMembers.first(where: {$0.userID == Auth.auth().currentUser?.uid})?.didSubmitTimes != false) {
			let dateFormatterOne = DateFormatter()
			dateFormatterOne.dateFormat = "MMMM d"
			let dateFormatterTwo = DateFormatter()
			dateFormatterTwo.dateFormat = "MMMM d, yyyy"
			actionView.backgroundColor = .lightGray
			eventNameLabel.text = event.nameOfEvent
			actionLabelA.text = "Edit your availability"
			actionLabelB.text = "You've already entered your availability, click here if you would like to change your availability."
			labelAA.text = "Scheduling Within Range"
			labelAB.text = "\(dateFormatterOne.string(from: event.startDate)) - \(dateFormatterTwo.string(from: minusNumWeek(date: event.startDate, num: 2)))"
			labelBA.text = "Location"
			labelBB.text = "\(event.address)\n\(event.city) \(event.state) \(event.zip)"
			labelCA.text = "Description"
			labelCB.text = event.description!
		} else {
			let dateFormatterOne = DateFormatter()
			dateFormatterOne.dateFormat = "MMMM d"
			let dateFormatterTwo = DateFormatter()
			dateFormatterTwo.dateFormat = "MMMM d, yyyy"
			actionView.backgroundColor = UIColor(named: "UIRed")
			eventNameLabel.text = event.nameOfEvent
			actionLabelA.text = "TAKE ACTION"
			actionLabelB.text = "Please click here to let the event organizer know when you'd be available."
			labelAA.text = "Scheduling Within Range"
			labelAB.text = "\(dateFormatterOne.string(from: event.startDate)) - \(dateFormatterTwo.string(from: minusNumWeek(date: event.startDate, num: 2)))"
			labelBA.text = "Location"
			labelBB.text = "\(event.address)\n\(event.city) \(event.state) \(event.zip)"
			labelCA.text = "Description"
			labelCB.text = event.description!
		}
	}
	func didReceiveError(error: any Error) {
		print("**ERROR: \(error)")
	}
}
