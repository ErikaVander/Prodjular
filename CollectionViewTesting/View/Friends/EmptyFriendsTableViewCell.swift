//
//  EmptyFriendsTableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 10/9/24.
//

import UIKit

class EmptyFriendsTableViewCell: UITableViewCell {
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var emptyLabel: UILabel!
	var heightConstraintEmpty: NSLayoutConstraint?
	var heightConstraint: NSLayoutConstraint?
	
	var emptyLabelCenterXConstraint: NSLayoutConstraint?
	var emptyLabelCenterYConstraint: NSLayoutConstraint?
	
	var emptyLabelHeight: NSLayoutConstraint?
//	var emptyLabelWidth: NSLayoutConstraint?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		heightConstraintEmpty = containerView.heightAnchor.constraint(equalToConstant: 45)
		heightConstraintEmpty!.identifier = "emptyLabelHeightConstraintEmpty-Height"
		
		heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 1)
		heightConstraint!.identifier = "emptyLabelHeightConstraint-Height"
		
//		emptyLabelWidth = containerView.widthAnchor.constraint(equalTo: superview!.widthAnchor, multiplier: 1)
//		emptyLabelWidth!.isActive = true
		
		
		emptyLabelCenterXConstraint = emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
		emptyLabelCenterXConstraint!.identifier = "emptyLabelLeadingConstraint-centerX"
		emptyLabelCenterXConstraint!.isActive = true
		
		emptyLabelCenterYConstraint = emptyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		emptyLabelCenterYConstraint!.identifier = "emptyLabelLeadingConstraint-centerY"
		emptyLabelCenterYConstraint!.isActive = true
		
//		emptyLabelHeight = emptyLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1)
//		emptyLabelHeight!.isActive = true
//		emptyLabelWidth = emptyLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1)
//		emptyLabelWidth!.isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
