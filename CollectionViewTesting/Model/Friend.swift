//
//  Friend.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit
///An array of friends
var friendList = [Friend]()
var friendReqReceived = [Friend]()
var friendReqSent = [Friend]()

///The definition of a Friend.
struct Friend : Equatable {
	let id: String
	var userName: String
	let email: String
	var tagName: String?
	var status: String
	var profilePhotoURL: String
//	var ProfilePhotoLastUpdated: String
}
