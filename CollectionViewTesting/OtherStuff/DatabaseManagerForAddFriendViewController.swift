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
	public func newFriend(with friend: Friend) {
		database.child("users").child(Auth.auth().currentUser!.uid).child("friends").childByAutoId().setValue([
			"userName": friend.userName,
			"email": friend.email,
			"tagName": friend.tagName
		])
		friendList.append(friend)
		print("--Trying to print friendList from the create function", friendList)
	}
	
	func findUser(emailToFind: String, completionSuccess: @escaping (String) -> Void) {
		if (emailToFind == Auth.auth().currentUser?.email) {
			completionSuccess("self")
			return
		}
		
		print("--Here at observeFriends")
		checkDuplicateFriend(emailToFind: emailToFind) {double in
			if(double == "found" ) {
				completionSuccess("double")
				return
			}
			
			let friendRef = Database.database().reference().child("userList")
			
			friendRef.queryOrdered(byChild: "email").queryEqual(toValue: emailToFind).observeSingleEvent(of: .value, with: { snapshot in
				var found = "notFound"
				
				for child in snapshot.children {
					if let childSnapshot = child as? DataSnapshot,
					   let dict = childSnapshot.value as? [String: Any],
					   let emailFound = dict["email"] as? String,
					   let userName = dict["userName"] as? String
					{
					let friend = Friend(id: "", userName: userName, email: emailToFind, tagName: "")
					print("--Found a user: ", friend)
					if(childSnapshot.childrenCount > 0) {
						//						completionSuccess(true)
						found = "found"
					} else {
						//						completionSuccess(false)
						found = "notFound"
					}
					self.newFriend(with: friend)
					}
				}
				completionSuccess(found)
			})
		}
	}
	
	func checkDuplicateFriend(emailToFind: String, completionSuccess: @escaping (String) -> Void) {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("friends")
		friendRef.queryOrdered(byChild: "email").queryEqual(toValue: emailToFind).observeSingleEvent(of: .value, with: { snapshot in
			var found = "notFound"
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot
				{
					if(childSnapshot.childrenCount > 0) {
						found = "found"
					} else {
						found = "notFound"
					}
				}
			}
			completionSuccess(found)
		})
	}
}
