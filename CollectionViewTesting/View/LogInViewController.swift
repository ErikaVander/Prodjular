//
//  LogInViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/19/21.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController, UITextFieldDelegate
{
	@IBOutlet weak var SignUp: UIButton!
	@IBOutlet weak var Email: UITextField!
	@IBOutlet weak var Password: UITextField!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Email.delegate = self
		Password.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
	}
	
	//The function called when "Back to Settings" is pressed by the user. The login page is dismissed.
	@IBAction func DismissViewController(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func SignUp(_ sender: Any) {
		showSignUp()
	}
	
	//Code to desplay the signup screen
	func showSignUp() {
		print(">>>>>ThisOneIsCalled<<<<<")
		let vc = storyboard?.instantiateViewController(identifier: "SignInViewController")
		
		vc!.modalPresentationStyle = .popover
		
		present(vc!, animated: true, completion: nil)
	}
	
	//Code that is run after the user hits the return key on keyboard
	//when the user hits done in password textfield, the login function is called.
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == Email {
			self.resignFirstResponder()
			Password.becomeFirstResponder()
		} else {
			Password.resignFirstResponder()
			login()
			print(">>>>>KeyboardReturnButtonHit<<<<<")
		}
		return true
	}
	
	//Logic for logging in
	//This is where the warning to the user when there is an error logging in should occurr
	func login() {
		guard let email = Email.text else {
			print(">>>>>NoEmailProvided<<<<<")
			return
		}
		guard let password = Password.text else {
			print(">>>>>NoPasswordProvided<<<<<")
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
			guard error == nil else {
				print(">>>>>Error logging in: \(error!.localizedDescription)<<<<<")
				alertUserOfError(view: self, title: "Error", content: error!.localizedDescription, goAway: false)
				return
			}
			isLoggedIn = true
			print(">>>>>User has signed in: \(authResult?.email ?? "No user has signed in<<<<<") isLoggedIn: \(isLoggedIn)")
			alertUserOfError(view: self, title: "Success", content: "You are now logged in", goAway: true)
		}
	}
}
