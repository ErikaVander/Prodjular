//
//  YourFriendsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/15/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

var initialLoadingOfDataForFriendsTableView = true

class YourFriendsViewController: UIViewController {
	
	@IBOutlet weak var friendReqButton: UIButton!
	@IBOutlet var YourFriendsContainerView: UIView!
	@IBOutlet weak var footerButtonContainerView: UIView!
	@IBOutlet weak var footerContainerView: UIView!
	@IBOutlet weak var headerContainerView: UIView!
	@IBOutlet weak var friendsTableView: UITableView!
	@IBOutlet weak var addFriends: UIButton!
	@IBOutlet weak var backButton: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.observeFriends()
		
		setHeaderContainerViewLook()
		setFooterContainerViewLook()
		
		addFriends.setTitle("", for: .normal)
		
		//Registering xib files
		friendsTableView.register(UINib(nibName: "FriendsTableViewTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsTableCell")
		friendsTableView.register(UINib(nibName: "EmptyFriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyFriendsTableViewCell")
		
		friendsTableView.dataSource = self
		friendsTableView.delegate = self
		
		DatabaseManagerForFriendsViewController.shared.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		friendsTableView.estimatedRowHeight = 200
		friendsTableView.rowHeight = UITableView.automaticDimension
		
//		print("--printing friendList from viewWillAppear: ", friendList)
//		print("--printing friendReqReceived from viewWillAppear: ", friendReqReceived)
//		print("--printing friendReqSent from viewWillAppear: ", friendReqSent)
		friendsTableView.reloadData()
	}
	
	///Goes back to the settings page
	@IBAction func backToSettings(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func setHeaderContainerViewLook() {
		headerContainerView.layer.shadowOffset = .zero
		headerContainerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 25, width: headerContainerView.frame.width, height: headerContainerView.frame.height/2)).cgPath
		headerContainerView.layer.shadowOpacity = 0.5
		headerContainerView.layer.shadowRadius = 3
		headerContainerView.layer.shadowColor = UIColor.label.cgColor
		
		headerContainerView.layer.shouldRasterize = true
		headerContainerView.layer.rasterizationScale = UIScreen.main.scale
		friendsTableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
	}
	
	func setFooterContainerViewLook() {
		footerButtonContainerView.backgroundColor = UIColor.clear
		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(roundedRect: footerContainerView.bounds, byRoundingCorners: .topLeft, cornerRadii: CGSize(width: 20, height: 20)).cgPath
		footerContainerView.layer.mask = maskLayer
		
		
		let outerView = UIView(frame: CGRect(origin: footerContainerView.frame.origin, size: CGSize(width: footerContainerView.frame.width + 10.0, height: footerContainerView.frame.height + 10.0)))
		outerView.backgroundColor = .clear
		
		
		outerView.layer.shadowColor = UIColor.label.cgColor
		outerView.layer.shadowOpacity = 0.5
		outerView.layer.shadowOffset = .zero
		outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, byRoundingCorners: .topLeft, cornerRadii: CGSize(width: 20, height: 20)).cgPath
		YourFriendsContainerView.addSubview(outerView)
		outerView.addSubview(footerContainerView)
	}
}

//MARK: TableViewDataSource
extension YourFriendsViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(section == 0) {
			if friendReqSent.isEmpty == false {
				return friendReqSent.count
			} else {
				return 1
			}
		} else {
			if friendList.isEmpty == false {
				return friendList.count
			} else {
				return 1
			}
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if(section == 0){
			return "Pending Requests"
		} else {
			return "Friends"
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellOne = friendsTableView.dequeueReusableCell(withIdentifier: "friendsTableCell", for: indexPath) as! FriendsTableViewTableViewCell
		print("--index path section: ", indexPath.section)
		let cellTwo = friendsTableView.dequeueReusableCell(withIdentifier: "emptyFriendsTableViewCell", for: indexPath) as! EmptyFriendsTableViewCell
		if (tableView.numberOfRows(inSection: 0) == 0 && tableView.numberOfRows(inSection: 1) == 0 && tableView.numberOfRows(inSection: 2) == 0) {
		} else {
			if(indexPath.section == 0)
			{
				if(friendReqSent.isEmpty != true) {
					cellOne.nameLabel.text = friendReqSent[indexPath.item].userName
					cellOne.emailLabel.text = friendReqSent[indexPath.item].email
				} else {
					cellTwo.emptyLabel.text = "No pending requests"
					return cellTwo
				}
			} else if(indexPath.section == 1) {
				if( friendReqReceived.isEmpty != true) {
					cellOne.nameLabel.text = friendList[indexPath.item - friendReqSent.count].userName
					cellOne.emailLabel.text = friendList[indexPath.item - friendReqSent.count].email
				} else {
					cellTwo.emptyLabel.text = "You have no friends"
					return cellTwo
				}
				
			}
			
		}
		return cellOne
	}
}
	


//MARK: TableViewDelegate
extension YourFriendsViewController: UITableViewDelegate, DatabaseManagerDelegateForFriendsViewController {
	
	func logicForDeletingFriendTableViewCell(_ databaseManager: DatabaseManagerForFriendsViewController, indexPath: IndexPath) {
		DispatchQueue.main.async {
			
			//friendList.remove(at: indexPath.row)
			self.friendsTableView.deleteRows(at: [indexPath], with: .fade)
			
			if(self.friendsTableView.numberOfRows(inSection: 0) == 0) {
				//self.noEventsScheduledLabel.text = "no events scheduled"
			}
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if friendList.isEmpty == true && indexPath.item == 0 {
			return false
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			DatabaseManagerForFriendsViewController.shared.deleteFriend(with: friendList[indexPath.item], indexPath: indexPath)
		}
	}
	
}

//MARK: FirebaseRealtimeDatabase
extension YourFriendsViewController {
	///Getting all the events created by the user and storing them in eventList so that the table view can display them.
	func observeFriends() {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("friends")
		
		friendRef.observe(.value, with: { snapshot in
			
			var tempFriendList = [Friend]()
			var tempFriendReqSent = [Friend]()
			var tempFriendReqReceived = [Friend]()
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userName = dict["userName"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let status = dict["status"] as? String
				{
					let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status)
					print("--friend got from database: ", friend)
					if(status == "accepted") {
						tempFriendList.append(friend)
					} else if(status == "sent") {
						tempFriendReqSent.append(friend)
					} else if(status == "received") {
						tempFriendReqReceived.append(friend)
					}
				}
			}
			
			friendList = tempFriendList
			friendReqReceived = tempFriendReqReceived
			friendReqSent = tempFriendReqSent
			
			if (friendReqReceived.count != 0) {
				self.friendReqButton.setImage(UIImage(systemName: "envelope.badge"), for: .normal)
			} else {
				self.friendReqButton.setImage(UIImage(systemName: "envelope"), for: .normal)
			}
			
			//print("--eventsForDate: \(eventsForDate(parDate: selectedDate)) selectedDate: \(selectedDate))")
			if(initialLoadingOfDataForFriendsTableView == true) {
				self.friendsTableView.reloadData()
				initialLoadingOfDataForFriendsTableView = false
			}
		})
		
	}
}
