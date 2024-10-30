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
	
	private let refreshControl = UIRefreshControl()
	
	deinit {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
		friendRef.removeAllObservers()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.observeAddedFriends()
		self.observeChangedFriends()
		
		setHeaderContainerViewLook()
		setFooterContainerViewLook()
		
		addFriends.setTitle("", for: .normal)
		
		//Registering xib files
		friendsTableView.register(UINib(nibName: "FriendsTableViewTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsTableCell")
		friendsTableView.register(UINib(nibName: "EmptyFriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyFriendsTableViewCell")
		
		friendsTableView.dataSource = self
		friendsTableView.delegate = self
		
		DatabaseManagerForFriendViewController.shared.delegate = self
		
		friendsTableView.translatesAutoresizingMaskIntoConstraints = false
		setupPullToRefresh()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		friendsTableView.estimatedRowHeight = 200
		friendsTableView.rowHeight = UITableView.automaticDimension
		friendsTableView.reloadData()
	}
	
	///Goes back to the settings page
	@IBAction func backToSettings(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
//	func setupPullToRefresh() {
//		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
//	}
	
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
				return friendReqSent.count + 1
			} else {
				return 1
			}
		} else {
			if friendList.isEmpty == false {
				return friendList.count + 1
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
		let cellTwo = friendsTableView.dequeueReusableCell(withIdentifier: "emptyFriendsTableViewCell", for: indexPath) as! EmptyFriendsTableViewCell
		if (tableView.numberOfRows(inSection: 0) == 0 && tableView.numberOfRows(inSection: 1) == 0 && tableView.numberOfRows(inSection: 2) == 0) {
		} else {
			if(indexPath.section == 0)
			{
				if(self.friendsTableView.numberOfRows(inSection: 0) == 1) {
					print("--here")
					
					cellTwo.setNeedsLayout()
						
					cellTwo.emptyLabel.text = "No pending requests"
					cellTwo.emptyLabel.sizeToFit()
					cellTwo.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
					
					cellTwo.heightConstraint!.isActive = false
					cellTwo.heightConstraintEmpty!.isActive = true
					
					cellTwo.emptyLabelCenterXConstraint!.isActive = true
					cellTwo.emptyLabelCenterYConstraint!.isActive = true
					
					var emptyLabelWidth: NSLayoutConstraint
					emptyLabelWidth = cellTwo.containerView.widthAnchor.constraint(equalTo: cellTwo.widthAnchor, multiplier: 1)
					emptyLabelWidth.isActive = true
					
					cellTwo.layoutIfNeeded()
					
					return cellTwo
				} else {
					if(indexPath.item == friendReqSent.count) {
						cellTwo.emptyLabel.text = ""
						cellTwo.contentView.translatesAutoresizingMaskIntoConstraints = false
						
						cellTwo.heightConstraintEmpty!.isActive = false
						cellTwo.heightConstraint!.isActive = true
						
						return cellTwo
					} else {
						print("--indexPath.item: ", indexPath.item, friendReqSent.count)
						cellOne.nameLabel.text = friendReqSent[indexPath.item].userName
						cellOne.emailLabel.text = friendReqSent[indexPath.item].email
						cellOne.setFriend(friend: friendReqSent[indexPath.item])
					}
				}
			} else if(indexPath.section == 1) {
				if(self.friendsTableView.numberOfRows(inSection: 1) == 1) {
					cellTwo.emptyLabel.text = "You have no friends"
					cellTwo.emptyLabel.sizeToFit()
					cellTwo.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
					
					cellTwo.heightConstraint!.isActive = false
					cellTwo.heightConstraintEmpty!.isActive = true
					
					cellTwo.emptyLabelCenterXConstraint!.isActive = true
					cellTwo.emptyLabelCenterYConstraint!.isActive = true
					
					var emptyLabelWidth: NSLayoutConstraint
					emptyLabelWidth = cellTwo.containerView.widthAnchor.constraint(equalTo: cellTwo.widthAnchor, multiplier: 1)
					emptyLabelWidth.isActive = true
					
					cellTwo.layoutIfNeeded()

					return cellTwo
				} else {
					if(indexPath.item == friendList.count) {
						cellTwo.emptyLabel.text = ""
						cellTwo.contentView.translatesAutoresizingMaskIntoConstraints = false
						
						cellTwo.heightConstraintEmpty!.isActive = false
						cellTwo.heightConstraint!.isActive = true
						
						return cellTwo
					} else {
						print("--indexPath.item: ", indexPath.item, friendList.count)
						cellOne.nameLabel.text = friendList[indexPath.item].userName
						cellOne.emailLabel.text = friendList[indexPath.item].email
						cellOne.setFriend(friend: friendList[indexPath.item])
					}
				}
			}
			
		}
		return cellOne
	}
	
	func setConstraintsForCell(indexPath: IndexPath) {
		let cell = self.friendsTableView.cellForRow(at: indexPath) as! EmptyFriendsTableViewCell
		if(indexPath.section == 0) {
			cell.emptyLabel.text = "no pending requests"
		} else {
			cell.emptyLabel.text = "you have no friends"
		}
	}
}
	


//MARK: TableViewDelegate
extension YourFriendsViewController: UITableViewDelegate, DatabaseManagerDelegateForFriendsViewController {
	
	private func setupPullToRefresh() {
		// Configure refresh control
		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.placeholderText,
			.font: UIFont.systemFont(ofSize: 12)
		]
		
		refreshControl.attributedTitle = NSAttributedString(string: "")
		let attributedText = NSAttributedString(
			string: "refreshing",
			attributes: attributes
		)
		
		refreshControl.attributedTitle = attributedText
		refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
		
		// Add refresh control to table view
		friendsTableView.refreshControl = refreshControl
	}
	
	@objc private func refreshData() {
		refreshControl.beginRefreshing()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
			self?.fetchData()
		}
	}
	
	func logicForDeletingFriendTableViewCell(_ databaseManager: DatabaseManagerForFriendViewController, indexPath: IndexPath) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {return}
			friendList.remove(at: indexPath.item)
			self.friendsTableView.deleteRows(at: [indexPath], with: .fade)
			self.friendsTableView.reloadData()
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
			if(indexPath.section == 0) {
				let cell = tableView.cellForRow(at: indexPath) as? FriendsTableViewTableViewCell
				let index = friendReqSent.firstIndex(of: cell!.friend)
				
				print("--cell: ", cell?.friend ?? "did not find a friend")
				
				DatabaseManagerForFriendViewController.shared.deleteFriendFromCell(with: friendReqSent[index!], indexPath: indexPath)
				friendReqSent.remove(at: index!)
				
			} else if(indexPath.section == 1) {
				print("--number of rows in section before before: ", self.friendsTableView.numberOfRows(inSection: 1))
				let cell = tableView.cellForRow(at: indexPath) as? FriendsTableViewTableViewCell
				let index = friendList.firstIndex(of: cell!.friend)
				
				print("--cell: ", cell?.friend ?? "did not find a friend")
				
				DatabaseManagerForFriendViewController.shared.deleteFriendFromCell(with: friendList[index!], indexPath: indexPath)
				print("--number of rows in section before after: ", self.friendsTableView.numberOfRows(inSection: 1))
				
			}
		}
	}
}

//MARK: FirebaseRealtimeDatabase
extension YourFriendsViewController {
	///Getting all the events created by the user and storing them in eventList so that the table view can display them.
	func observeAddedFriends() {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
		
		friendRef.observe(.childAdded, with: { [weak self] snapshot in
			guard let self = self else {return}
			
			var tempFriendList = [Friend]()
			var tempFriendReqSent = [Friend]()
			var tempFriendReqReceived = [Friend]()
			
			print("snapshot: ", snapshot)
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userName = dict["userName"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let status = dict["status"] as? String,
				   let photoURL = dict["profilePhotoURL"] as? String
				{
					let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status, profilePhotoURL: photoURL)
					print("--friend got from database: ", status)
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
			
			print("--friendList: ", friendList)
			print("--friendReqReceived: ", friendReqReceived)
			print("--friendReqSent: ", friendReqSent)
			
			if (friendReqReceived.count != 0) {
				self.friendReqButton.setImage(UIImage(systemName: "envelope.badge"), for: .normal)
			} else {
				self.friendReqButton.setImage(UIImage(systemName: "envelope"), for: .normal)
			}
			self.friendsTableView.reloadData()
		})
	}
	func observeChangedFriends() {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
		
		friendRef.observe(.childChanged, with: { [weak self] snapshot in
			guard let self = self else {return}
			
			var tempFriendList = [Friend]()
			var tempFriendReqSent = [Friend]()
			var tempFriendReqReceived = [Friend]()
			
			print("snapshot: ", snapshot)
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userName = dict["userName"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let status = dict["status"] as? String,
				   let photoURL = dict["profilePhotoURL"] as? String
				{
				let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status, profilePhotoURL: photoURL)
				print("--friend got from database: ", status)
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
			
			print("--friendList: ", friendList)
			print("--friendReqReceived: ", friendReqReceived)
			print("--friendReqSent: ", friendReqSent)
			
			if (friendReqReceived.count != 0) {
				self.friendReqButton.setImage(UIImage(systemName: "envelope.badge"), for: .normal)
			} else {
				self.friendReqButton.setImage(UIImage(systemName: "envelope"), for: .normal)
			}
			self.friendsTableView.reloadData()
		})
	}
	func fetchData() {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("friends")
		
		friendRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
			guard let self = self else {return}
			
			var tempFriendList = [Friend]()
			var tempFriendReqSent = [Friend]()
			var tempFriendReqReceived = [Friend]()
			
			print("snapshot: ", snapshot)
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userName = dict["userName"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let status = dict["status"] as? String,
				   let photoURL = dict["profilePhotoURL"] as? String
				{
				let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status, profilePhotoURL: photoURL)
				print("--friend got from database: ", status)
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
			
			print("--friendList: ", friendList)
			print("--friendReqReceived: ", friendReqReceived)
			print("--friendReqSent: ", friendReqSent)
			
			if (friendReqReceived.count != 0) {
				self.friendReqButton.setImage(UIImage(systemName: "envelope.badge"), for: .normal)
			} else {
				self.friendReqButton.setImage(UIImage(systemName: "envelope"), for: .normal)
			}
			self.friendsTableView.reloadData()
		})
		
		DispatchQueue.main.async { [weak self] in
			self?.refreshControl.endRefreshing()
			self?.friendsTableView.reloadData()
		}
	}
}
