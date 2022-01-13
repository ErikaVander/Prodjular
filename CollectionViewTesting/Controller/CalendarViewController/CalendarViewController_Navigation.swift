//
//  CalendarViewController_Navigation.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 1/12/22.
//

import UIKit

extension CalendarViewController {
	///Logic to show the login page.
	func showLogIn() {
		let vc = storyboard?.instantiateViewController(identifier: "LogInViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
	
	///BackSegue after creating a new event
	@IBAction func BackSegue(unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
	}
	
	func showEventViewController() {
		let vc = storyboard?.instantiateViewController(identifier: "EventViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)	}
}
