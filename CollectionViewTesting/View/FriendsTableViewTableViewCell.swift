//
//  FriendsTableViewTableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit

class FriendsTableViewTableViewCell: UITableViewCell {
	static let shared = FriendsTableViewTableViewCell()
	
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	var friend = Friend(id: "nil", userName: "nil", email: "nil", tagName: "nil", status: "nil", profilePhotoURL: "nil")
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
	func setFriend(friend: Friend) {
		self.friend = friend
	}
	func getFriend() -> Friend {
		return friend
	}
}
