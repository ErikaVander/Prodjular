//
//  GroupsTC.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/4/25.
//

import UIKit

class GroupsTC: UITableViewCell {
	@IBOutlet weak var acceptButton: UIButton!
	@IBOutlet weak var numMembersLabel: UILabel!
	@IBOutlet weak var adminLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
	func hideAcceptButtonView() {
		acceptButton.isHidden = true
	}
	func showAcceptButtonView() {
		acceptButton.isHidden = false
		acceptButton.layer.cornerRadius = 12
	}
}
