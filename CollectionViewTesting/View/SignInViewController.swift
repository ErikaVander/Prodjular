//
//  LogInViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/6/21.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate
{
	@IBOutlet weak var emailTextFieldSignUp: UITextField!
	@IBOutlet weak var passwordTextfieldSignUp: UITextField!
	@IBOutlet weak var Verified: UIButton!
	
	override func viewDidLoad() {
		emailTextFieldSignUp.delegate = self
		passwordTextfieldSignUp.delegate = self
		
		super .viewDidLoad()
		setProfilePicImage()
	}
	
	@IBAction func verifyAndGoBack(_ sender: Any) {

		Auth.auth().currentUser?.reload(completion:
			{_ in
				if Auth.auth().currentUser?.isEmailVerified == true {
				isLoggedIn = true
				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
				} else {
					self.alertUserOfError(title: "Not yet verified.", content: "Please verify your account and try again.", goAway: true)
				}
			}
		)
	}
	
	func setProfilePicImage() {
		//profilePicture.layer.cornerRadius = 10
		//profilePicture.backgroundColor = UIColor.white
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)

		signUp()
	}
	
	func signUp() {
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
				self.alertUserOfError(title: "Error", content: error!.localizedDescription, goAway: false)
				return
			}
			let user: String = result.email!
			print("Created User: \(user), Logged in: \(isLoggedIn)")
			//self.dismiss(animated: true, completion: nil)
			self.alertUserOfError(title: "Success", content: "An email has been sent for verification of this account", goAway: true)
			self.sendVerificationEmail()
		})
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailTextFieldSignUp {
			self.resignFirstResponder()
			passwordTextfieldSignUp.becomeFirstResponder()
		} else {
			passwordTextfieldSignUp.resignFirstResponder()
			signUp()
			print(">>>>>KeyboardReturnButtonHit<<<<<")
		}
		return true
	}
	
	func alertUserOfError(title: String, content: String, goAway: Bool) {
		let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
			if goAway == true && FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == true {
				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
			}
		}))
		present(alert, animated: true, completion: nil)
	}
	
	func sendVerificationEmail() {
		Auth.auth().currentUser?.sendEmailVerification(completion: { [self](error) -> Void in
			if (error != nil) {
				self.alertUserOfError(title: "Success", content: "You are now a verified user", goAway: true)
			} else {
				self.alertUserOfError(title: "Error", content: "There was an error in the verification process", goAway: false)
			}
		})
	}
	
	func arrowForDismissal() {
		self.modalPresentationCapturesStatusBarAppearance = true
	}
}

