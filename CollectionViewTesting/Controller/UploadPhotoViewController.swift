//
//  UploadPhotoViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/28/24.
//

import UIKit
import FirebaseAuth

class UploadPhotoViewController: UIViewController {
//	private var selectedProfileImage: UIImage?
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBAction func back(_ sender: Any) {
		goBack()
	}
	@IBAction func uploadPhoto(_ sender: Any) {
		uploadButtonTapped()
	}
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	@objc private func uploadButtonTapped() {
//		PHPhotoLibrary.requestAuthorization { [weak self] status in
//			guard status == .authorized else {
//				print("--You are not authorized")
//				return
//			}
//			
//			DispatchQueue.main.async {
//				self?.presentImagePicker()
//			}
//		}
		presentImagePicker()
		setProfileImageConstraints()
	}
	
	private func setProfileImageConstraints() {
		profileImage.contentMode = .scaleAspectFit
		profileImage.backgroundColor = .lightGray
		profileImage.layer.cornerRadius = profileImage.frame.width/2
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
extension UploadPhotoViewController {
	
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
	
	func goBack() {
		let vc = storyboard?.instantiateViewController(identifier: "SignUpViewController")
		
		vc!.modalPresentationStyle = .fullScreen
		
		present(vc!, animated: true, completion: nil)
	}
}

//MARK: UIImagePickerDelegate
extension UploadPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
