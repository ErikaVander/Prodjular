//
//  GroupEventsVC.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/15/25.
//

import UIKit
import FirebaseAuth

class GroupEventsVC: UIViewController {
	var groupID: String?
	var numMembers: Int?
	var eventsTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, groupEvent>!
	var pendingEventsTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, groupPendingEvent>!
	private var initialLoadOfEvents = true
	private var initialLoadOfPendingEvents = true
//	var pendingEventsTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, groupPendingEvent>!
	@IBOutlet weak var numMembersButton: UIButton!
	@IBOutlet weak var eventsView: GenericTableWithHeader!
	@IBOutlet weak var pendingEventsView: GenericTableWithHeader!
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setButtonViews()
		setTableViews()
		setTableViewDelegateAndDataSource()
		configureTableViewDataSources()
		userGroupService.shared.observeNumMembers(groupID: groupID!)
    }
	@IBAction func goBack(_ sender: Any) {
		groupEventService.shared.stopObserving()
		groupPendingEventService.shared.stopObserving()
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		groupEventService.shared.stopObserving()
		groupPendingEventService.shared.stopObserving()
		self.view.window?.rootViewController?.dismiss(animated: true)
	}
	
	func setButtonViews() {
		homeButton.setTitle("", for: .normal)
		homeButton.setImage(UIImage(systemName: "house"), for: .normal)
		
		settingsButton.setTitle("", for: .normal)
		settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
		
		backButton.setTitle("", for: .normal)
		backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		
		numMembersButton.layer.cornerRadius = 5
//		numMembersButton.setTitle("\(userGroupService.shared.observeNumMembers(groupID: groupID!)) Members", for: .normal)
		
//		numMembersButton.setTitle("\(await String(describing: userGroupService.shared.getNumMembers(groupID: groupID!))) Members", for: .normal)
	}
}
extension GroupEventsVC: GenericTableWithHeaderDelegate, GenericTCADelegate, GenericTCBDelegate {
	func cellTappedLogic(objectID: String) {
		let vc = EventVC(nibName: "EventVC", bundle: nil)
		
		vc.modalPresentationStyle = .fullScreen
		vc.eventID = objectID
		
		groupEventService.shared.stopObserving()
		groupPendingEventService.shared.stopObserving()
		
		self.present(vc, animated: true, completion: nil)
		print("**GroupEventVC-cellTappedLogic")
	}
	
	func buttonTappedLogic() {
		print("Hello")
	}
	
	enum Section {
		case main
	}
	func setTableViewDelegateAndDataSource() {
		groupEventService.shared.startObservingGroupEvents(for: groupID!)
		print("**GroupID: \(groupID!)")
		groupEventService.shared.delegate = self
		
		userGroupService.shared.delegateB = self
		
		eventsView.delegate = self
		
		eventsView.tableView.register(UINib(nibName: "GenericTCA", bundle: nil), forCellReuseIdentifier: "genericTCA")
		eventsView.tableView.register(UINib(nibName: "GenericTCB", bundle: nil), forCellReuseIdentifier: "genericTCB")
		
		groupPendingEventService.shared.startObservingGroupPendingEvents(for: groupID!)
		print("**GroupID: \(groupID!)")
		groupPendingEventService.shared.delegate = self
		
		pendingEventsView.delegate = self
		
		pendingEventsView.tableView.register(UINib(nibName: "GenericTCB", bundle: nil), forCellReuseIdentifier: "genericTCB")
		
	}
	func setTableViews() {
		eventsView.headerLabel.text = "Events"
		eventsView.addPlusAndSearchButton()
		
		pendingEventsView.headerLabel.text = "Pending Events"
		pendingEventsView.addSearchButton()
	}
	func configureTableViewDataSources() {
		let dateFormatterFirst = DateFormatter()
		dateFormatterFirst.dateFormat = "EEEE, MMMM d"
		let dateFormatterSecond = DateFormatter()
		dateFormatterSecond.dateFormat = "h:mm a"
		eventsTableViewDiffableDataSource = UITableViewDiffableDataSource(tableView: eventsView.tableView) { (tableView, indexPath, event) -> UITableViewCell? in
			if(event.attendingUsers.contains(where: {$0 == Auth.auth().currentUser?.uid})) {
				print("**event: \(event)")
				let cellOne = self.eventsView.tableView.dequeueReusableCell(withIdentifier: "genericTCA", for: indexPath) as! GenericTCA
				cellOne.nameLabel.text = event.name
				cellOne.labelA.text = dateFormatterFirst.string(from: event.startDate)
				cellOne.labelB.text = "\(dateFormatterSecond.string(from: event.startDate)) - \(dateFormatterSecond.string(from: event.endDate))"
				cellOne.hideButtonView()
				cellOne.showRightArrowButton()
				cellOne.objectID = event.id
				cellOne.delegate = self
				return cellOne
			} else {
				print("**attendingUsers: \(event.attendingUsers)")
				print("**attendingUsers True: \(event.attendingUsers.contains(where: {$0 == Auth.auth().currentUser?.uid}))")
				let cellOne = self.eventsView.tableView.dequeueReusableCell(withIdentifier: "genericTCB", for: indexPath) as! GenericTCB
				cellOne.nameLabel.text = event.name
				cellOne.labelA.text = dateFormatterFirst.string(from: event.startDate)
				cellOne.labelB.text = "\(dateFormatterSecond.string(from: event.startDate)) - \(dateFormatterSecond.string(from: event.endDate))"
				cellOne.labelC.text = "PLEASE RSVP"
				cellOne.objectID = event.id
				cellOne.delegate = self
				return cellOne

			}
		}
		let dateFormatterThird = DateFormatter()
		dateFormatterThird.dateFormat = "M/d/yy"
		pendingEventsTableViewDiffableDataSource = UITableViewDiffableDataSource(tableView: pendingEventsView.tableView) { (tableView, indexPath, event) -> UITableViewCell? in
			print("**Event: \(event)")
			let cellOne = self.pendingEventsView.tableView.dequeueReusableCell(withIdentifier: "genericTCB", for: indexPath) as! GenericTCB
			cellOne.nameLabel.text = event.name
			cellOne.labelA.text = "Will be scheduled within:"
			cellOne.labelB.text = dateFormatterThird.string(from: event.startDate)
			if(event.toSubmitTimesUsers.contains(where: {$0 == Auth.auth().currentUser!.uid})) {
				cellOne.labelC.text = "ACTION REQUIRED"
			} else {
				cellOne.labelC.text = "Pending Admin Approval"
				cellOne.labelC.textColor = .lightGray
			}
			cellOne.objectID = event.id
			cellOne.delegate = self
			return cellOne
		}
	}
	func applyEventsSnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, groupEvent>()
		snapshot.appendSections([.main])
		snapshot.appendItems(groupEventList)
		eventsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: !initialLoadOfEvents) { [weak self] in
			guard let self = self else {return}
			initialLoadOfEvents = false
			let rowCount = groupEventList.count
			
			self.eventsView.tableView.isScrollEnabled = rowCount > 1
		}
	}
	func applyPendingEventsSnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, groupPendingEvent>()
		snapshot.appendSections([.main])
		snapshot.appendItems(groupPendingEventList)
		pendingEventsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: !initialLoadOfPendingEvents) { [weak self] in
			guard let self = self else {return}
			initialLoadOfPendingEvents = false
			let rowCount = groupPendingEventList.count
			
			self.pendingEventsView.tableView.isScrollEnabled = rowCount > 1
		}
	}
	
	func setGenericTableWithHeaderView() {
		print("**Hello")
	}
	
	func plusButtonTappedLogic() {
		print("**Hello 2")
	}
	
	func searchButtonTappedLogic() {
		print("**Hello 3")
	}
}
extension GroupEventsVC: groupEventServiceDelegate, groupPendingEventServiceDelegate, userGroupServiceDelegateB {
	func logicForDeletingTableViewCell(_ databaseManager: groupPendingEventService, indexPath: IndexPath) {
		applyPendingEventsSnapshot()
		print("**logic for deleting table view cell")
	}
	
	func groupPendingEventWasAdded(_ event: groupPendingEvent) {
		applyPendingEventsSnapshot()
		print("**group event was added \(event)")
	}
	
	func groupPendingEventWasChanged(_ event: groupPendingEvent, at index: Int) {
		applyPendingEventsSnapshot()
		print("**group event was changed \(event)")
	}
	
	func groupPendingEventWasRemoved(at index: Int) {
		applyPendingEventsSnapshot()
		print("**group event was removed \(index)")
	}
	
	func numMembersWasRetreived(_ numMembers: Int) {
		numMembersButton.setTitle("\(numMembers) Members", for: .normal)
	}
	
	func logicForDeletingTableViewCell(_ databaseManager: groupEventService, indexPath: IndexPath) {
		applyEventsSnapshot()
		print("**logic for deleting table view cell")
	}
	
	func groupEventWasAdded(_ event: groupEvent) {
		applyEventsSnapshot()
		print("**group event was added \(event)")
	}
	
	func groupEventWasChanged(_ event: groupEvent, at index: Int) {
		applyEventsSnapshot()
		print("**group event was changed \(event)")
	}
	
	func groupEventWasRemoved(at index: Int) {
		applyEventsSnapshot()
		print("**group event was removed \(index)")
	}
	
	func didReceiveError(_ error: any Error) {
		print("**ERROR: \(error)")
	}
	
	
}
