//
//  User.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit
var currentUser: ProjdularUser?
//var currentUserProfilePhoto: UIImage?

///The definition of a ProjdularUser.
struct ProjdularUser : Equatable {
	let email: String
	let userID: String
	let userName: String
	var profilePhotoURL: String
}
