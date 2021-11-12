//
//  SignUpViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/6/21.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController
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
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		signUp()
	}
	
	func setProfilePicImage() {
		//profilePicture.layer.cornerRadius = 10
		//profilePicture.backgroundColor = UIColor.white
	}
}

//MARK: SignUpLogic
extension SignUpViewController {
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
				alertUser(view: self, title: "Error", content: error!.localizedDescription, dismissView: false)
				return
			}
			let user: String = result.email!
			print("Created User: \(user), Logged in: \(isLoggedIn)")
			//self.dismiss(animated: true, completion: nil)
			alertUser(view: self, title: "Success", content: "An email has been sent for verification of this account", dismissView: true)
			self.sendVerificationEmail()
		})
	}
	
	func sendVerificationEmail() {
		Auth.auth().currentUser?.sendEmailVerification(completion: { [self](error) -> Void in
			if (error != nil) {
				alertUser(view: self, title: "Success", content: "You are now a verified user", dismissView: true)
			} else {
				alertUser(view: self, title: "Error", content: "There was an error in the verification process", dismissView: false)
			}
		})
	}
}

//MARK: Navigation
extension SignUpViewController {
	@IBAction func verifyAndGoBack(_ sender: Any) {
		Auth.auth().currentUser?.reload(completion:
											{_ in
			if Auth.auth().currentUser?.isEmailVerified == true {
				isLoggedIn = true
				
				DatabaseManager.shared.insertUser(with: ProjdularUser(email: (Auth.auth().currentUser?.email)!, userID: Auth.auth().currentUser!.uid))
				
				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
			} else {
				alertUser(view: self, title: "Not yet verified.", content: "Please verify your account and try again.", dismissView: true)
			}
		}
		)
	}
}

//MARK: TextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailTextFieldSignUp {
			self.resignFirstResponder()
			passwordTextfieldSignUp.becomeFirstResponder()
		} else {
			passwordTextfieldSignUp.resignFirstResponder()
			signUp()
		}
		return true
	}
}

