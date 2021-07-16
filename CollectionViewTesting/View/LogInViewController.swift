//
//  LogInViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/6/21.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController
{
	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextfield: UITextField!
	@IBOutlet weak var EditPicButton: UIButton!
	
	override func viewDidLoad() {
		super .viewDidLoad()
		setProfilePicImage()
	}
	
	func setProfilePicImage() {
		//profilePicture.layer.cornerRadius = 10
		//profilePicture.backgroundColor = UIColor.white
	}
	@IBAction func DoneAddingUser(_ sender: Any) {
		guard
			let email = emailTextField.text,
			let password = passwordTextfield.text,
			!password.isEmpty,
			!email.isEmpty
		else {
			
			print("FailedLogin")
			return
		}
		
		FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
			guard let result = authResult, error == nil else {
				print("Error creating user")
				return
			}
			let user: String = result.email!
			isLoggedIn = true
			print("Created User: \(user), Logged in: \(isLoggedIn)")
			self.dismiss(animated: true, completion: nil)
		})
	}
	
}
