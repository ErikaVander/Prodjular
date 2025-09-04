//
//  Notification.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/23/25.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array of ProjdularEvents
var notificationList = [ProjdularNotification]()

///The definition of a ProdjularEvent.
struct ProjdularNotification : Equatable {
	var id: String
	var header: String
	var content: String
	let timestamp: TimeInterval
}

protocol notificationServiceDelegate: AnyObject {
	func logicForDeletingTableViewCell(_ databaseManager: notificationService, indexPath: IndexPath)
	func notificationWasAdded(_ notification: ProjdularNotification, at index: Int)
	func notificationWasChanged(_ notification: ProjdularNotification, at index: Int)
	func notificationNameWasChanged(_ notification: ProjdularNotification, at index: Int)
	func notificationWasRemoved(at index: Int)
	func notificationListDidLoad(_notifications: [ProjdularNotification])
	func didReceiveError(_ error: Error)
//	func didStopObserving()
}

final class notificationService {
	static let shared = notificationService()
	
	var delegate: notificationServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserNotifications(for userID: String) {
		stopObserving()
		let userNotificationsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let valueObserver = userNotificationsRef.child("notifications").observe(.value) {[weak self] snapshot in
			self?.handleInitialLoad(snapshot)
			print("**Snapshot 1: \(snapshot)")
		}
		observers.append(valueObserver)
		
		let addedObserver = userNotificationsRef.child("notifications").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAdded(snapshot)
		}
		observers.append(addedObserver)
		
		let changedObserver = userNotificationsRef.child("notifications").observe(.childChanged) {[weak self] snapshot in
			self?.handleChildChanged(snapshot)
		}
		observers.append(changedObserver)
		
		let removedObserver = userNotificationsRef.child("notifications").observe(.childRemoved) {[weak self] snapshot in
			self?.handleChildRemoved(snapshot)
		}
		observers.append(removedObserver)
	}
	
	private func handleInitialLoad(_ snapshot: DataSnapshot) {
		var notifications: [ProjdularNotification] = []
		print("**Snapshot: \(snapshot)")
		for child in snapshot.children {
			if let notification = parseNotification(from: child as? DataSnapshot) {
				notifications.append(notification)
				print("**\(notification)")
			}
		}
		
		notifications.sort{$0.timestamp < $1.timestamp}
		notificationList = notifications
		
		DispatchQueue.main.async {
			self.delegate?.notificationListDidLoad(_notifications: notifications)
		}
	}
	
	private func handleChildAdded(_ snapshot: DataSnapshot) {
		guard let notification = parseNotification(from: snapshot) else { return }
		
		let insertIndex = notificationList.firstIndex{$0.timestamp > notification.timestamp} ?? notificationList.count
		notificationList.insert(notification, at: insertIndex)
		
		DispatchQueue.main.async {
			self.delegate?.notificationWasAdded(notification, at: insertIndex)
		}
	}
	
	private func handleChildChanged(_ snapshot: DataSnapshot) {
		guard let updatedNotification = parseNotification(from: snapshot),
			  let existingIndex = notificationList.firstIndex(where: {$0.id == updatedNotification.id }) else {
			return
		}
		
		notificationList[existingIndex] = updatedNotification
		
		DispatchQueue.main.async {
			self.delegate?.notificationWasChanged(updatedNotification, at: existingIndex)
		}
	}
	
	private func handleChildRemoved(_ snapshot: DataSnapshot) {
		guard let notificationID = snapshot.key as String?,
			  let existingIndex = notificationList.firstIndex(where: { $0.id == notificationID }) else {
			return
		}
		
		notificationList.remove(at: existingIndex)
		
		DispatchQueue.main.async {
			self.delegate?.notificationWasRemoved(at: existingIndex)
		}
	}
	
	private func parseNotification(from snapshot: DataSnapshot?) -> ProjdularNotification? {
		guard let snapshot = snapshot,
			  let notificationID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			return nil
		}
		
		let header = data["header"] as? String ?? ""
		let content = data["content"] as? String ?? ""
		let timestamp = data["timestamp"] as? String ?? "946684800.0"
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return ProjdularNotification(
			id: notificationID,
			header: header, // Fetch from users node
			content: content,
			timestamp: Double(timestamp)!
		)
	}
	
	func stopObserving() {
		observers.forEach { handle in
			database.removeObserver(withHandle: handle)
		}
		observers.removeAll()
		notificationList.removeAll()
	}
	
	///Writes the new notification or updates notification into the firebase database.
	public func notificationUpdateAndWrite(with notification: ProjdularNotification, isWriteNotUpdate: Bool) {
		var key: String
		if(isWriteNotUpdate == true) {
			//create a key in .child("notifications") to ensure the key is not a duplicate key. This line of code does not determine where the updates occur.
			guard let newKey = database.child("notifications").childByAutoId().key else {return}
			
			key = newKey
		} else {
			key = notification.id
		}
		//create a notification object that will be written to the database
		let notification = ["header": notification.header,
							"content": notification.content,
							"timestamp": notification.timestamp,
		] as [String:Any]
		
		//create a list of paths to update
		let childUpdates = ["/notifications/\(key)": notification]
		
		//update occurs here
		database.updateChildValues(childUpdates) { error, database in
			if let error = error {
				print("Data could not be saved: \(error).")
			} else {
				print("Data saved successfully at \(database.url).")
			}
		}
	}
	
	///Deletes group
	public func notificationDelete(with notification: ProjdularNotification, indexPath: IndexPath) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("notifications").child(String(describing: notification.id)).setValue(nil) { error, database in
			if let error = error {
				print("**Data could not be saved: \(error).")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("**Data saved successfully at \(database.url)")
			}
		}
	}
}
