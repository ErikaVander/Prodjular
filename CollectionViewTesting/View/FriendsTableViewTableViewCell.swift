//
//  FriendsTableViewTableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit

class FriendsTableViewTableViewCell: UITableViewCell {
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
