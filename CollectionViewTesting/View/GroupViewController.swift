//
//  GroupViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/3/25.
//

import UIKit

class GroupViewController: UIViewController {
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var groupInvitationsView: GenericTableWithHeader!
	@IBOutlet weak var groupsView: GenericTableWithHeader!
	@IBOutlet weak var numInvitesButton: UIButton!
	@IBOutlet weak var numGroupsButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setButtonViews()
    }
	@IBAction func goBack(_ sender: Any) {
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let vc = storyboard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else {
			print("**Could not instantiate viewController")
			return
		}
//		let vc = HomeViewController(name: "HomeViewController", bundle: nil)
		
		vc.modalPresentationStyle = .fullScreen
		
		self.present(vc, animated: true, completion: nil)
	}
	func setButtonViews() {
		backButton.setTitle("", for: .normal)
		backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		
		homeButton.setTitle("", for: .normal)
		
		numGroupsButton.setTitleColor(.black, for: .normal)
		numGroupsButton.layer.backgroundColor = UIColor(named: "UIGreen")?.cgColor
		numGroupsButton.layer.cornerRadius = 5
		let numGroups = groupList.count
		numGroupsButton.setTitle("\(numGroups) Groups", for: .normal)
		
		numInvitesButton.setTitleColor(.label, for: .normal)
		numInvitesButton.layer.borderColor = UIColor.darkGray.cgColor
		numInvitesButton.layer.cornerRadius = 5
		numInvitesButton.layer.borderWidth = 1
		numInvitesButton.layer.backgroundColor = UIColor.clear.cgColor
		let numInvites = groupList.count
		numInvitesButton.setTitle("\(numInvites) Invites", for: .normal)
		numInvitesButton.setImage(UIImage(systemName: "bell"), for: .normal)
	}
}
