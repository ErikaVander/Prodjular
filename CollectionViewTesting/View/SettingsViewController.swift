//
//  SettingsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/19/21.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseDatabase
import FirebaseCore

class SettingsViewController: UIViewController
{
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func AccountInfoRequest(_ sender: Any) {
		showLogIn()
	}
	
	
	func showLogIn() {
		let vc = storyboard?.instantiateViewController(identifier: "LogInViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
}
