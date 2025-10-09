//
//  groupPendingEvent.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/17/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing event ids of all group's events
var groupPendingEventList = [groupPendingEvent]()

struct groupPendingEvent : Equatable, Hashable {
	var id: String
	var name: String
	var startDate: Date!
	var toSubmitTimesUsers: [String]
}

protocol groupPendingEventServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: groupPendingEventService, indexPath: IndexPath)
	func groupPendingEventWasAdded(_ event: groupPendingEvent)
	func groupPendingEventWasChanged(_ event: groupPendingEvent, at index: Int)
	func groupPendingEventWasRemoved(at index: Int)
	func didReceiveError(_ error: Error)
}

final class groupPendingEventService {
	static let shared = groupPendingEventService()
	
	var delegate: groupPendingEventServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	var groupPendingEventServiceGroupID: String = ""
	
	func startObservingGroupPendingEvents(for groupID: String) {
		stopObserving()
		groupPendingEventServiceGroupID = groupID
		let groupPendingEventsRef = database.child("groups").child(groupID)
		
		let addedObserver = groupPendingEventsRef.child("pendingEvents").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedGroupPendingEvents(snapshot)
		}
		observers.append(addedObserver)
		
		let changedObserver = groupPendingEventsRef.child("pendingEvents").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChangedGroupPendingEvents(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = groupPendingEventsRef.child("pendingEvents").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemovedGroupPendingEvents(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleChildAddedGroupPendingEvents(_ snapshot: DataSnapshot) {
		print("**added \(snapshot)")
		guard let event = parseGroupPendingEvent(from: snapshot) else {
			print("**ERROR: Could not parse groupPendingEvent")
			return
		}
		
		groupPendingEventList.append(event)
		print("**userIDs: \(event.toSubmitTimesUsers)")
		
		DispatchQueue.main.async {
			self.delegate?.groupPendingEventWasAdded(event)
		}
	}
	
	private func handleChildChangedGroupPendingEvents(_ snapshot: DataSnapshot) {
		guard let updatedGroupPendingEvent = parseGroupPendingEvent(from: snapshot),
			  let existingIndex = groupPendingEventList.firstIndex(where: {$0.id == updatedGroupPendingEvent.id }) else {
			return
		}
		
		// Update the friend in our local array
		groupPendingEventList[existingIndex] = updatedGroupPendingEvent
		DispatchQueue.main.async {
			self.delegate?.groupPendingEventWasChanged(updatedGroupPendingEvent, at: existingIndex)
		}
	}
	
	private func handleChildRemovedGroupPendingEvents(_ snapshot: DataSnapshot) {
		guard let eventID = snapshot.key as String?,
			  let existingIndex = groupPendingEventList.firstIndex(where: {$0.id == eventID}) else {
			return
		}
		
		groupPendingEventList.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.groupPendingEventWasRemoved(at: existingIndex)
		}
		
		stopObserving()
	}
	
	private func parseGroupPendingEvent(from snapshot: DataSnapshot?) -> groupPendingEvent? {
		let dateFormatter = DateFormatter()
		guard let snapshot = snapshot,
			  let eventID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			print("**ERROR: Could not parse snapshot")
			return nil
		}
		
		let name = data["name"] as? String ?? ""
		let startDate = data["startDate"] as? String ?? "August 18, 2025 at 4:40:00 PM PDT"
		let endDate = data["endDate"] as? String ?? "August 18, 2025 at 4:40:00 PM PDT"
		let toSubmitTimesUsers = data["toSubmitTimesUsers"] as? [String:String] ?? [:]
		
		print("**toSubmitTimes: \(toSubmitTimesUsers)")
		
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch group profile data here
		return groupPendingEvent(
			id: eventID,
			name: name,
			startDate: dateFormatter.date(from: startDate)!,
			toSubmitTimesUsers: Array(toSubmitTimesUsers.values)
		)
	}
	
	///Deletes event
	public func groupPendingEventDeleteFromUIView(with event: groupPendingEvent, indexPath: IndexPath) {
		database.child("groups").child(groupPendingEventServiceGroupID).child("events").child(String(describing: event.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func groupPendingEventDelete(with eventID: String) {
		database.child("groups").child(groupPendingEventServiceGroupID).child("events").child(eventID).setValue(nil) { error, database in
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
		groupPendingEventList.removeAll()
	}
}
