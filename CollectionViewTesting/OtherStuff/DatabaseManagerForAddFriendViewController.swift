//
//  DatabaseManagerForAddFriendViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

final class DatabaseManagerForAddFriendsViewController {
	static let shared = DatabaseManagerForAddFriendsViewController()
	
	private let database = Database.database().reference()
	
	///Writes a new Friend into the firebase database.
	public func newFriend(with friend: Friend, location: String) {
		database.child("users").child(location).child("friends").childByAutoId().setValue([
			"userName": friend.userName,
			"email": friend.email,
			"tagName": friend.tagName,
			"status": friend.status
		])
		//friendList.append(friend)
//		print("--Trying to print friendList from the create function", friendList)
	}
	
	///Updates friends in firebase database.
	public func updateFriend(with friend: Friend, user: String, location: String) {
		let data = [
			"userName": friend.userName,
			"email": friend.email,
			"tagName": friend.tagName,
			"status": friend.status,
		]
		database.child("users").child(user).child("friends").child(location).updateChildValues(data)
		
	}
	
	func findUser(emailToFind: String, completionSuccess: @escaping (String) -> Void) {
		if (emailToFind == Auth.auth().currentUser?.email) {
			completionSuccess("self")
			return
		}
		
		checkDuplicateFriend(emailToFind: emailToFind, idToUse: Auth.auth().currentUser!.uid) {double in
			if(double == "found") {
				completionSuccess("double")
				return
			}
			
			let friendRef = Database.database().reference().child("userList")
			
			friendRef.queryOrdered(byChild: "email").observeSingleEvent(of: .value, with: { snapshot in
				var found = "notFound"
				
				for child in snapshot.children {
					if let childSnapshot = child as? DataSnapshot,
					   let id = childSnapshot.key as? String,
					   let dict = childSnapshot.value as? [String: Any],
					   let emailFound = dict["email"] as? String,
					   let userName = dict["userName"] as? String
					{
					if(emailFound == emailToFind) {
						if(double != "found" && double != "notFound") {
							let friend = Friend(id: id, userName: userName, email: emailToFind, tagName: "", status: "accepted")
							let myself = Friend(id: Auth.auth().currentUser!.uid, userName: currentUser!.userName, email: Auth.auth().currentUser!.email!, tagName: "", status: "accepted")
							self.updateFriend(with: friend, user: Auth.auth().currentUser!.uid, location: double)
							print("emailToFind: ", Auth.auth().currentUser!.email!)
							
							print("-----id: ", id)
							self.checkDuplicateFriend(emailToFind: Auth.auth().currentUser!.email!, idToUse: id) { idFound in
								self.updateFriend(with: myself, user: id, location: idFound)
								print("--was able to get to here")
							}
//							print("--Found a user: ", friend)
						} else {
							let myfriend = Friend(id: id, userName: userName, email: emailToFind, tagName: "", status: "sent")
							let friend = Friend(id: currentUser!.userID, userName: currentUser!.userName, email: currentUser!.email, tagName: "", status: "received")
//							print("--Found a user: ", friend)
							self.newFriend(with: myfriend, location: Auth.auth().currentUser!.uid)
							self.newFriend(with: friend, location: id)
						}
						if(childSnapshot.childrenCount > 0) {
							//						completionSuccess(true)
							found = "found"
						} else {
							//						completionSuccess(false)
							found = "notFound"
						}
					}
						//self.sendFriendRequest(emailToFind: currentUser.email, id: id)
					}
				}
				completionSuccess(found)
			}, withCancel: {(err) in
				print("--error: ", err)
			})
		}
	}
	
	func checkDuplicateFriend(emailToFind: String, idToUse: String, completionSuccess: @escaping (String) -> Void) {
		let friendRef = Database.database().reference().child("users").child(idToUse).child("friends")
		friendRef.queryOrdered(byChild: "email").observeSingleEvent(of: .value, with: { snapshot in
			var found = "notFound"
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let status = dict["status"] as? String,
				   let email = dict["email"] as? String
				{
					print("--found: ", found, " ", id, " ", status)
					if(emailToFind == email) {
						if(childSnapshot.childrenCount > 0) {
							if(status == "received" || status == "sent"){
								found = id
							} else {
								found = "found"
							}
						} else {
							found = "notFound"
						}
						print("--found: ", found)
						completionSuccess(found)
						return
					}
				}
			}
		})
		print("--nothingFound: ", emailToFind, " ", idToUse)
		
	}
	
	func acceptFriendRequest() {
		
	}
	
	func sendFriendRequest(emailToFind: String, id: String) {
		//newFriend(with: Friend(id: currentUser.userID, userName: currentUser.userName, email: currentUser.email, tagName: "", status: "not approved"), location: id)
	}
}
