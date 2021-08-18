//
//  DatabaseManager.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/13/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

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
		database.child("events").childByAutoId().setValue([
			"name": event.nameOfEvent,
			"date": dateformat.string(from: event.date),
			"tag": event.tag,
			"userID": event.userID
		])
		print("--\(DateFormatter().string(from: event.date))--")
		print("--\(String(describing: event.date))--")
		eventList.append(event)
	}
}

///The definition of a ProjdularUser.
struct ProjdularUser {
	let email: String
	let userID: String
}

///The definition of a ProdjularEvent.
struct ProjdularEvent {
	let nameOfEvent: String
	let userID: String
	var date: Date!
	let tag: String
}
