//
//  FriendReqTableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/14/24.
//

import UIKit

protocol FriendReqTableViewCellDelegate {
	func deleteRow(cell: UITableViewCell, friend: Friend)
}

class FriendReqTableViewCell: UITableViewCell {
	
	var delegate: FriendReqTableViewCellDelegate?
	static let shared = FriendReqTableViewCell()

	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
	var indexPath: IndexPath?
	var friend = Friend(id: "nil", userName: "nil", email: "nil", tagName: "nil", status: "nil", profilePhotoURL: "nil")
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	@IBAction func acceptFriend(_ sender: Any) {
		print("--accepted friend")
		DatabaseManagerForFriendViewController.shared.acceptFriendRequest(friend: self.friend)
		self.delegate!.deleteRow(cell: self, friend: self.friend)
	}
	
	@IBAction func declineFriend(_ sender: Any) {
		print("--declined friend")
		DatabaseManagerForFriendViewController.shared.declineFriendRequest(friend: self.friend)
		self.delegate!.deleteRow(cell: self, friend: self.friend)
	}
	
	
	func setFriend(friend: Friend) {
		self.friend = friend
		print("--trying to set friend: ", self.friend)
	}
	
	func getFriend() -> Friend {
		print("--trying to get friend: ", friend)
		return friend
	}
}
