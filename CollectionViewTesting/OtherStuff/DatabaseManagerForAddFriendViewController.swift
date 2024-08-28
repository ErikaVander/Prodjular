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
			"id": friend.id,
			"name": friend.name,
			"email": friend.email,
			"tagName": friend.tagName
		])
		friendList.append(friend)
		print("--Trying to print friendList from the create function", friendList)
	}
	
	func findUser(emailToFind: String) {
		print("--Here at observeFriends")
		let friendRef = Database.database().reference().child("userList").child(Auth.auth().currentUser!.uid)  .child(emailToFind)
		
		friendRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userID = dict["userID"] as? String
				{
					print("--before the if statement")
					if(id == emailToFind) {
						let friend = Friend(id: userID, name: "", email: emailToFind, tagName: "")
						print("Found a user: ", friend)
						
						self.newFriend(with: friend)
					} else {
						print("--Did not find any users")
					}
				}
			}
		})
		
	}
}
