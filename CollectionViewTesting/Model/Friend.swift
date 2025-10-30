//
//  Friend.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

///An array of friends
var friendList = [Friend]()
var friendReqReceived = [Friend]()
var friendReqSent = [Friend]()

///The definition of a Friend.
struct Friend : Equatable, Hashable {
	let id: String
	var userName: String
	let email: String
	var tagName: String?
	var status: String
	var profilePhotoURL: String
//	var ProfilePhotoLastUpdated: String
}

protocol friendServiceDelegate {
	func logicForDeletingFriendTableViewCell(_ databaseManager: friendService, indexPath: IndexPath)
	func friendWasFetched()
}

final class friendService {
	static let shared = friendService()
	var delegate: friendServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
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
	
	func startObservingFriends(for userID: String) {
		stopObserving()
		let userEventsRef = database.child("users").child(Auth.auth().currentUser!.uid)
		
		let addedObserver = userEventsRef.child("friends").observe(.childAdded) {[weak self] snapshot in
			self?.handleChildAddedFriend(snapshot)
		}
		observers.append(addedObserver)
		
		//		let changedObserver = userEventsRef.child("friends").observe(.childChanged) {[weak self] snapshot in
		//			self?.handleChildChangedFriend(snapshot)
		//		}
		//		observers.append(changedObserver)
		//		
		//		let removedObserver = userEventsRef.child("friends").observe(.childRemoved) {[weak self] snapshot in
		//			self?.handleChildRemovedFriend(snapshot)
		//		}
		//		observers.append(removedObserver)
	}
	
	private func handleChildAddedFriend(_ snapshot: DataSnapshot) {
		guard let friend = parseFriend(from: snapshot) else { return }
		
		if(friend.status == "accepted") {
			print("--here \(friend)")
			friendList.append(friend)
		} else if(friend.status == "sent") {
			friendReqSent.append(friend)
		} else if(friend.status == "received") {
			friendReqReceived.append(friend)
		}
		
		print("**Inside handle: \(friendList)")
		
		DispatchQueue.main.async {
			self.delegate?.friendWasFetched()
		}
	}
	
	//	private func handleChildRemovedUserEvents(_ snapshot: DataSnapshot) {
	//		guard let friendID = snapshot.key as String?,
	//			  let existingIndex = friendList.firstIndex(where: {$0.id == friendID}) else {
	//			return
	//		}
	//		
	//		friendList.remove(at: existingIndex)
	//		
	//		DispatchQueue.main.async {
	//			self.delegate?.(at: existingIndex)
	//		}
	//		
	//		stopObserving()
	//	}
	
	private func parseFriend(from snapshot: DataSnapshot?) -> Friend? {
		guard let snapshot = snapshot,
			  let id = snapshot.key as? String,
			  let data = snapshot.value as? [String: Any] else {
			return nil
		}
		
		let userName = data["userName"] as? String ?? ""
		let email = data["email"] as? String ?? ""
		let tagName = data["tagName"] as? String ?? ""
		let status = data["status"] as? String ?? ""
		let profilePhotoURL = data["profilePhotoURL"] as? String ?? ""
		
		// For this example, we'll use placeholder data
		// In reality, you'd fetch user profile data here
		return Friend(
			id: id,
			userName: userName,
			email: email,
			tagName: tagName,
			status: status,
			profilePhotoURL: profilePhotoURL// Fetch from users node
		)
	}
	
	//	func fetchFriendsData(completionSuccess: @escaping (String) -> Void) {
	//		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("friends")
	//		
	//		friendRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
	//			//			var tempFriendList = [Friend]()
	//			//			var tempFriendReqSent = [Friend]()
	//			//			var tempFriendReqReceived = [Friend]()
	//			
	//			var tempFriendList = [Friend]()
	//			var tempFriendReqReceived = [Friend]()
	//			var tempFriendReqSent = [Friend]()
	//			
	//			for child in snapshot.children {
	//				if let childSnapshot = child as? DataSnapshot,
	//				   let id = childSnapshot.key as? String,
	//				   let dict = childSnapshot.value as? [String: Any],
	//				   let userName = dict["userName"] as? String,
	//				   let email = dict["email"] as? String,
	//				   let tagName = dict["tagName"] as? String,
	//				   let status = dict["status"] as? String,
	//				   let profilePhotoURL = dict["profilePhotoURL"] as? String
	//				{
	//				let friend = Friend(id: id, userName: userName, email: email, tagName: tagName, status: status, profilePhotoURL: profilePhotoURL)
	//				print("--friend got from database: ", status)
	//				if(status == "accepted") {
	//					print("--here \(friend)")
	//					tempFriendList.append(friend)
	//				} else if(status == "sent") {
	//					tempFriendReqSent.append(friend)
	//				} else if(status == "received") {
	//					tempFriendReqReceived.append(friend)
	//				}
	//				}
	//			}
	//			friendList = tempFriendList
	//			friendReqReceived = tempFriendReqReceived
	//			friendReqSent = tempFriendReqSent
	//			DispatchQueue.main.async {
	//				self?.delegate?.friendWasFetched()
	//			}
	//		})
	//	}
	
	func stopObserving() {
		observers.forEach { handle in
			database.removeObserver(withHandle: handle)
		}
		observers.removeAll()
		friendList.removeAll()
		friendReqReceived.removeAll()
		friendReqSent.removeAll()
	}
}
