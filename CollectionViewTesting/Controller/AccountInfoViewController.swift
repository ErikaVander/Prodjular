//
//  AccountInfoViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 7/21/21.
//

import Foundation
import UIKit
import FirebaseAuth

var initialLoadingOfDataForAccountInfo = true

class AccountInfoViewController: UIViewController {
	
	@IBOutlet weak var headerContainerView: UIView!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var pageTitle: UILabel!
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var UserEmail: UILabel!
	
	override func viewDidLoad() {
		super .viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		setUserEmail()
		setHeaderContainerViewLook()
		setProfileImageConstraints()
//		profileImage.image = currentUserProfilePhoto!
		if initialLoadingOfDataForAccountInfo == true {
			userService.shared.loadProfilePhoto(for: Auth.auth().currentUser!.uid) { [weak self] result in
				switch result {
				case .failure(let error):
					print("**error: ", error)
				case .success(let image):
					self?.profileImage.image = image
				}
			}
			print("--initialLoadingOfDataForAccountInfo = true")
			initialLoadingOfDataForAccountInfo = false
		} else {
			userService.shared.loadProfilePhotoWithCaching(for: Auth.auth().currentUser!.uid) { [weak self] result in
				switch result {
				case .failure(let error):
					print("**error: ", error)
				case .success(let image):
					self?.profileImage.image = image
				}
			}
			print("--initialLoadingOfDataForAccountInfo = false")
		}
	}
	
	func setHeaderContainerViewLook() {
		headerContainerView.layer.shadowOffset = .zero
		headerContainerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 25, width: headerContainerView.frame.width, height: headerContainerView.frame.height/2)).cgPath
		headerContainerView.layer.shadowOpacity = 0.5
		headerContainerView.layer.shadowRadius = 3
		headerContainerView.layer.shadowColor = UIColor.label.cgColor
		
		headerContainerView.layer.shouldRasterize = true
		headerContainerView.layer.rasterizationScale = UIScreen.main.scale
	}
	
	private func setProfileImageConstraints() {
		profileImage.contentMode = .scaleAspectFit
		profileImage.backgroundColor = .lightGray
		profileImage.layer.cornerRadius = profileImage.frame.width/2
	}
}

//MARK: EditAccount or Logout
extension AccountInfoViewController {
	func setUserEmail() {
		UserEmail.text = Auth.auth().currentUser?.email
	}
	
	@IBAction func changePhoto(_ sender: Any) {
		presentImagePicker()
	}
	
	@IBAction func logout(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			alertUserOfError(title: "Success", content: "You are now logged out", goAway: true)
			//UDM.shared.defaults.setValue(false, forKey: "isLoggedIn")
			currentUser = nil
		} catch let error as NSError {
			alertUserOfError(title: "Error", content: error.localizedDescription, goAway: false)
		}
	}
	private func presentImagePicker() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
}

//MARK: Navigation
extension AccountInfoViewController {
	func updateProfilePhoto(with image: UIImage) {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		userService.shared.uploadProfilePhoto(image: image, for: userID) { [weak self] result in
			switch result {
			case .success(let url):
				print("**Successfully uploaded photo: \(url)")
				self?.profileImage.image = image
			case .failure(let error):
				print("**Error uploading photo: \(error)")
				// Show error to user
			}
		}
	}
	
	///Goes back to the settings page
	@IBAction func backToSettings(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	///You cannot use alertUser, because, as of right now, alertUser does not support presenting another screen as opposed to dismissing the current one.
	///Alerts user and presents LogInViewController if logOut was successful.
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

//MARK: UIImagePickerDelegate
extension AccountInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let selectedProfileImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
			//			self.selectedProfileImage = selectedProfileImage
			profileImage.image = selectedProfileImage
			updateProfilePhoto(with: selectedProfileImage)
			dismiss(animated: true, completion: nil)
			return
		}
		
		dismiss(animated: true, completion: nil)
		
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
}
