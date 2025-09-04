//
//  userFriend.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/26/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing friend ids of all user's friends
var userFriends = [userFriend]()

struct userFriend : Equatable {
	var id: String
	var isFriend: Bool
}

protocol userFriendServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: userFriendService, indexPath: IndexPath)
	func userFriendWasAdded(_ friend: userFriend)
	func userFriendWasChanged(_ friend: userFriend, at index: Int)
	func userFriendWasRemoved(at index: Int)
	func didReceiveError(_ error: Error)
}

final class userFriendService {
	static let shared = userFriendService()
	
	var delegate: userFriendServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserFriends(for userID: String) {
		stopObserving()
		let userFriendsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let addedObserver = userFriendsRef.child("friends").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedUserFriends(snapshot)
		}
		observers.append(addedObserver)
		
		let changedObserver = userFriendsRef.child("friends").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChangedUserFriends(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = userFriendsRef.child("friends").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemovedUserFriends(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleChildAddedUserFriends(_ snapshot: DataSnapshot) {
		guard let friend = parseUserFriend(from: snapshot) else { return }
		
		userFriends.append(friend)
		
		DispatchQueue.main.async {
			self.delegate?.userFriendWasAdded(friend)
		}
	}
	
	private func handleChildChangedUserFriends(_ snapshot: DataSnapshot) {
		guard let updatedUserFriend = parseUserFriend(from: snapshot),
			  let existingIndex = userFriends.firstIndex(where: {$0.id == updatedUserFriend.id }) else {
			return
		}
		
		// Update the friend in our local array
		userFriends[existingIndex] = updatedUserFriend
		DispatchQueue.main.async {
			self.delegate?.userFriendWasChanged(updatedUserFriend, at: existingIndex)
		}
	}
	
	private func handleChildRemovedUserFriends(_ snapshot: DataSnapshot) {
		guard let friendID = snapshot.key as String?,
			  let existingIndex = userFriends.firstIndex(where: {$0.id == friendID}) else {
			return
		}
		
		userFriends.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.userFriendWasRemoved(at: existingIndex)
		}
		
		stopObserving()
	}
	
	private func parseUserFriend(from snapshot: DataSnapshot?) -> userFriend? {
		guard let snapshot = snapshot,
			  let friendID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any],
			  let isFriend = data["isFriend"] as? Bool else {
			return nil
		}
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return userFriend(
			id: friendID,
			isFriend: isFriend // Fetch from users node
		)
	}
	
	///Deletes friend
	public func userFriendDeleteFromUIView(with friend: userFriend, indexPath: IndexPath) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("friends").child(String(describing: friend.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func userFriendDelete(with friendID: String) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("friends").child(friendID).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	func stopObserving() {
		observers.forEach { handle in
			database.removeObserver(withHandle: handle)
		}
		observers.removeAll()
		friendList.removeAll()
	}
}
