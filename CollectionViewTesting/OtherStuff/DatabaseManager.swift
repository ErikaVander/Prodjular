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

final class DatabaseManager {
	static let shared = DatabaseManager()
	
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
			"date": dateformat.string(from: event.date),
			"tagName": event.tagName,
			"tagColor": event.tagColor,
		])
		print("--newDateTwo: \(String(describing: event.date))--")
		print("--selectedDate: \(String(describing: selectedDate))")
		selectedDate = event.date
		eventList.append(event)
	}
	
	///Deletes event
	public func deleteEvent(with event: ProjdularEvent) {
		self.database.ref.child("events/\(String(describing: event.id))").removeValue()
	}
}

///The definition of a ProjdularUser.
struct ProjdularUser : Equatable {
	let email: String
	let userID: String
}
