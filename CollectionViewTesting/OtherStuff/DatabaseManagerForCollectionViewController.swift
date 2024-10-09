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

protocol DatabaseManagerDelegateForCollectionViewController {
	func logicForDeletingTableViewCell(_ databaseManager: DatabaseManagerForCollectionViewController, indexPath: IndexPath)
}

final class DatabaseManagerForCollectionViewController {
	static let shared = DatabaseManagerForCollectionViewController()
	
	var delegate: DatabaseManagerDelegateForCollectionViewController?
	
	private let database = Database.database().reference()
	
	///Writes the new user into the firebase database.
	public func insertUser(with user: ProjdularUser) {
		print("**tryingto create a new user: ", user.userID)
		database.child("userList").child(Auth.auth().currentUser!.uid).setValue([
			"email": user.email,
			"userName": user.userName
			//"userID": Auth.auth().currentUser!.uid
		])
	}
	
	func findUser(emailToFind: String, completionSuccess: @escaping (ProjdularUser) -> Void) {
		var user = ProjdularUser(email: "", userID: "", userName: "")
		let friendRef = Database.database().reference().child("userList")
		
		friendRef.queryOrdered(byChild: "email").observeSingleEvent(of: .value, with: { snapshot in
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let emailFound = dict["email"] as? String,
				   let userName = dict["userName"] as? String
				{
					if(emailToFind == emailFound) {
						user = ProjdularUser(email: emailFound, userID: id, userName: userName)
//						print("--user1: ", user)
						completionSuccess(user)
					}
				}
			}
		}, withCancel: {(err) in
			print("**error: ", err)
		})
	}
	
//	public func newUser(with user: ProjdularUser) {
//		database.child("userList").childByAutoId().setValue([
//			"email": user.email,
//			"userID": user.userID
//		])
//		print(user.email, user.userID)
//	}
	
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
				print("**Data could not be saved: \(error).")
			} else {
				self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
				print("**Data saved successfully!")
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
