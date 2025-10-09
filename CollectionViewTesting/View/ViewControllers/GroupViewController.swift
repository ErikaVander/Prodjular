//
//  GroupViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/3/25.
//

import UIKit
import FirebaseAuth

class GroupViewController: UIViewController {
	var cellHeight = 79.0
	private var groupInvitationsViewHeightConstraint: NSLayoutConstraint?
	var groupsTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, userGroup>!
	var invitationsTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, userPendingGroup>!
	private var initialLoadOfGroups = true
	private var initialLoadOfInvitations = true
	
	@IBOutlet weak var tableViewsContainerView: UIView!
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var groupInvitationsView: GenericTableWithHeader!
	@IBOutlet weak var groupsView: GenericTableWithHeader!
	@IBOutlet weak var numInvitesButton: UIButton!
	@IBOutlet weak var numGroupsButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setTableViewDelegateAndDataSource()
		setTableViewInitialHeight()
		setButtonViews()
		setTableViews()
		configureTableViewDataSources()
    }
	@IBAction func goBack(_ sender: Any) {
		userGroupService.shared.stopObserving()
		userPendingGroupService.shared.stopObserving()
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		userGroupService.shared.stopObserving()
		userPendingGroupService.shared.stopObserving()
		self.view.window?.rootViewController?.dismiss(animated: true)
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

extension GroupViewController: GenericTableWithHeaderDelegate, GenericTCADelegate {
	enum Section {
		case main
	}
	func setTableViewDelegateAndDataSource() {
		userGroupService.shared.delegate = self
		userGroupService.shared.startObservingUserGroups(for: Auth.auth().currentUser!.uid)
		
		userPendingGroupService.shared.delegate = self
		userPendingGroupService.shared.startObservingUserPendingGroups(for: Auth.auth().currentUser!.uid)
		
		groupInvitationsView.delegate = self
		groupsView.delegate = self
		
		groupsView.tableView.register(UINib(nibName: "GenericTCA", bundle: nil), forCellReuseIdentifier: "genericTCA")
	}
	func setTableViews() {
		groupsView.headerLabel.text = "Groups"
		groupsView.addPlusAndSearchButton()
		
		groupInvitationsView.headerLabel.text = "Group Invitations"
		groupInvitationsView.tableView.register(UINib(nibName: "GenericTCA", bundle: nil), forCellReuseIdentifier: "genericTCA")
		groupInvitationsView.addHideButton()
	}
	func configureTableViewDataSources() {
		groupsTableViewDiffableDataSource = UITableViewDiffableDataSource(tableView: groupsView.tableView) { (tableView, indexPath, group) -> UITableViewCell? in
			let cellOne = self.groupsView.tableView.dequeueReusableCell(withIdentifier: "genericTCA", for: indexPath) as! GenericTCA
			cellOne.nameLabel.text = group.name
			cellOne.labelA.text = group.adminName
			cellOne.labelB.text = "\(group.numOfMembers) Members"
			self.cellHeight = cellOne.frame.height
			cellOne.hideButtonView()
			cellOne.showRightArrowButton()
			cellOne.objectID = group.id
			cellOne.delegate = self
			return cellOne
		}
		invitationsTableViewDiffableDataSource = UITableViewDiffableDataSource(tableView: groupInvitationsView.tableView) { (tableView, indexPath, pendingGroup) -> UITableViewCell? in
			let cellOne = self.groupInvitationsView.tableView.dequeueReusableCell(withIdentifier: "genericTCA", for: indexPath) as! GenericTCA
			cellOne.nameLabel.text = pendingGroup.name
			cellOne.labelA.text = pendingGroup.adminName
			cellOne.labelB.text = "\(pendingGroup.numOfMembers) Members"
			self.cellHeight = cellOne.frame.height
			cellOne.showButtonView()
			cellOne.hideRightArrowButton()
			cellOne.delegate = self
			return cellOne
		}
	}
	func setTableViewInitialHeight() {
		let initialHeight = (userPendingGroupsList.count <= 1) ? cellHeight : cellHeight + (cellHeight / 2)
		let newConstraint = groupInvitationsView.tableView.heightAnchor.constraint(equalToConstant: initialHeight)
		newConstraint.identifier = "groupInvitationsViewHeightConstraint"
		newConstraint.isActive = true
		self.groupInvitationsViewHeightConstraint = newConstraint
	}
	func applyInvitationsSnapshotAndAdjustHeight() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, userPendingGroup>()
		snapshot.appendSections([.main])
		if(groupInvitationsView.hideButtonP.title(for: .normal) == "hide") {
			snapshot.appendItems(userPendingGroupsList)
		}
		invitationsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: !initialLoadOfInvitations) { [weak self] in
			guard let self = self else {return}
			
			initialLoadOfInvitations = false
			let rowCount = userPendingGroupsList.count
			let newHeight: CGFloat
			let widthForInnerShadowFunc = groupInvitationsView.contentView.bounds.width
			let heightForInnerShadowFunc: CGFloat
			
			if (groupInvitationsView.hideButtonP.title(for: .normal) == "show") {
				newHeight = 0
				heightForInnerShadowFunc = groupsView.contentView.bounds.height + cellHeight
			} else if rowCount <= 1 {
				newHeight = self.cellHeight
				heightForInnerShadowFunc = groupInvitationsView.contentView.bounds.height + cellHeight
			} else {
				newHeight = 1.5 * self.cellHeight
				heightForInnerShadowFunc = groupInvitationsView.contentView.bounds.height + (cellHeight * 1.5)
			}
			
			CATransaction.begin()
			CATransaction.setCompletionBlock {
				UIView.animate(withDuration: 0.3) {
					self.groupInvitationsViewHeightConstraint?.constant = newHeight
					self.tableViewsContainerView.layoutIfNeeded()
				}
			}
			CATransaction.setDisableActions(true)
			if (groupInvitationsView.hideButtonP.title(for: .normal) == "show") {
				self.groupsView.setContentViewWithInnerShadow(width: widthForInnerShadowFunc, height: heightForInnerShadowFunc)
			} else {
				self.groupInvitationsView.setContentViewWithInnerShadow(width: widthForInnerShadowFunc, height: heightForInnerShadowFunc)
			}
			CATransaction.commit()
			
			self.groupInvitationsView.tableView.isScrollEnabled = rowCount > 1
		}
	}
	func applyGroupsSnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, userGroup>()
		snapshot.appendSections([.main])
		snapshot.appendItems(userGroupsList)
		groupsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: !initialLoadOfGroups) { [weak self] in
			guard let self = self else {return}
			initialLoadOfGroups = false
			let rowCount = userGroupsList.count
			
			self.groupInvitationsView.tableView.isScrollEnabled = rowCount > 1
		}
	}
	func setGenericTableWithHeaderView() {
		groupInvitationsView.tableView.beginUpdates()
		groupsView.tableView.beginUpdates()
		print("**Here here \(groupInvitationsView.hideButtonP?.title(for: .normal) == "hide")")
		if(userPendingGroupsList.count <= 1 && groupInvitationsView.hideButtonP?.title(for: .normal) == "hide") {
			self.groupInvitationsViewHeightConstraint?.constant = cellHeight
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.groupInvitationsView.setContentViewWithInnerShadow(width: self.groupInvitationsView.contentView.bounds.width, height: self.groupInvitationsView.contentView.bounds.height + cellHeight)
			CATransaction.commit()
		} else if (groupInvitationsView.hideButtonP?.title(for: .normal) == "hide") {
			print("**Here 2")
			self.groupInvitationsViewHeightConstraint?.constant = cellHeight+(cellHeight/2)
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.groupInvitationsView.setContentViewWithInnerShadow(width: self.groupInvitationsView.contentView.bounds.width, height: self.groupInvitationsView.contentView.bounds.height + cellHeight + (cellHeight/2))
			CATransaction.commit()
		} else {
			self.groupInvitationsViewHeightConstraint?.constant = 0
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.groupsView.setContentViewWithInnerShadow(width: self.groupsView.contentView.bounds.width, height: self.groupsView.contentView.bounds.height + cellHeight)
			CATransaction.commit()
		}
		print("**Subviews \(self.tableViewsContainerView.subviews)")
		self.tableViewsContainerView.setNeedsLayout()
		
		UIView.animate(withDuration: 0.3) {
			self.tableViewsContainerView.layoutIfNeeded()
		} completion: { _ in
			self.groupsView.setContentViewWithInnerShadow(width: self.groupsView.contentView.bounds.width, height: self.groupsView.contentView.bounds.height)
			self.groupInvitationsView.setContentViewWithInnerShadow(width: self.groupInvitationsView.contentView.bounds.width, height: self.groupInvitationsView.contentView.bounds.height)
			self.groupInvitationsView.tableView.endUpdates()
			self.groupsView.tableView.endUpdates()
		}
	}
	func plusButtonTappedLogic() {
		let vc = NewGroupViewController(nibName: "NewGroupViewController", bundle: nil)
		
		vc.modalPresentationStyle = .fullScreen
		
		userGroupService.shared.stopObserving()
		userPendingGroupService.shared.stopObserving()
		
		self.present(vc, animated: true, completion: nil)
		
		print("**plus button tapped logic")
		
	}
	func searchButtonTappedLogic() {
		print("**search button tapped logic")
	}
	func cellTappedLogic(objectID: String) {
		let vc = GroupEventsVC(nibName: "GroupEventsVC", bundle: nil)
		
		vc.modalPresentationStyle = .fullScreen
		vc.groupID = objectID
//		vc.numMembers = userGroupsList.first(where: {$0.id == objectID})?.numOfMembers
//		print("**numMembers: \(String(describing: userGroupsList.first(where: {$0.id == objectID})?.numOfMembers))")
		
		userGroupService.shared.stopObserving()
		userPendingGroupService.shared.stopObserving()
		
		self.present(vc, animated: true, completion: nil)
		print("**cell tapped logic")
	}
	func buttonTappedLogic() {
		print("**accept tapped logic")
	}
}

extension GroupViewController: userGroupServiceDelegate, userPendingGroupServiceDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: userPendingGroupService, indexPath: IndexPath) {
		groupInvitationsView.tableView.reloadData()
	}
	
	func userPendingGroupWasAdded(_ group: userPendingGroup) {
		numInvitesButton.setTitle("\(userPendingGroupsList.count) Invites", for: .normal)
		print("**ADDED: \(userPendingGroupsList.count)")
		applyInvitationsSnapshotAndAdjustHeight()
		print("**HERE: \(userPendingGroupsList.count)")
	}
	
	func userPendingGroupWasChanged(_ group: userPendingGroup, at index: Int) {
		numInvitesButton.setTitle("\(userPendingGroupsList.count) Invites", for: .normal)
		applyInvitationsSnapshotAndAdjustHeight()
	}
	
	func userPendingGroupWasRemoved(at index: Int) {
		numInvitesButton.setTitle("\(userPendingGroupsList.count) Invites", for: .normal)
		applyInvitationsSnapshotAndAdjustHeight()
	}
	
	func logicForDeletingTableViewCell(_ databaseManager: userGroupService, indexPath: IndexPath) {
		applyInvitationsSnapshotAndAdjustHeight()
	}
	
	func userGroupWasAdded(_ group: userGroup) {
		numGroupsButton.setTitle("\(userGroupsList.count) Groups", for: .normal)
		applyGroupsSnapshot()
	}
	
	func userGroupWasChanged(_ group: userGroup, at index: Int) {
		numGroupsButton.setTitle("\(userGroupsList.count) Groups", for: .normal)
		applyGroupsSnapshot()
	}
	
	func userGroupWasRemoved(at index: Int) {
		numGroupsButton.setTitle("\(userGroupsList.count) Groups", for: .normal)
		applyGroupsSnapshot()
	}
	
	func didReceiveError(_ error: any Error) {
		print("**ERROR: \(error)")
	}
}
