//
//  DatabaseManager.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/13/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

protocol DatabaseManagerDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: DatabaseManager, indexPath: IndexPath)
}

final class DatabaseManager {
	static let shared = DatabaseManager()
	
	var delegate: DatabaseManagerDelegate?
	
	private let database = Database.database().reference()
	
	///Writes the new user into the firebase database.
	public func insertUser(with user: ProjdularUser) {
		database.child("users").child(user.userID).setValue([
			"email": user.email
		])
	}
	
	///Writes the new event into the firebase database.
	public func newEvent(with event: ProjdularEvent) {
		let dateformat = DateFormatter()
		dateformat.dateStyle = .long
		dateformat.timeStyle = .long
		database.child("users").child(Auth.auth().currentUser!.uid).child("events").childByAutoId().setValue([
			"name": event.nameOfEvent,
			"startDate": dateformat.string(from: event.startDate),
			"endDate": dateformat.string(from: event.endDate),
			"tagName": event.tagName,
			"tagColor": event.tagColor,
			"description": event.description
		])
		selectedDate = event.startDate
		eventList.append(event)
	}
	
	///Deletes event
	public func deleteEvent(with event: ProjdularEvent, indexPath: IndexPath) {
		/*self.database.ref.child("users/\(Auth.auth().currentUser!.uid)/events/\(String(describing: event.id))").removeValue() {_,_ in
			print("--LogicForDeletingTableViewCell about to be called")
			self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
			print("--at the end")
		}*/
		self.database.ref.child("users").child(Auth.auth().currentUser!.uid).child("events").child(String(describing: event.id)).setValue(nil) {
			(error: Error?, ref: DatabaseReference) in
			if let error = error {
				print("--Data could not be saved: \(error).")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("--Data saved successfully!")
			}

		}
	}
	
	///updates user settings on firebase
	public func updateUserSettings(settings: SettingsHelper) {
		self.database.child("users").child(Auth.auth().currentUser!.uid).child("userSettings").setValue([
			"autoBreakLength": settings.autoBreakLength,
			"autoPrepLength": settings.autoPrepLength,
			"addNewDirection": settings.addNewDirection,
			"autoWorkDays": settings.autoWorkDays
		])
	}
}

///The definition of a ProjdularUser.
struct ProjdularUser : Equatable {
	let email: String
	let userID: String
}
