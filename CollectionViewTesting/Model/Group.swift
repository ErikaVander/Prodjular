//
//  Group.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/23/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array of ProjdularEvents
var groupList = [ProjdularGroup]()

///The definition of a ProdjularEvent.
struct ProjdularGroup : Equatable {
	var id: String
	let nameOfGroup: String
	var numOfMembers: Int
	var members: [ProjdularUser]
	var events: [ProjdularEvent]
	var description: String?
}

protocol groupServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: groupService, indexPath: IndexPath)
	func groupWasAdded(_ group: ProjdularGroup, at index: Int)
	func groupWasChanged(_ group: ProjdularGroup, at index: Int)
	func groupNameWasChanged(_ group: ProjdularGroup, at index: Int)
	func groupWasRemoved(at index: Int)
	func groupListDidLoad(_groups: [ProjdularGroup])
	func didReceiveError(_ error: Error)
}

final class groupService {
	static let shared = groupService()
	
	var delegate: groupServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserGroups(for userID: String) {
		stopObserving()
		let userGroupsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let valueObserver = userGroupsRef.child("groups").observe(.value) {[weak self] snapshot in
			self?.handleInitialLoad(snapshot)
		}
		observers.append(valueObserver)
		
		let addedObserver = userGroupsRef.observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAdded(snapshot)
		}
		observers.append(addedObserver)
		
		let changedObserver = userGroupsRef.observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChanged(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = userGroupsRef.observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemoved(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleInitialLoad(_ snapshot: DataSnapshot) {
		var groups: [ProjdularGroup] = []
		
		for child in snapshot.children {
			if let group = parseGroup(from: child as? DataSnapshot) {
				groups.append(group)
			}
		}
		
		groups.sort{$0.nameOfGroup < $1.nameOfGroup}
		groupList = groups
		
		DispatchQueue.main.async {
			self.delegate?.groupListDidLoad(_groups: groups)
		}
	}
	
	private func handleChildAdded(_ snapshot: DataSnapshot) {
		guard let group = parseGroup(from: snapshot) else { return }

		let insertIndex = groupList.firstIndex{$0.nameOfGroup > group.nameOfGroup} ?? groupList.count
		groupList.insert(group, at: insertIndex)
		
		DispatchQueue.main.async {
			self.delegate?.groupWasAdded(group, at: insertIndex)
		}
		
		let notification = ProjdularNotification(id: "", header: "New group invite", content: "You have been invited to join \(group.nameOfGroup)", timestamp: Date().timeIntervalSince1970)
		notificationService.shared.notificationUpdateAndWrite(with: notification, isWriteNotUpdate: true)
	}
	
	private func handleChildChanged(_ snapshot: DataSnapshot) {
		guard let updatedGroup = parseGroup(from: snapshot),
			  let existingIndex = groupList.firstIndex(where: {$0.id == updatedGroup.id }) else {
			return
		}
		
		if(updatedGroup.nameOfGroup != groupList[existingIndex].nameOfGroup) {
			let index = groupList.firstIndex{$0.nameOfGroup > updatedGroup.nameOfGroup} ?? groupList.count
			groupList.remove(at: existingIndex)
			// Update the friend in our local array
			groupList.insert(updatedGroup, at: index)
			DispatchQueue.main.async {
				self.delegate?.groupNameWasChanged(updatedGroup, at: existingIndex)
			}
		} else {
			// Update the friend in our local array
			groupList[existingIndex] = updatedGroup
			DispatchQueue.main.async {
				self.delegate?.groupWasChanged(updatedGroup, at: existingIndex)
			}
		}
	}
	
	private func handleChildRemoved(_ snapshot: DataSnapshot) {
		guard let groupID = snapshot.key as String?,
			  let existingIndex = groupList.firstIndex(where: { $0.id == groupID }) else {
			return
		}
		
		groupList.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.groupWasRemoved(at: existingIndex)
		}
		
		let notification = ProjdularNotification(id: "", header: "\(groupList[existingIndex].nameOfGroup) deleted", content: "This group has been dissolved by the Admin.", timestamp: Date().timeIntervalSince1970)
		notificationService.shared.notificationUpdateAndWrite(with: notification, isWriteNotUpdate: true)
	}
	
	private func parseGroup(from snapshot: DataSnapshot?) -> ProjdularGroup? {
		guard let snapshot = snapshot,
			  let groupID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any],
			  let name = data["name"] as? String,
			  let numOfMembers = data["numOfMembers"] as? Int,
			  let members = data["members"] as? [ProjdularUser],
			  let events = data["events"] as? [ProjdularEvent],
			  let description = data["description"] as? String else {
			return nil
		}
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return ProjdularGroup(
			id: groupID,
			nameOfGroup: name, // Fetch from users node
			numOfMembers: numOfMembers,
			members: members,
			events: events,
			description: description
		)
	}
	
	func stopObserving() {
		observers.forEach { handle in
			database.removeObserver(withHandle: handle)
		}
		observers.removeAll()
		groupList.removeAll()
	}
	
	///Writes the new group or updates group into the firebase database.
	public func groupUpdateAndWrite(with group: ProjdularGroup, isWriteNotUpdate: Bool) {
		var key: String
		if(isWriteNotUpdate == true) {
			//create a key in .child("groups") to ensure the key is not a duplicate key. This line of code does not determine where the updates occur.
			guard let newKey = database.child("groups").childByAutoId().key else {return}
			
			key = newKey
		} else {
			key = group.id
		}
		//create a group object that will be written to the database
		let group = ["name": group.nameOfGroup,
					 "numOfMembers": group.numOfMembers,
					 "members": group.members,
					 "events": group.events,
					 "description": group.description] as [String:Any]
		
		//create a list of paths to update
		let childUpdates = ["/groups/\(key)":group,
							"/users/\(Auth.auth().currentUser!.uid)/groups/\(key)":group]
		
		//update occurs here
		database.updateChildValues(childUpdates) { error, database in
			if let error = error {
				print("Data could not be saved: \(error).")
			} else {
				print("Data saved successfully at \(database.url).")
			}
		}
	}
	
	func observeUsersGroups() {
		database.child("users").child(Auth.auth().currentUser!.uid).child("groups")
	}
}
