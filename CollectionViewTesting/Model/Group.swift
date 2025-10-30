//
//  Group.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/23/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing user's groups
var groupList = [ProjdularGroup]()

///The definition of a ProdjularEvent.
struct ProjdularGroup {
	var id: String
	let nameOfGroup: String
	var numOfMembers: Int
	var members: [GroupMember]
	var events: [String:Any]
	var description: String?
}

///The definition of a databaseGroup
struct ProjdularGroupDB {
	var id: String
	var adminName: String
	var adminID: String
	var nameOfGroup: String
	var members: [String:[String:String]]
	var pendingMembers: [String:[String:String]]
	var description: String
}

struct GroupMember {
	var id: String
	var isAdmin: Bool
}

protocol groupServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: groupService, indexPath: IndexPath)
	func groupListDidLoad(_groups: [ProjdularGroup])
	func didReceiveError(_ error: Error)
}

protocol groupServiceWriteDelegate: AnyObject {
	func groupWasWritten(_success: Bool)
}

final class groupService {
	static let shared = groupService()
	
	var delegate: groupServiceDelegate?
	var writeDelegate: groupServiceWriteDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingGroups(for groupID: String) {
		stopObserving()
		let groupsRef = database.child("groups").child(groupID)
		
		let valueObserver = groupsRef.observe(.value) {[weak self] snapshot in
			if(!snapshot.exists()) {
				let existingIndex = groupList.firstIndex(where: {$0.id == snapshot.key})
				print("\n\n**groupList before: \(groupList)\n\n")
				groupList.remove(at: existingIndex!)
				print("**groupList: \(groupList)\n\n")
				self!.stopObserving()
			} else {
				self?.handleInitialLoad(snapshot)
			}
		}
		observers.append(valueObserver)
	}
	
	private func handleInitialLoad(_ snapshot: DataSnapshot) {
		if let group = parseGroup(from: snapshot as? DataSnapshot) {
			let existingIndex = groupList.firstIndex(where: {$0.id == snapshot.key})
			if(existingIndex == nil) {
				groupList.append(group)
			} else {
				groupList[existingIndex!] = group
			}
		}
		
		groupList.sort{$0.nameOfGroup < $1.nameOfGroup}
		
		DispatchQueue.main.async {
			self.delegate?.groupListDidLoad(_groups: groupList)
		}
	}
	
	private func parseGroup(from snapshot: DataSnapshot?) -> ProjdularGroup? {
		guard let snapshot = snapshot,
			  let groupID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			return nil
		}
		
		let name = data["name"] as? String ?? ""
		let numOfMembers = data["numOfMembers"] as? Int ?? 0
		let membersDict = data["members"] as? [String: Any] ?? [:]
		let events = data["events"] as? [String:Any] ?? [:]
		let description = data["description"] as? String ?? ""
		
		var members: [GroupMember] = []
		for(userID, value) in membersDict {
			if let memberData = value as? [String: Any],
			   let isAdmin = memberData["isAdmin"] as? Bool {
				members.append(GroupMember(id: userID, isAdmin: isAdmin))
			}
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
		print("\n\n**stop observing called\n\n")
	}
	
	///Writes the new group or updates group into the firebase database.
	public func groupUpdateAndWrite(with group: ProjdularGroupDB, isWriteNotUpdate: Bool) {
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
					 "admin": ["name":group.adminName, "userID": group.adminID],
					 "members": [group.adminID: ["name":group.adminName]],
					 "pendingMembers": group.pendingMembers,
					 "description": group.description] as [String:Any]
		
		//create a list of paths to update
		let childUpdates = ["/groups/\(key)":group]
		
		//update occurs here
		database.updateChildValues(childUpdates) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
				DispatchQueue.main.async {
					self.writeDelegate?.groupWasWritten(_success: false)
				}
			} else {
				print("\n\n**Data saved successfully at \(database.url).\n\n")
				DispatchQueue.main.async {
					self.writeDelegate?.groupWasWritten(_success: true)
				}
			}
		}
	}
	
	///Deletes group
	public func groupDeleteFromUIView(with group: ProjdularGroup, indexPath: IndexPath) {
		database.child("groups").child(String(describing: group.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func groupDelete(with groupID: String) {
		database.child("groups").child(groupID).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
}
