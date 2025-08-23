//
//  User.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
var currentUser: ProjdularUser?
//var currentUserProfilePhoto: UIImage?

///The definition of a ProjdularUser.
struct ProjdularUser : Equatable {
	let email: String
	let userID: String
	let userName: String
	var profilePhotoURL: String
}

final class userService {
	static let shared = userService()
	private let storage = Storage.storage().reference()
	private let database = Database.database().reference()
	
	public func insertUser(with user: ProjdularUser) {
		print("**tryingto create a new user: ", user.userID)
		database.child("userList").child(Auth.auth().currentUser!.uid).setValue([
			"email": user.email,
			"userName": user.userName,
			"profilePhotoURL": user.profilePhotoURL
			//"userID": Auth.auth().currentUser!.uid
		])
	}
	
	func findUser(emailToFind: String, completionSuccess: @escaping (ProjdularUser) -> Void) {
		var user = ProjdularUser(email: "", userID: "", userName: "", profilePhotoURL: "")
		let friendRef = database.child("userList")
		
		friendRef.queryOrdered(byChild: "email").observeSingleEvent(of: .value, with: { snapshot in
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any],
				   let emailFound = dict["email"] as? String,
				   let userName = dict["userName"] as? String,
				   let photoURL = dict["profilePhotoURL"] as? String
				{
				if(emailToFind == emailFound) {
					user = ProjdularUser(email: emailFound, userID: id, userName: userName, profilePhotoURL: photoURL)
					completionSuccess(user)
				}
				}
			}
		}, withCancel: {(err) in
			print("**error: ", err)
		})
	}
	
	func uploadProfilePhoto (image: UIImage, for userID: String, completion: @escaping (Result<String, Error>) -> Void) {
		guard let imageData = image.jpegData(compressionQuality: 0.4) else {
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])))
			return
		}
		
		let photoRef = storage.child("profile_photos").child("\(userID).jpg")
		
		let metadata = StorageMetadata()
		metadata.contentType = "image/jpeg"
		
		photoRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			photoRef.downloadURL { url, error in
				if let error = error {
					completion(.failure(error))
					return
				}
				
				guard let downloadURL = url?.absoluteString else {
					completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get download URL"])))
					return
				}
				
				//				self?.database.child("users").child(userID).updateChildValues([
				//					"profilePhotoURL": downloadURL
				//				]) { error, _ in
				//					if let error = error {
				//						completion(.failure(error))
				//					} else {
				//						completion(.success(downloadURL))
				//					}
				//				}
				self?.database.child("userList").child(userID).updateChildValues([
					"profilePhotoURL": downloadURL
				]) { error, _ in
					if let error = error {
						completion(.failure(error))
					} else {
						currentUser!.profilePhotoURL = downloadURL
						completion(.success(downloadURL))
					}
				}
			}
		}
	}
	
	// Function to load profile photo
	func loadProfilePhoto(for userID: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
		// 1. Get URL from database
		database.child("userList").child(userID).child("profilePhotoURL").observeSingleEvent(of: .value) { snapshot in
			guard let urlString = snapshot.value as? String, let url = URL(string: urlString) else {
				completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
				return
			}
			
			// 2. Download image data
			URLSession.shared.dataTask(with: url) { data, response, error in
				if let error = error {
					completion(.failure(error))
					return
				}
				
				guard let imageData = data,
					  let image = UIImage(data: imageData) else {
					completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create image"])))
					return
				}
				
				DispatchQueue.main.async {
					completion(.success(image))
				}
			}.resume()
		}
	}
	
	// Function to cache images
	private let imageCache = NSCache<NSString, UIImage>()
	
	func loadProfilePhotoWithCaching(for userID: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
		// Check cache first
		if let cachedImage = imageCache.object(forKey: userID as NSString) {
			completion(.success(cachedImage))
			return
		}
		
		loadProfilePhoto(for: userID) { [weak self] result in
			switch result {
			case .success(let image):
				// Store in cache
				self?.imageCache.setObject(image, forKey: userID as NSString)
				completion(.success(image))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	///updates user settings on firebase
	public func updateUserSettings(settings: SettingsHelper) {
		self.database.child("users").child(Auth.auth().currentUser!.uid).child("userSettings").setValue([
			"autoBreakLength": settings.autoBreakLength,
			"autoPrepLength": settings.autoPrepLength,
			"addNewDirection": settings.addNewDirection,
			"autoWorkDays": settings.autoWorkDays
		])
	}
	
}
