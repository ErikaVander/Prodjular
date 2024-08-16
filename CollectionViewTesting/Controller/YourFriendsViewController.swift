//
//  YourFriendsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/15/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class YourFriendsViewController: UIViewController {
	
	@IBOutlet weak var headerContainerView: UIView!
	@IBOutlet weak var friendsTableView: UITableView!
	@IBOutlet weak var addFriends: UIButton!
	@IBOutlet weak var backButton: NSLayoutConstraint!
	
	override func viewDidLoad() {
		self.observeFriends()
		addFriends.setTitle("", for: .normal)
		setHeaderContainerViewLook()
		
		//Registering xib files
		friendsTableView.register(UINib(nibName: "FriendsTableViewTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsTableCell")
		
		friendsTableView.dataSource = self
		friendsTableView.delegate = self
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
	
	func setHeaderContainerViewLook() {
		headerContainerView.layer.shadowOffset = .zero
		headerContainerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 25, width: headerContainerView.frame.width, height: headerContainerView.frame.height/2)).cgPath
		headerContainerView.layer.shadowOpacity = 0.5
		headerContainerView.layer.shadowRadius = 3
		
		headerContainerView.layer.shouldRasterize = true
		headerContainerView.layer.rasterizationScale = UIScreen.main.scale
	}
}

//MARK: TableViewDataSource
extension YourFriendsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if friendList.isEmpty == false {
			return friendList.count
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print("hello")
		let cellOne = friendsTableView.dequeueReusableCell(withIdentifier: "friendsTableCell", for: indexPath) as! FriendsTableViewTableViewCell
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			
		} else {
			cellOne.nameLabel.text = friendList[indexPath.item].name
			cellOne.emailLabel.text = friendList[indexPath.item].email
			
		}
		return cellOne
	}
}
	


//MARK: TableViewDelegate
extension YourFriendsViewController: UITableViewDelegate, DatabaseManagerDelegateForFriendsViewController {
	
	func logicForDeletingFriendTableViewCell(_ databaseManager: DatabaseManagerForFriendsViewController, indexPath: IndexPath) {
		print("Trying to print something")
		DispatchQueue.main.async {
			
			print("Trying to print friendList", friendList)
			friendList.remove(at: indexPath.row)
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
		print("Here")
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("friends")
		
		friendRef.observe(.value, with: { snapshot in
			
			var tempFriends = [Friend]()
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let name = dict["name"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String
				{
					let friend = Friend(id: id, name: name, email: email, tagName: tagName)
					tempFriends.append(friend)
				}
			}
			friendList = tempFriends
			//print("--eventsForDate: \(eventsForDate(parDate: selectedDate)) selectedDate: \(selectedDate))")
			if(initialLoadingOfData == true) {
				self.friendsTableView.reloadData()
				initialLoadingOfData = false
			}
		})
		
	}
}
