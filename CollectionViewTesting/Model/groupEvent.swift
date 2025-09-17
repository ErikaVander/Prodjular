//
//  groupEvent.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/26/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing event ids of all group's events
var groupEvents = [groupEvent]()

struct groupEvent : Equatable {
	var id: String
	var name: String
	var startDate: Date!
	var endDate: Date!
}

protocol groupEventServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: groupEventService, indexPath: IndexPath)
	func groupEventWasAdded(_ event: groupEvent)
	func groupEventWasChanged(_ event: groupEvent, at index: Int)
	func groupEventWasRemoved(at index: Int)
	func didReceiveError(_ error: Error)
}

final class groupEventService {
	static let shared = groupEventService()
	
	var delegate: groupEventServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	var groupEventServiceGroupID: String = ""
	
	func startObservingGroupEvents(for groupID: String) {
		stopObserving()
		groupEventServiceGroupID = groupID
		let groupEventsRef = database.child("groups").child(groupID)
		
		let addedObserver = groupEventsRef.child("events").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedGroupEvents(snapshot)
		}
		observers.append(addedObserver)
		
		let changedObserver = groupEventsRef.child("events").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChangedGroupEvents(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = groupEventsRef.child("events").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemovedGroupEvents(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleChildAddedGroupEvents(_ snapshot: DataSnapshot) {
		print("**added \(snapshot)")
		guard let event = parseGroupEvent(from: snapshot) else {
				print("**ERROR: Could not parse groupEvent")
			return
		}
		
		groupEvents.append(event)
		
		DispatchQueue.main.async {
			self.delegate?.groupEventWasAdded(event)
		}
	}
	
	private func handleChildChangedGroupEvents(_ snapshot: DataSnapshot) {
		guard let updatedGroupEvent = parseGroupEvent(from: snapshot),
			  let existingIndex = groupEvents.firstIndex(where: {$0.id == updatedGroupEvent.id }) else {
			return
		}
		
		// Update the friend in our local array
		groupEvents[existingIndex] = updatedGroupEvent
		DispatchQueue.main.async {
			self.delegate?.groupEventWasChanged(updatedGroupEvent, at: existingIndex)
		}
	}
	
	private func handleChildRemovedGroupEvents(_ snapshot: DataSnapshot) {
		guard let eventID = snapshot.key as String?,
			  let existingIndex = groupEvents.firstIndex(where: {$0.id == eventID}) else {
			return
		}
		
		groupEvents.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.groupEventWasRemoved(at: existingIndex)
		}
		
		stopObserving()
	}
	
	private func parseGroupEvent(from snapshot: DataSnapshot?) -> groupEvent? {
		guard let snapshot = snapshot,
			  let eventID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			print("**ERROR: Could not parse snapshot")
			return nil
		}
		
		let name = data["name"] as? String ?? ""
		let startDate = data["startDate"] as? String ?? "August 18, 2025 at 4:40:00 PM PDT"
		let endDate = data["endDate"] as? String ?? "August 18, 2025 at 4:40:00 PM PDT"
		
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
				
		// For this example, we'll use placeholder data
		// In reality, you'd fetch group profile data here
		return groupEvent(
			id: eventID,
			name: name,
			startDate: dateFormatter.date(from: startDate)!,
			endDate: dateFormatter.date(from: endDate)!
		)
	}
	
	///Deletes event
	public func groupEventDeleteFromUIView(with event: groupEvent, indexPath: IndexPath) {
		database.child("groups").child(groupEventServiceGroupID).child("events").child(String(describing: event.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func groupEventDelete(with eventID: String) {
		database.child("groups").child(groupEventServiceGroupID).child("events").child(eventID).setValue(nil) { error, database in
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
		eventList.removeAll()
	}
}
