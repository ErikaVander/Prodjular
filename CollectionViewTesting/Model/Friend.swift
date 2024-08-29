//
//  Friend.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit
///An array of friends
var friendList = [Friend]()

///The definition of a Friend.
struct Friend : Equatable {
	let id: String
	var userName: String
	let email: String
	var tagName: String?
}
