//
//  userGroup.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/25/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing group ids of all user's groups
var userGroupsList = [userGroup]()

struct userGroup : Equatable, Hashable {
	var id: String
	var name: String
	var isAdmin: Bool
	var adminName: String
	var numOfMembers: Int
}

protocol userGroupServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: userGroupService, indexPath: IndexPath)
	func userGroupWasAdded(_ group: userGroup)
	func userGroupWasChanged(_ group: userGroup, at index: Int)
	func userGroupWasRemoved(at index: Int)
	func didReceiveError(_ error: Error)
}

final class userGroupService {
	static let shared = userGroupService()
	
	var delegate: userGroupServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserGroups(for userID: String) {
		stopObserving()
		let userGroupsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let addedObserver = userGroupsRef.child("groups").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedUserGroups(snapshot)
			print("**userGroup snapshot: \(snapshot)")
		}
		observers.append(addedObserver)
		
		let changedObserver = userGroupsRef.child("groups").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChangedUserGroups(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = userGroupsRef.child("groups").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemovedUserGroups(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleChildAddedUserGroups(_ snapshot: DataSnapshot) {
		guard let group = parseUserGroup(from: snapshot) else {
			print("ERROR: Colud not parse UserGroup")
			return }
		
		userGroupsList.append(group)
		
		DispatchQueue.main.async {
			self.delegate?.userGroupWasAdded(group)
		}
	}
	
	private func handleChildChangedUserGroups(_ snapshot: DataSnapshot) {
		guard let updatedUserGroup = parseUserGroup(from: snapshot),
			  let existingIndex = userGroupsList.firstIndex(where: {$0.id == updatedUserGroup.id }) else {
			return
		}
		
		// Update the friend in our local array
		userGroupsList[existingIndex] = updatedUserGroup
		DispatchQueue.main.async {
			self.delegate?.userGroupWasChanged(updatedUserGroup, at: existingIndex)
		}
	}
	
	private func handleChildRemovedUserGroups(_ snapshot: DataSnapshot) {
		guard let groupID = snapshot.key as String?,
			  let existingIndex = userGroupsList.firstIndex(where: {$0.id == groupID}) else {
			return
		}
		
		userGroupsList.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.userGroupWasRemoved(at: existingIndex)
		}
		
		stopObserving()
	}
	
	private func parseUserGroup(from snapshot: DataSnapshot?) -> userGroup? {
		guard let snapshot = snapshot,
			  let groupID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			return nil
		}
		
		let name = data["name"] as? String ?? ""		
		let isMember = data["isAdmin"] as? Bool ?? false
		let adminName = data["adminName"] as? String ?? ""
		let numOfMembers = data["numOfMembers"] as? Int ?? 0
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return userGroup(
			id: groupID,
			name: name,
			isAdmin: isMember, // Fetch from users node
			adminName: adminName,
			numOfMembers: numOfMembers
		)
	}
	
	///Deletes group
	public func userGroupDeleteFromUIView(with group: userGroup, indexPath: IndexPath) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("groups").child(String(describing: group.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func userGroupDelete(with groupID: String) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("groups").child(groupID).setValue(nil) { error, database in
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
		userGroupsList.removeAll()
	}
}
