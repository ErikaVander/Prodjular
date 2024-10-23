//
//  DatabaseManagerForFriendsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

//protocol DatabaseManagerDelegateForFriendsViewController {
//	func logicForDeletingFriendTableViewCell(_ databaseManager: DatabaseManagerForFriendsViewController, indexPath: IndexPath)
//}
//
//final class DatabaseManagerForFriendsViewController {
//	static let shared = DatabaseManagerForFriendsViewController()
//	
//	var delegate: DatabaseManagerDelegateForFriendsViewController?
//	
//	private let database = Database.database().reference()
//	
//	///Deletes friend
//	public func deleteFriend(with friend: Friend, indexPath: IndexPath) {
//		/*self.database.ref.child("users/\(Auth.auth().currentUser!.uid)/events/\(String(describing: event.id))").removeValue() {_,_ in
//		 print("--LogicForDeletingTableViewCell about to be called")
//		 self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
//		 print("--at the end")
//		 }*/
//		self.database.ref.child("users").child(Auth.auth().currentUser!.uid).child("friends").child(String(describing: friend.id)).setValue(nil) {
//			(error: Error?, ref: DatabaseReference) in
//			if let error = error {
//				print("**Data could not be saved: \(error).")
//			} else {
//				//print("--Trying to print friendList", friendList)
//				self.delegate?.logicForDeletingFriendTableViewCell(self, indexPath: indexPath)
//				//				print("--Just triend to call the function")
//				print("**Data saved successfully!")
//			}
//			
//		}
//	}
//}
