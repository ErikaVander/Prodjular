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
	
	@IBAction func logout(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			alertUserOfError(title: "Success", content: "You are now logged out", goAway: true)
			isLoggedIn = false
		} catch let error as NSError {
			alertUserOfError(title: "Error", content: error.localizedDescription, goAway: false)
		}
	}
	
	@IBAction func changePhoto(_ sender: Any) {
		
	}
	
	@IBAction func backToSettings(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func setUserEmail() {
		UserEmail.text = Auth.auth().currentUser?.email
	}
	
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
