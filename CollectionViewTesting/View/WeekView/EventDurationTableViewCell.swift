//
//  EventDurationTableViewCell.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 5/21/22.
//

import UIKit

let hourSegmentLineTrailingConstraint = 0
let hourSegmentSegmentorDistribution = 46
let hourLabelTrailingConstraint = 15
let tableViewCellHeight = 40

class EventDurationTableViewCell: UITableViewCell {
	
	@IBOutlet weak var hourSegmentLine: UIView!
	@IBOutlet weak var eventDurationHourLabel: UILabel!
	@IBOutlet weak var hourSegmentSegmentor_01: UIView!
	@IBOutlet weak var hourSegmentSegmentor_02: UIView!
	@IBOutlet weak var hourSegmentSegmentor_03: UIView!
	@IBOutlet weak var hourSegmentSegmentor_04: UIView!
	@IBOutlet weak var hourSegmentSegmentor_05: UIView!
	@IBOutlet weak var hourSegmentSegmentor_06: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		//		print(hourSegmentLine.frame.width)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
