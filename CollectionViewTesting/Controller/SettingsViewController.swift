//
//  SettingsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 12/13/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettingsViewController: UIViewController {
	
	@IBAction func accountInfo(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(identifier: "AccountInfoViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
	@IBAction func YourFriends(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(identifier: "YourFriendsViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
}
