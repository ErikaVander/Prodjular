//
//  FriendRequestViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Foundation

var initialLoadingOfDataForFriendRequest = true

class FriendRequestViewController: UIViewController {

	@IBOutlet weak var noPendingRequestsLabel: UILabel!
	@IBOutlet weak var friendRequestContainerView: UIView!
	@IBOutlet weak var friendRequestTableView: UITableView!
	
	deinit {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
		friendRef.removeAllObservers()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		friendRequestTableView.register(UINib(nibName: "FriendReqTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendRequestReceivedCell")
		friendRequestTableView.register(UINib(nibName: "EmptyFriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyFriendsTableViewCell")
		
		friendRequestTableView.dataSource = self
		friendRequestTableView.delegate = self
		
		friendRequestContainerView.layer.cornerRadius = 50
		friendRequestTableView.layer.cornerRadius = 50
		
		self.observeFriends()
		self.friendRequestTableView.reloadData()
    }
}

//MARK: TableViewDataSource
extension FriendRequestViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if friendReqReceived.isEmpty == false {
			return friendReqReceived.count
		} else {
//			return 1
			noPendingRequestsLabel.isHidden = true
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Pending Requests"
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellOne = friendRequestTableView.dequeueReusableCell(withIdentifier: "FriendRequestReceivedCell", for: indexPath) as! FriendReqTableViewCell
		if (tableView.numberOfRows(inSection: 0) == 0) {
			DispatchQueue.main.async {
				self.noPendingRequestsLabel.isHidden = false
			}
		} else {
			DispatchQueue.main.async {
				self.noPendingRequestsLabel.isHidden = true
			}
				cellOne.nameLabel.text = friendReqReceived[indexPath.item].userName
				cellOne.emailLabel.text = friendReqReceived[indexPath.item].email
				if(initialLoadingOfDataForFriendRequest == true) {
					userService.shared.loadProfilePhoto(for: friendReqReceived[indexPath.item].id, completion: { [weak self] result in
						switch result {
						case .success(let image):
							cellOne.friendProfilePhoto.image = image
						case .failure(let error):
							print("**error: ", error)
						}
					})
					print("--initialLoadingOfDataForFriendRequest == true")
					initialLoadingOfDataForFriendRequest = false
				} else {
					userService.shared.loadProfilePhotoWithCaching(for: friendReqReceived[indexPath.item].id, completion: { [weak self] result in
						switch result {
						case .success(let image):
							cellOne.friendProfilePhoto.image = image
						case .failure(let error):
							print("**error: ", error)
						}
					})
					print("--initialLoadingOfDataForFriendRequest == false")
				}
				cellOne.friendProfilePhoto.layer.cornerRadius = (self.friendRequestTableView.frame.width/5.5)/2
//				cellOne.friendProfilePhoto.image = friendReqReceived[indexPath.item].profilePhoto ?? UIImage(systemName: "person.circle.fill")
				cellOne.indexPath = indexPath
				cellOne.delegate = self
				cellOne.setFriend(friend: friendReqReceived[indexPath.item])
		}
		return cellOne
	}
}



//MARK: TableViewDelegate
extension FriendRequestViewController: UITableViewDelegate, FriendReqTableViewCellDelegate {
	func deleteRow(cell: UITableViewCell, friend: Friend) {
		let index = friendReqReceived.firstIndex(of: friend)
		friendReqReceived.remove(at: index!)
		friendRequestTableView.deleteRows(at: [self.friendRequestTableView.indexPath(for: cell)!], with: .right)
		if(friendReqReceived.isEmpty == true) {
			DispatchQueue.main.async {
				self.noPendingRequestsLabel.isHidden = false
			}
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if friendList.isEmpty == true && indexPath.item == 0 {
			//return false
			return true
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			friendService.shared.deleteFriendFromCell(with: friendList[indexPath.item], indexPath: indexPath)
		}
	}
	
}

//MARK: FirebaseRealtimeDatabase
extension FriendRequestViewController {
	///Getting all the events created by the user and storing them in eventList so that the table view can display them.
	func observeFriends() {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
		
		friendRef.observe(.childAdded, with: { [weak self] snapshot in
			
			var tempFriendReqReceived = [Friend]()

			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userName = dict["userName"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let status = dict["status"] as? String,
				   let photoURL = dict["profilePhotoURL"] as? String
//				   let ProfilePhotoLastUpdated = dict["ProfilePhotoLastUpdated"] as? String
				{
					let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status, profilePhotoURL: photoURL)
					if(status == "received") {
						tempFriendReqReceived.append(friend)
					}
				}
			}
			
			friendReqReceived = tempFriendReqReceived
		})
		
	}
}
