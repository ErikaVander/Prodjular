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

protocol DatabaseManagerDelegateForFriendsViewController {
	func logicForDeletingFriendTableViewCell(_ databaseManager: DatabaseManagerForFriendViewController, indexPath: IndexPath)
}

final class DatabaseManagerForFriendViewController {
	static let shared = DatabaseManagerForFriendViewController()
	var delegate: DatabaseManagerDelegateForFriendsViewController?
	
	private let database = Database.database().reference()
	
	///Writes a new Friend into the firebase database.
	func newFriend(with friend: Friend, location: String) {
		database.child("users").child(location).child("friends").child(friend.id).setValue([
			"userName": friend.userName,
			"email": friend.email,
			"tagName": friend.tagName,
			"status": friend.status,
			"profilePhotoURL": friend.profilePhotoURL,
//			"ProfilePhotoLastUpdated": friend.ProfilePhotoLastUpdated
		])
		//friendList.append(friend)
//		print("--Trying to print friendList from the create function", friendList)
	}
	
	///Updates friends in firebase database.
	func updateFriend(with friend: Friend, user: String, location: String) {
		let data = [
			"userName": friend.userName,
			"email": friend.email,
			"tagName": friend.tagName,
			"status": friend.status,
			"profilePhotoURL": friend.profilePhotoURL,
//			"ProfilePhotoLastUpdated": friend.profilePhotoURL
		]
//		print("--user: ", user, "location: ", location)
		database.child("users").child(user).child("friends").child(location).updateChildValues(data)
		
	}
	
	func deleteFriend(friend: Friend, completionSuccess: @escaping (String) -> Void) {
		self.database.ref.child("users").child(Auth.auth().currentUser!.uid).child("friends").child(String(describing: friend.id)).setValue(nil) {
			(error: Error?, ref: DatabaseReference) in
			if let error = error {
				print("**Data could not be saved: \(error).")
				completionSuccess("fail")
			} else {
				//print("--Trying to print friendList", friendList)
				//				print("--Just triend to call the function")
				print("**Data saved successfully!")
				completionSuccess("success")
			}
		}
	}
	
	func deleteMyselfAsFriend(friend: Friend, completionSuccess: @escaping(String) -> Void) {
		checkDuplicateFriend(emailToFind: friend.email, idToUse: Auth.auth().currentUser!.uid, function: "deleteFriend") { id in
			self.database.ref.child("users").child(id).child("friends").child(String(describing: Auth.auth().currentUser!.uid)).setValue(nil) {
				(error: Error?, ref: DatabaseReference) in
				if let error = error {
					print("**Data could not be saved: \(error).")
					completionSuccess("fail")
				} else {
					//print("--Trying to print friendList", friendList)
					//				print("--Just triend to call the function")
					print("**Data saved successfully!")
					completionSuccess("success")
				}
				
			}
		}
	}
	
	func findAndAddFriend(emailToFind: String, completionSuccess: @escaping (String) -> Void) {
		if (emailToFind == Auth.auth().currentUser?.email) {
			completionSuccess("self")
			return
		}
		
		checkDuplicateFriend(emailToFind: emailToFind, idToUse: Auth.auth().currentUser!.uid, function: "findUser") {double in
			if(double == "found") {
				completionSuccess("double")
				return
			}
			
			let friendRef = Database.database().reference().child("userList")
			friendRef.queryOrdered(byChild: "email").queryEqual(toValue: emailToFind).observeSingleEvent(of: .value, with: { snapshot in
				var found = "notFound"
				for child in snapshot.children {
					if let childSnapshot = child as? DataSnapshot,
					   let id = childSnapshot.key as? String,
					   let dict = childSnapshot.value as? [String: Any],
					   let emailFound = dict["email"] as? String,
					   let userName = dict["userName"] as? String,
					   let photoURL = dict["profilePhotoURL"] as? String
					{
//					if(emailFound == emailToFind) {
						if(double != "found" && double != "notFound") {
							let friend = Friend(id: id, userName: userName, email: emailToFind, tagName: "", status: "accepted", profilePhotoURL: photoURL)
							let myself = Friend(id: Auth.auth().currentUser!.uid, userName: currentUser!.userName, email: Auth.auth().currentUser!.email!, tagName: "", status: "accepted", profilePhotoURL: currentUser!.profilePhotoURL)
							self.updateFriend(with: friend, user: Auth.auth().currentUser!.uid, location: double)
							self.checkDuplicateFriend(emailToFind: Auth.auth().currentUser!.email!, idToUse: id, function: "findUser") { idFound in
								self.updateFriend(with: myself, user: id, location: idFound)
							}
//							print("--Found a user: ", friend)
						} else {
							let myfriend = Friend(id: id, userName: userName, email: emailToFind, tagName: "", status: "sent", profilePhotoURL: photoURL)
							let friend = Friend(id: currentUser!.userID, userName: currentUser!.userName, email: currentUser!.email, tagName: "", status: "received", profilePhotoURL: currentUser!.profilePhotoURL)
							//print("--Found a user: ", friend)
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
						//print("--gotToHere")
//					}
						//self.sendFriendRequest(emailToFind: currentUser.email, id: id)
					}
				}
				//print("--gotToHere2: ", found)
				completionSuccess(found)
			}, withCancel: {(err) in
				print("**error: ", err)
			})
		}
	}
	
	func checkDuplicateFriend(emailToFind: String, idToUse: String, function: String, completionSuccess: @escaping (String) -> Void) {
		let friendRef = Database.database().reference().child("users").child(idToUse).child("friends")
		friendRef.queryOrdered(byChild: "email").queryEqual(toValue: emailToFind).observeSingleEvent(of: .value, with: { snapshot in
			var found = "notFound"
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let status = dict["status"] as? String,
				   let email = dict["email"] as? String,
				   let photoURL = dict["profilePhotoURL"] as? String
				{
					if(function == "findUser") {
						if(childSnapshot.childrenCount > 0) {
							if(status == "received" || status == "sent"){
								found = id
							} else {
								found = "found"
							}
						} else {
							found = "notFound"
						}
						completionSuccess(found)
						return
					} else if(function == "deleteFriend") {
						if(childSnapshot.childrenCount > 0) {
							found = id
						} else {
							print("**Was not able to find a user to delete.")
						}
//						print("--found: ", found)
						completionSuccess(found)
						return
					}
				}
			}
			completionSuccess(found)
		})
		//print("--nothingFound: ", emailToFind, " ", idToUse)
	}
	
	func acceptFriendRequest(friend: Friend) {
		let myself = Friend(id: Auth.auth().currentUser!.uid, userName: currentUser!.userName, email: Auth.auth().currentUser!.email!, tagName: "", status: "accepted", profilePhotoURL: currentUser!.profilePhotoURL)
		let friendAccepted = Friend(id: friend.id, userName: friend.userName, email: friend.email, tagName: "", status: "accepted", profilePhotoURL: friend.profilePhotoURL)
		
		//		checkDuplicateFriend(emailToFind: Auth.auth().currentUser!.email!, idToUse: friend.id) { idFound in
		self.updateFriend(with: myself, user: friend.id, location: Auth.auth().currentUser!.uid)
		//		}
		//		checkDuplicateFriend(emailToFind: friend.email, idToUse: Auth.auth().currentUser!.uid) { idFound in
		self.updateFriend(with: friendAccepted, user: Auth.auth().currentUser!.uid, location: friend.id)
		//		}
	}
	
	func declineFriendRequest(friend: Friend) {
		self.deleteFriend(friend: friend) { completed in
			print("**declining friend request failed on deleteFriend")
		}
		self.deleteMyselfAsFriend(friend: friend) { completed in
			print("**declining friend request failed on deleteMyselfAsFriend")
		}
	}
	
	public func deleteFriendFromCell(with friend: Friend, indexPath: IndexPath) {
		/*self.database.ref.child("users/\(Auth.auth().currentUser!.uid)/events/\(String(describing: event.id))").removeValue() {_,_ in
		 print("--LogicForDeletingTableViewCell about to be called")
		 self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
		 print("--at the end")
		 }*/
		checkDuplicateFriend(emailToFind: friend.email, idToUse: Auth.auth().currentUser!.uid, function: "deleteFriend") { id in
			self.deleteFriend(friend: friend) { completed in
				if(completed == "success") {
					self.delegate?.logicForDeletingFriendTableViewCell(self, indexPath: indexPath)
				}
			}
			self.deleteMyselfAsFriend(friend: friend) { completed in
			}
		}
	}
	
	func fetchFriendsData(completionSuccess: @escaping (String) -> Void) {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("friends")
		
		friendRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
			//			var tempFriendList = [Friend]()
			//			var tempFriendReqSent = [Friend]()
			//			var tempFriendReqReceived = [Friend]()
			
			var tempFriendList = [Friend]()
			var tempFriendReqReceived = [Friend]()
			var tempFriendReqSent = [Friend]()
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let userName = dict["userName"] as? String,
				   let email = dict["email"] as? String,
				   let tagName = dict["tagName"] as? String,
				   let status = dict["status"] as? String,
				   let profilePhotoURL = dict["profilePhotoURL"] as? String
				{
				let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status, profilePhotoURL: profilePhotoURL)
				print("--friend got from database: ", status)
				if(status == "accepted") {
					print("--here")
					tempFriendList.append(friend)
				} else if(status == "sent") {
					tempFriendReqSent.append(friend)
				} else if(status == "received") {
					tempFriendReqReceived.append(friend)
				}
				}
			}
			friendList = tempFriendList
			friendReqReceived = tempFriendReqReceived
			friendReqSent = tempFriendReqSent
			
			var allFriendsForProfilePhotoLoad = [Friend]()
			allFriendsForProfilePhotoLoad.append(contentsOf: friendList)
			allFriendsForProfilePhotoLoad.append(contentsOf: friendReqSent)
			allFriendsForProfilePhotoLoad.append(contentsOf: friendReqReceived)
			self?.getProfilePhotos(photosToLoad: allFriendsForProfilePhotoLoad)
			
			print("--friendList: ", friendList)
			print("--friendReqReceived: ", friendReqReceived)
			print("--friendReqSent: ", friendReqSent)
		})
	}
	
	func getProfilePhotos(photosToLoad: [Friend]) {
		for friend in photosToLoad {
			DatabaseManagerForSignUpandLogin.shared.loadProfilePhotoWithCaching(for: friend.id) { result in
				switch result {
				case .success(let image):
					friendProfilePhotos[friend.id] = image
					if(photosToLoad.last == friend) {
						print("--here2")
					}
				case .failure(let error):
					print("**", error)
				} 
			}
		}
	}
	
//	func sendFriendRequest(emailToFind: String, id: String) {
//		//newFriend(with: Friend(id: currentUser.userID, userName: currentUser.userName, email: currentUser.email, tagName: "", status: "not approved"), location: id)
//	}
}
