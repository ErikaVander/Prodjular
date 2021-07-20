//
//  LogInViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/6/21.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController
{
	@IBOutlet weak var emailTextFieldSignUp: UITextField!
	@IBOutlet weak var passwordTextfieldSignUp: UITextField!
	
	override func viewDidLoad() {
		super .viewDidLoad()
		setProfilePicImage()
	}
	
	func setProfilePicImage() {
		//profilePicture.layer.cornerRadius = 10
		//profilePicture.backgroundColor = UIColor.white
	}
	
//	@IBAction func DoneAddingUser(_ sender: Any) {
//		guard
//			let email = emailTextFieldSignUp.text,
//			let password = passwordTextfieldSignUp.text,
//			!password.isEmpty,
//			!email.isEmpty
//		else {
//
//			print("FailedLogin")
//			return
//		}
//
//		FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
//			guard let result = authResult, error == nil else {
//				print("Error creating user: \(error!.localizedDescription)")
//				return
//			}
//			let user: String = result.email!
//			isLoggedIn = true
//			print("Created User: \(user), Logged in: \(isLoggedIn)")
//			self.dismiss(animated: true, completion: nil)
//		})
//	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)

		guard
			let email = emailTextFieldSignUp.text,
			let password = passwordTextfieldSignUp.text,
			!password.isEmpty,
			!email.isEmpty
		else {
			
			print("FailedLogin")
			return
		}
		
		FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
			guard let result = authResult, error == nil else {
				print("Error creating user: \(error!.localizedDescription)")
				return
			}
			let user: String = result.email!
			isLoggedIn = true
			print("Created User: \(user), Logged in: \(isLoggedIn)")
			self.dismiss(animated: true, completion: nil)
		})
	}
	
}
