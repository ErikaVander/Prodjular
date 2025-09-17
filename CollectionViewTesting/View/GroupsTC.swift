//
//  GroupsTC.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/4/25.
//

import UIKit

protocol GroupsTCDelegate: AnyObject {
	func cellTappedLogic(groupID: String)
	func acceptButtonTappedLogic()
}

class GroupsTC: UITableViewCell {
	weak var delegate: GroupsTCDelegate?
	var groupID: String?
	@IBOutlet weak var rightArrow: UIButton!
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
	@IBAction func cellTapped(_ sender: Any) {
		delegate?.cellTappedLogic(groupID: groupID!)
	}
	@IBAction func acceptTapped(_ sender: Any) {
		delegate?.acceptButtonTappedLogic()
	}
	
	func hideAcceptButtonView() {
		acceptButton.isHidden = true
	}
	func showAcceptButtonView() {
		acceptButton.isHidden = false
		acceptButton.layer.cornerRadius = 12
	}
	func showRightArrowButton() {
		rightArrow.isHidden = false
		rightArrow.setImage(UIImage(systemName: "chevron.right"), for: .normal)
		rightArrow.setTitle("", for: .normal)
	}
	func hideRightArrowButton() {
		rightArrow.isHidden = true
	}
}
