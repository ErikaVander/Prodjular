//
//  SettingsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 12/13/23.
//

import UIKit

class SettingsViewController: UIViewController {
	
	@IBAction func accountInfo(_ sender: Any) {
		let vc = storyboard?.instantiateViewController(identifier: "AccountInfoViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
}
