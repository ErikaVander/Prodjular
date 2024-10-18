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
	@IBOutlet weak var addFriendContainerView: UIView!
	@IBOutlet weak var addFriendLabel: UILabel!
	@IBOutlet weak var emailTextBox: UITextField!
	@IBOutlet weak var searchButton: UIButton!
	
	@IBAction func addFriend(_ sender: Any) {
		print("--here")
		DatabaseManagerForAddFriendViewController.shared.findUser(emailToFind: emailTextBox.text!) {found in
			print("--found from addFriend: ", found)
			if found == "found" {
				alertUserAndGoBack(view: self, title: "Success", content: "You've added an new friend!", dismissView: true)
			} else if found == "notFound"{
				alertUserAndGoBack(view: self, title: "No user found", content: "No user was found with that email address.", dismissView: false)
			} else if found == "double" {
				alertUserAndGoBack(view: self, title: "Duplicate", content: "You've already added that friend.", dismissView: false)
			} else if found == "self" {
				alertUserAndGoBack(view: self, title: "Narcissist", content: "Please use the email of someone other than yourself.", dismissView: false)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		emailTextBox.becomeFirstResponder()
		addFriendContainerView.layer.cornerRadius = 50
	}
}
