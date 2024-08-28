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
		DatabaseManagerForAddFriendsViewController.shared.findUser(emailToFind: emailTextBox.text!)
	}
	
}
