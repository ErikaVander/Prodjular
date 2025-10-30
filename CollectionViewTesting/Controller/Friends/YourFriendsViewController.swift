//
//  YourFriendsViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/15/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

var initialLoadingOfDataForFriendsTableView = true

class YourFriendsViewController: UIViewController {
	
	@IBOutlet weak var friendReqButton: UIButton!
	@IBOutlet var YourFriendsContainerView: UIView!
	@IBOutlet weak var footerButtonContainerView: UIView!
	@IBOutlet weak var footerContainerView: UIView!
	@IBOutlet weak var headerContainerView: UIView!
	@IBOutlet weak var friendsTableView: UITableView!
	@IBOutlet weak var addFriends: UIButton!
	@IBOutlet weak var backButton: NSLayoutConstraint!
	
	private let refreshControl = UIRefreshControl()
	
	deinit {
		let friendRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
		friendRef.removeAllObservers()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setHeaderContainerViewLook()
		setFooterContainerViewLook()
		
		addFriends.setTitle("", for: .normal)
		
		//Registering xib files
		friendsTableView.register(UINib(nibName: "FriendsTableViewTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsTableCell")
		friendsTableView.register(UINib(nibName: "EmptyFriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyFriendsTableViewCell")
		
		friendsTableView.dataSource = self
		friendsTableView.delegate = self
		
		friendService.shared.delegate = self
		
		friendsTableView.translatesAutoresizingMaskIntoConstraints = false
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		friendsTableView.estimatedRowHeight = 200
		friendsTableView.rowHeight = UITableView.automaticDimension
		friendsTableView.reloadData()
		
		friendService.shared.startObservingFriends(for: Auth.auth().currentUser!.uid)
	}
	
	///Goes back to the settings page
	@IBAction func backToSettings(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func setHeaderContainerViewLook() {
		headerContainerView.layer.shadowOffset = .zero
		headerContainerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 25, width: headerContainerView.frame.width, height: headerContainerView.frame.height/2)).cgPath
		headerContainerView.layer.shadowOpacity = 0.5
		headerContainerView.layer.shadowRadius = 3
		headerContainerView.layer.shadowColor = UIColor.label.cgColor
		
		headerContainerView.layer.shouldRasterize = true
		headerContainerView.layer.rasterizationScale = UIScreen.main.scale
		friendsTableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
	}
	
	func setFooterContainerViewLook() {
		footerButtonContainerView.backgroundColor = UIColor.clear
		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(roundedRect: footerContainerView.bounds, byRoundingCorners: .topLeft, cornerRadii: CGSize(width: 20, height: 20)).cgPath
		footerContainerView.layer.mask = maskLayer
		
		
		let outerView = UIView(frame: CGRect(origin: footerContainerView.frame.origin, size: CGSize(width: footerContainerView.frame.width + 10.0, height: footerContainerView.frame.height + 10.0)))
		outerView.backgroundColor = .clear
		
		
		outerView.layer.shadowColor = UIColor.label.cgColor
		outerView.layer.shadowOpacity = 0.5
		outerView.layer.shadowOffset = .zero
		outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, byRoundingCorners: .topLeft, cornerRadii: CGSize(width: 20, height: 20)).cgPath
		YourFriendsContainerView.addSubview(outerView)
		outerView.addSubview(footerContainerView)
	}
}

//MARK: TableViewDataSource
extension YourFriendsViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(section == 0) {
			if friendReqSent.isEmpty == false {
				return friendReqSent.count + 1
			} else {
				return 1
			}
		} else {
			if friendList.isEmpty == false {
				return friendList.count + 1
			} else {
				return 1
			}
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if(section == 0){
			return "Pending Requests"
		} else {
			return "Friends"
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print("**friends: \(friendList)")
		let cellOne = friendsTableView.dequeueReusableCell(withIdentifier: "friendsTableCell", for: indexPath) as! FriendsTableViewTableViewCell
		let cellTwo = friendsTableView.dequeueReusableCell(withIdentifier: "emptyFriendsTableViewCell", for: indexPath) as! EmptyFriendsTableViewCell
		if (tableView.numberOfRows(inSection: 0) == 0 && tableView.numberOfRows(inSection: 1) == 0 && tableView.numberOfRows(inSection: 2) == 0) {
		} else {
			if(indexPath.section == 0)
			{
				if(self.friendsTableView.numberOfRows(inSection: 0) == 1) {
					cellTwo.setNeedsLayout()
						
					cellTwo.emptyLabel.text = "No pending requests"
					cellTwo.emptyLabel.sizeToFit()
					cellTwo.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
					
					cellTwo.heightConstraint!.isActive = false
					cellTwo.heightConstraintEmpty!.isActive = true
					
					cellTwo.emptyLabelCenterXConstraint!.isActive = true
					cellTwo.emptyLabelCenterYConstraint!.isActive = true
					
					var emptyLabelWidth: NSLayoutConstraint
					emptyLabelWidth = cellTwo.containerView.widthAnchor.constraint(equalTo: cellTwo.widthAnchor, multiplier: 1)
					emptyLabelWidth.isActive = true
					
					cellTwo.layoutIfNeeded()
					
					return cellTwo
				} else {
					if(indexPath.item == friendReqSent.count) {
						cellTwo.emptyLabel.text = ""
						cellTwo.contentView.translatesAutoresizingMaskIntoConstraints = false
						
						cellTwo.heightConstraintEmpty!.isActive = false
						cellTwo.heightConstraint!.isActive = true
						
						return cellTwo
					} else {
						cellOne.nameLabel.text = friendReqSent[indexPath.item].userName
						cellOne.emailLabel.text = friendReqSent[indexPath.item].email
						if(initialLoadingOfDataForFriendsTableView == true) {
							userService.shared.loadProfilePhoto(for: friendReqSent[indexPath.item].id, completion: { [weak self] result in
								switch result {
								case .success(let image):
									cellOne.friendProfilePhoto.image = image
								case .failure(let error):
									print("**error: ", error)
								}
							})
							initialLoadingOfDataForFriendsTableView = false
						} else {
							userService.shared.loadProfilePhotoWithCaching(for: friendReqSent[indexPath.item].id, completion: { [weak self] result in
								switch result {
								case .success(let image):
									cellOne.friendProfilePhoto.image = image
								case .failure(let error):
									print("**error: ", error)
								}
							})
						}
						cellOne.friendProfilePhoto.layer.cornerRadius = (self.friendsTableView.frame.width/5.5)/2
						cellOne.setFriend(friend: friendReqSent[indexPath.item])
					}
				}
			} else if(indexPath.section == 1) {
				if(self.friendsTableView.numberOfRows(inSection: 1) == 1) {
					cellTwo.emptyLabel.text = "You have no friends"
					cellTwo.emptyLabel.sizeToFit()
					cellTwo.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
					
					cellTwo.heightConstraint!.isActive = false
					cellTwo.heightConstraintEmpty!.isActive = true
					
					cellTwo.emptyLabelCenterXConstraint!.isActive = true
					cellTwo.emptyLabelCenterYConstraint!.isActive = true
					
					var emptyLabelWidth: NSLayoutConstraint
					emptyLabelWidth = cellTwo.containerView.widthAnchor.constraint(equalTo: cellTwo.widthAnchor, multiplier: 1)
					emptyLabelWidth.isActive = true
					
					cellTwo.layoutIfNeeded()

					return cellTwo
				} else {
					if(indexPath.item == friendList.count) {
						cellTwo.emptyLabel.text = ""
						cellTwo.contentView.translatesAutoresizingMaskIntoConstraints = false
						
						cellTwo.heightConstraintEmpty!.isActive = false
						cellTwo.heightConstraint!.isActive = true
						
						return cellTwo
					} else {
						cellOne.nameLabel.text = friendList[indexPath.item].userName
						cellOne.emailLabel.text = friendList[indexPath.item].email
						if(initialLoadingOfDataForFriendsTableView == true) {
							userService.shared.loadProfilePhoto(for: friendList[indexPath.item].id, completion: { [weak self] result in
								switch result {
								case .success(let image):
									cellOne.friendProfilePhoto.image = image
								case .failure(let error):
									print("**error: ", error)
								}
							})
							print("--initialLoadingOfDataForFriendTableView == true")
							initialLoadingOfDataForFriendsTableView = false
						} else {
							userService.shared.loadProfilePhotoWithCaching(for: friendList[indexPath.item].id, completion: { [weak self] result in
								switch result {
								case .success(let image):
									cellOne.friendProfilePhoto.image = image
								case .failure(let error):
									print("**error: ", error)
								}
							})
							print("--initialLoadingOfDataForFriendTableView == false")
						}
						cellOne.friendProfilePhoto.layer.cornerRadius = (self.friendsTableView.frame.width/5.5)/2
						cellOne.setFriend(friend: friendList[indexPath.item])
					}
				}
			}
			
		}
		return cellOne
	}
	
	func setConstraintsForCell(indexPath: IndexPath) {
		let cell = self.friendsTableView.cellForRow(at: indexPath) as! EmptyFriendsTableViewCell
		if(indexPath.section == 0) {
			cell.emptyLabel.text = "no pending requests"
		} else {
			cell.emptyLabel.text = "you have no friends"
		}
	}
}
	


//MARK: TableViewDelegate
extension YourFriendsViewController: UITableViewDelegate, friendServiceDelegate {
	func friendWasFetched() {
		friendsTableView.reloadData()
		print("**friendWasFetched: \(friendList)")
	}
	
	func logicForDeletingFriendTableViewCell(_ databaseManager: friendService, indexPath: IndexPath) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {return}
			friendList.remove(at: indexPath.item)
			self.friendsTableView.deleteRows(at: [indexPath], with: .fade)
			self.friendsTableView.reloadData()
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if friendList.isEmpty == true && indexPath.item == 0 {
			return false
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if(indexPath.section == 0) {
				let cell = tableView.cellForRow(at: indexPath) as? FriendsTableViewTableViewCell
				let index = friendReqSent.firstIndex(of: cell!.friend)
				
				print("**cell: ", cell?.friend ?? "did not find a friend")
				
				friendService.shared.deleteFriendFromCell(with: friendReqSent[index!], indexPath: indexPath)
				friendReqSent.remove(at: index!)
				
			} else if(indexPath.section == 1) {
				let cell = tableView.cellForRow(at: indexPath) as? FriendsTableViewTableViewCell
				let index = friendList.firstIndex(of: cell!.friend)
				
				print("**cell: ", cell?.friend ?? "did not find a friend")
				
				friendService.shared.deleteFriendFromCell(with: friendList[index!], indexPath: indexPath)
				
			}
		}
	}
}
