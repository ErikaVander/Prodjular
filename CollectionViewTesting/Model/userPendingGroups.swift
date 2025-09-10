//
//  userPendingGroups.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/8/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing group ids of all user's groups
var userPendingGroupsList = [userPendingGroup]()

struct userPendingGroup : Equatable, Hashable {
	var id: String
	var name: String
	var adminName: String
	var numOfMembers: Int
}

protocol userPendingGroupServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: userPendingGroupService, indexPath: IndexPath)
	func userPendingGroupWasAdded(_ group: userPendingGroup)
	func userPendingGroupWasChanged(_ group: userPendingGroup, at index: Int)
	func userPendingGroupWasRemoved(at index: Int)
	func didReceiveError(_ error: Error)
}

final class userPendingGroupService {
	static let shared = userPendingGroupService()
	
	var delegate: userPendingGroupServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserPendingGroups(for userID: String) {
		stopObserving()
		let userPendingGroupsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let addedObserver = userPendingGroupsRef.child("pendingGroups").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedUserGroups(snapshot)
			print("userPending snapshot: \(snapshot)")
		}
		observers.append(addedObserver)
		
		let changedObserver = userPendingGroupsRef.child("pendingGroups").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChangedUserPendingGroups(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = userPendingGroupsRef.child("pendingGroups").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemovedUserPendingGroups(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleChildAddedUserGroups(_ snapshot: DataSnapshot) {
		guard let group = parseUserPendingGroup(from: snapshot) else { return }
		
		userPendingGroupsList.append(group)
		
		DispatchQueue.main.async {
			self.delegate?.userPendingGroupWasAdded(group)
		}
	}
	
	private func handleChildChangedUserPendingGroups(_ snapshot: DataSnapshot) {
		guard let updatedUserPendingGroup = parseUserPendingGroup(from: snapshot),
			  let existingIndex = userPendingGroupsList.firstIndex(where: {$0.id == updatedUserPendingGroup.id }) else {
			return
		}
		
		// Update the friend in our local array
		userPendingGroupsList[existingIndex] = updatedUserPendingGroup
		DispatchQueue.main.async {
			self.delegate?.userPendingGroupWasChanged(updatedUserPendingGroup, at: existingIndex)
		}
	}
	
	private func handleChildRemovedUserPendingGroups(_ snapshot: DataSnapshot) {
		guard let groupID = snapshot.key as String?,
			  let existingIndex = userPendingGroupsList.firstIndex(where: {$0.id == groupID}) else {
			return
		}
		
		userPendingGroupsList.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.userPendingGroupWasRemoved(at: existingIndex)
		}
		
		stopObserving()
	}
	
	private func parseUserPendingGroup(from snapshot: DataSnapshot?) -> userPendingGroup? {
		guard let snapshot = snapshot,
			  let groupID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			return nil
		}
		
		let name = data["name"] as? String ?? ""
		let adminName = data["adminName"] as? String ?? ""
		let numOfMembers = data["numOfMembers"] as? Int ?? 0
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return userPendingGroup(
			id: groupID,
			name: name, // Fetch from users node
			adminName: adminName,
			numOfMembers: numOfMembers
		)
	}
	
	///Deletes group
	public func userPendingGroupDeleteFromUIView(with group: userPendingGroup, indexPath: IndexPath) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("pendingGroups").child(String(describing: group.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func userPendingGroupDelete(with groupID: String) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("pendingGroups").child(groupID).setValue(nil) { error, database in
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
		userPendingGroupsList.removeAll()
	}
}
