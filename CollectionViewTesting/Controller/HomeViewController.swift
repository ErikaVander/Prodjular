//
//  HomeViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/22/25.
//
import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
	@IBOutlet weak var groupButton: UIButton!
	@IBOutlet weak var friendsButton: UIButton!
	@IBOutlet weak var tableViewContainer: GenericTable!
	@IBOutlet weak var containerView: GenericTableWithHeader!
	
	override func viewDidLoad() {
		containerView.tableView.delegate = self
		containerView.tableView.dataSource = self
		containerView.tableView.register(UINib(nibName: "NotificationTableCell", bundle: nil), forCellReuseIdentifier: "notificationTableCell")
		containerView.headerLabel.text = "Notifications"
		
		tableViewContainer.tableView.delegate = self
		tableViewContainer.tableView.dataSource = self
		tableViewContainer.tableView.register(UINib(nibName: "FriendsTableViewTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsTableCell")
		notificationService.shared.delegate = self
		
//		groupService.shared.delegate = self
//		userGroupService.shared.delegate = self
		notificationService.shared.startObservingUserNotifications(for: Auth.auth().currentUser!.uid)
		
//		addPlusAndSearchButton()
//		containerView.addHideButton()
		containerView.addSearchButton()
		
		setButtonView()
		
		print("hello\n\n")
	}
	
//	override func viewDidLayoutSubviews() {
//		super.viewDidLayoutSubviews()
//		
//	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setButtonView()
	}
	
	@IBAction func groupButtonTapped(_ sender: Any) {
		notificationService.shared.stopObserving()
		showGroupViewController()
	}
	
	
	func showGroupViewController() {
		let vc = GroupViewController(nibName: "GroupViewController", bundle: nil)
		
		vc.modalPresentationStyle = .fullScreen
		
		self.present(vc, animated: true, completion: nil)
	}
	
	func setButtonView() {
		friendsButton.layer.masksToBounds = true
		friendsButton.layer.cornerRadius = 12
		groupButton.layer.masksToBounds = true
		groupButton.layer.cornerRadius = 12
		
		friendsButton.setTitle("", for: .normal)
		groupButton.setTitle("", for: .normal)
	}
}

//extension HomeViewController: groupServiceDelegate {
//	func logicForDeletingTableViewCell(_ databaseManager: groupService, indexPath: IndexPath) {
//		
//	}
//	func groupListDidLoad(_groups: [ProjdularGroup]) {
//		print("\n\n**ListDidLoad: \(_groups)\n\n")
//	}
//	func didReceiveError(_ error: Error) {
//		print("\n\n**Error: \(error)\n\n")
//	}
//}
//
//extension HomeViewController: userGroupServiceDelegate {
//	func logicForDeletingTableViewCell(_ databaseManager: userGroupService, indexPath: IndexPath) {
//		
//	}
//	func userGroupWasAdded(_ group: userGroup) {
//		print("\n\n**UserGroup Added: \(group)\n\n")
//	}
//	func userGroupWasChanged(_ group: userGroup, at index: Int) {
//		print("\n\n**UserGroup Changed: \(group)\n\n")
//	}
//	func userGroupWasRemoved(at index: Int) {
//		print("\n\n**UserGroup Removed at: \(index)\n\n")
//	}
//}

extension HomeViewController: notificationServiceDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: notificationService, indexPath: IndexPath) {
		containerView.tableView.reloadData()
	}
	func notificationWasAdded(_ notification: ProjdularNotification, at index: Int) {
		print("**Notification was added: \(notification)")
		containerView.tableView.reloadData()
	}
	func notificationWasChanged(_ notification: ProjdularNotification, at index: Int) {
		print("**Notification was changed: \(notification)")
		containerView.tableView.reloadData()
	}
	func notificationNameWasChanged(_ notification: ProjdularNotification, at index: Int) {
		print("**Notification name was changed: \(notification)")
		containerView.tableView.reloadData()
	}
	func notificationWasRemoved(at index: Int) {
		print("**Notification was removed at: \(index)")
		containerView.tableView.reloadData()
	}
	func notificationListDidLoad(_notifications: [ProjdularNotification]) {
		print("**Notifications loaded: \(_notifications)")
		containerView.tableView.reloadData()
	}
	func didReceiveError(_ error: any Error) {
		print("**\(error)")
	}
}

extension HomeViewController: UITableViewDelegate {
	
}

extension HomeViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(tableView == containerView.tableView) {
			return notificationList.count
		} else {
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if(tableView == containerView.tableView) {
			let cellOne = containerView.tableView.dequeueReusableCell(withIdentifier: "notificationTableCell", for: indexPath) as! NotificationTableCell
			
			cellOne.headerLabel.text = notificationList[indexPath.item].header
			cellOne.contentLabel.text = notificationList[indexPath.item].content
			let timeLabelDate = timeIntervalToDate(timeInterval: notificationList[indexPath.item].timestamp)
			let timeLabelString = getHowLongAgoFromTimeInterval(date: timeLabelDate)
			cellOne.timeLabel.text = timeLabelString
			return cellOne
		} else {
			let cellOne = tableViewContainer.tableView.dequeueReusableCell(withIdentifier: "friendsTableCell", for: indexPath) as! FriendsTableViewTableViewCell
			
//			cellOne.nameLabel.text = Auth.auth().currentUser?.displayName
			cellOne.nameLabel.text = "Erika Vanderhoff"
			cellOne.emailLabel.text = Auth.auth().currentUser?.email
			if initialLoadingOfDataForAccountInfo == true {
				userService.shared.loadProfilePhoto(for: Auth.auth().currentUser!.uid) { [weak self] result in
					switch result {
					case .failure(let error):
						print("**error: ", error)
					case .success(let image):
						cellOne.friendProfilePhoto.image = image
						cellOne.setFriendProfilePhotoConstraints()
					}
				}
				print("--initialLoadingOfDataForAccountInfo = true")
				initialLoadingOfDataForAccountInfo = false
			} else {
				userService.shared.loadProfilePhotoWithCaching(for: Auth.auth().currentUser!.uid) { [weak self] result in
					switch result {
					case .failure(let error):
						print("**error: ", error)
					case .success(let image):
						cellOne.friendProfilePhoto.image = image
						cellOne.setFriendProfilePhotoConstraints()
					}
				}
				print("--initialLoadingOfDataForAccountInfo = false")
			}
			return cellOne
		}
	}
	
	
}
