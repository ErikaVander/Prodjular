//
//  AccountInfoViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/21/21.
//

import Foundation
import UIKit
import FirebaseAuth

class AccountInfoViewController: UIViewController {
	
	@IBOutlet weak var UserPhoto: UIImageView!
	@IBOutlet weak var UserEmail: UILabel!
	
	override func viewDidLoad() {
		super .viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		setUserEmail()
	}
}

//MARK: EditAccount or Logout
extension AccountInfoViewController {
	func setUserEmail() {
		UserEmail.text = Auth.auth().currentUser?.email
	}
	
	@IBAction func changePhoto(_ sender: Any) {
		
	}
	
	@IBAction func logout(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			alertUserOfError(title: "Success", content: "You are now logged out", goAway: true)
			isLoggedIn = false
		} catch let error as NSError {
			alertUserOfError(title: "Error", content: error.localizedDescription, goAway: false)
		}
	}
}

//MARK: Navigation
extension AccountInfoViewController {
	///Goes back to the settings page
	@IBAction func backToSettings(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	///You cannot use alertUser, because, as of right now, alertUser does not support presenting another screen as opposed to dismissing the current one.
	///Alerts user and presents LogInViewController if logOut was successful.
	func alertUserOfError(title: String, content: String, goAway: Bool) {
		let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
			if goAway == true {
				let vc = self.storyboard?.instantiateViewController(identifier: "LogInViewController")
				
				vc!.modalPresentationStyle = .fullScreen
				
				self.present(vc!, animated: true, completion: nil)
			}
		}))
		present(alert, animated: true, completion: nil)
	}
}
