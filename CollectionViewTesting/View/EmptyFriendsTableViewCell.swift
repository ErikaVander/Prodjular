//
//  EmptyFriendsTableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/9/24.
//

import UIKit

class EmptyFriendsTableViewCell: UITableViewCell {
	@IBOutlet weak var emptyLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
