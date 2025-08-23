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
	@IBOutlet weak var userNameTextfieldSignUp: UITextField!
	@IBOutlet weak var Verified: UIButton!
	
	@IBAction func login(_ sender: Any) {
		showLogin()
	}
	
	override func viewDidLoad() {
		emailTextFieldSignUp.delegate = self
		passwordTextfieldSignUp.delegate = self
		userNameTextfieldSignUp.delegate = self
		
		super .viewDidLoad()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		signUp()
	}
}

//MARK: SignUpLogic
extension SignUpViewController {
	func signUp() {
		guard
			let email = emailTextFieldSignUp.text,
			let password = passwordTextfieldSignUp.text,
			let userName = userNameTextfieldSignUp.text,
			!password.isEmpty,
			!email.isEmpty,
			!userName.isEmpty
		else {
			print("**FailedLogin")
			return
		}
		
		FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
			guard let result = authResult, error == nil else {
				print("**Error creating user: \(error!.localizedDescription)")
				alertUserAndGoToRootController(view: self, title: "Error", content: error!.localizedDescription, dismissView: false)
				return
			}
			let user: String = result.user.email!
			print("**Created User: \(user), Logged in: \(true)")
			//self.dismiss(animated: true, completion: nil)
			alertUserAndGoToRootController(view: self, title: "Success", content: "An email has been sent for verification of this account", dismissView: true)
			self.sendVerificationEmail()
		})
		
//		DatabaseManagerForCollectionViewController.shared.newUser(with: ProjdularUser(email: email, userID: password))
	}
	
	func sendVerificationEmail() {
		Auth.auth().currentUser?.sendEmailVerification(completion: { [self](error) -> Void in
			if (error != nil) {
				alertUserAndGoToRootController(view: self, title: "Success", content: "You are now a verified user", dismissView: true)
			} else {
				alertUserAndGoToRootController(view: self, title: "Error", content: "There was an error in the verification process", dismissView: false)
			}
		})
	}
}

//MARK: Navigation
extension SignUpViewController {
	@IBAction func verifyAndGoBack(_ sender: Any) {
		Auth.auth().currentUser?.reload(completion:	{_ in
			if Auth.auth().currentUser?.isEmailVerified == true {
				//UDM.shared.defaults.setValue(true, forKey: "isLoggedIn")
				
				userService.shared.insertUser(with: ProjdularUser(email: (Auth.auth().currentUser?.email)!, userID: Auth.auth().currentUser!.uid, userName: self.userNameTextfieldSignUp.text ?? "", profilePhotoURL: "to be set"))
				currentUser = ProjdularUser(email: (Auth.auth().currentUser?.email)!, userID: Auth.auth().currentUser!.uid, userName: self.userNameTextfieldSignUp.text ?? "", profilePhotoURL: "to be set")
				
//				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
				let vc = self.storyboard?.instantiateViewController(identifier: "UploadPhotoViewController")
				
				vc!.modalPresentationStyle = .fullScreen
				
				self.present(vc!, animated: true, completion: nil)
			} else {
				alertUserAndGoToRootController(view: self, title: "Not yet verified.", content: "Please verify your account and try again.", dismissView: true)
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
	func showLogin() {
		let vc = storyboard?.instantiateViewController(identifier: "LogInViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
}

