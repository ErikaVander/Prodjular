//
//  userEvent.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/26/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array storing event ids of all user's events
var userEvents = [userEvent]()

struct userEvent : Equatable {
	var id: String
	var isAttending: Bool
}

protocol userEventServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: userEventService, indexPath: IndexPath)
	func userEventWasAdded(_ event: userEvent)
	func userEventWasChanged(_ event: userEvent, at index: Int)
	func userEventWasRemoved(at index: Int)
	func didReceiveError(_ error: Error)
}

final class userEventService {
	static let shared = userEventService()
	
	var delegate: userEventServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserEvents(for userID: String) {
		stopObserving()
		let userEventsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let addedObserver = userEventsRef.child("events").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedUserEvents(snapshot)
		}
		observers.append(addedObserver)
		
		let changedObserver = userEventsRef.child("events").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChangedUserEvents(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = userEventsRef.child("events").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemovedUserEvents(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleChildAddedUserEvents(_ snapshot: DataSnapshot) {
		guard let event = parseUserEvent(from: snapshot) else { return }
		
		userEvents.append(event)
		
		DispatchQueue.main.async {
			self.delegate?.userEventWasAdded(event)
		}
	}
	
	private func handleChildChangedUserEvents(_ snapshot: DataSnapshot) {
		guard let updatedUserEvent = parseUserEvent(from: snapshot),
			  let existingIndex = userEvents.firstIndex(where: {$0.id == updatedUserEvent.id }) else {
			return
		}
		
		// Update the friend in our local array
		userEvents[existingIndex] = updatedUserEvent
		DispatchQueue.main.async {
			self.delegate?.userEventWasChanged(updatedUserEvent, at: existingIndex)
		}
	}
	
	private func handleChildRemovedUserEvents(_ snapshot: DataSnapshot) {
		guard let eventID = snapshot.key as String?,
			  let existingIndex = userEvents.firstIndex(where: {$0.id == eventID}) else {
			return
		}
		
		userEvents.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.userEventWasRemoved(at: existingIndex)
		}
		
		stopObserving()
	}
	
	private func parseUserEvent(from snapshot: DataSnapshot?) -> userEvent? {
		guard let snapshot = snapshot,
			  let eventID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any],
			  let isAttending = data["isAttending"] as? Bool else {
			return nil
		}
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return userEvent(
			id: eventID,
			isAttending: isAttending // Fetch from users node
		)
	}
	
	///Deletes event
	public func userEventDeleteFromUIView(with event: userEvent, indexPath: IndexPath) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("events").child(String(describing: event.id)).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
	
	public func userEventDelete(with eventID: String) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("events").child(eventID).setValue(nil) { error, database in
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
