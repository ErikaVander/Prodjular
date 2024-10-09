//
//  DatabaseManagerForSignUpandLogin.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/8/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

final class DatabaseManagerForSignUpandLogin {
	static let shared = DatabaseManagerForSignUpandLogin()
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
							//print("--user1: ", user)
							completionSuccess(user)
						}
					}
					//self.sendFriendRequest(emailToFind: currentUser.email, id: id)
				}
		}, withCancel: {(err) in
			print("**error: ", err)
		})
	}
}
