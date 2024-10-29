//
//  UploadPhotoViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/28/24.
//

import UIKit
import FirebaseAuth

class UploadPhotoViewController: UIViewController {
	@IBAction func back(_ sender: Any) {
		goBack()
	}
	override func viewDidLoad() {
		super.viewDidLoad()
	}
}

//MARK: Navigation
extension UploadPhotoViewController {
	func goBack() {
		let vc = storyboard?.instantiateViewController(identifier: "SignUpViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
}
