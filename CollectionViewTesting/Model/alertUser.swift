//
//  FirebaseAuthHelper.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/13/21.
//

import Foundation
import FirebaseAuth
import UIKit

func alertUser(view: UIViewController, title: String, content: String, dismissView: Bool) {
	let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
	alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
		if dismissView == true && FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == true {
			view.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
		}
	}))
	view.present(alert, animated: true, completion: nil)
}
