//
//  AddFriendViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddFriendViewController: UIViewController {
	@IBOutlet weak var addFriendLabel: UILabel!
	@IBOutlet weak var emailTextBox: UITextField!
	@IBOutlet weak var searchButton: UIButton!
	
	@IBAction func addFriend(_ sender: Any) {
		DatabaseManagerForAddFriendsViewController.shared.findUser(emailToFind: emailTextBox.text!) {found in
			print(found)
			if found == "found" {
				alertUser(view: self, title: "Success", content: "You've added an new friend!", dismissView: true)
			} else if found == "notFound"{
				alertUser(view: self, title: "No user found", content: "No user was found with that email address.", dismissView: false)
			} else if found == "double" {
				alertUser(view: self, title: "Duplicate", content: "You've already added that friend.", dismissView: false)
			} else if found == "self" {
				alertUser(view: self, title: "Narcissist", content: "Please use the email of someone other than yourself.", dismissView: false)
			}
		}
	}
	
}
