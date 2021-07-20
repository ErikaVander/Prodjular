//
//  LogInViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/19/21.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController
{
	@IBOutlet weak var SignUpLogOut: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		setSignUpLogOutButton()
	}
	
	@IBAction func DismissViewController(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func setSignUpLogOutButton() {
		if isLoggedIn == true {
			SignUpLogOut.setTitle("Log Out", for: .normal)
		} else {
			SignUpLogOut.setTitle("Sign Up", for: .normal)
		}
	}
	@IBAction func LogOutOrSignUp(_ sender: Any) {
		if isLoggedIn == true {
			let firebaseAuth = Auth.auth()
			do {
				try firebaseAuth.signOut()
			} catch let signOutError as NSError {
				print("Error signing out: %@", signOutError)
			}
			print(">>>>>>>>>>>>>>>EndOfSignOut<<<<<<<<<<<<<<<<<")
		} else {
			print(">>>>>>>>>>>>>>WhyAmIHere<<<<<<<<<<<<<<<<")
			showSignUp()
		}
	}
	
	func showSignUp() {
		let vc = storyboard?.instantiateViewController(identifier: "SignInViewController")
		
		vc!.modalPresentationStyle = .popover
		
		present(vc!, animated: true, completion: nil)
	}
}
