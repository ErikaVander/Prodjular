//
//  NewGroupViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/15/25.
//

import UIKit
import FirebaseAuth

class NewGroupViewController: UIViewController {
	var tempMembers: [String:[String:String]] = ["toRemove":[:]]
	
	var friendsTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Friend>!
	private var initialLoadOfFriends = true
	@IBOutlet weak var nameTF: UITextField!
	@IBOutlet weak var descriptionTF: PaddedTextField!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var addFriendsTable: GenericTableWithHeader!
	@IBOutlet weak var doneB: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("**Here")
		
		setButtonViews()
		setTableViews()
		setTableViewDelegateAndDataSource()
		setTextFieldDelegates()
		configureTableViewDataSources()
		setGroupServiceWriteDelegate()
        // Do any additional setup after loading the view.
    }
	@IBAction func goBack(_ sender: Any) {
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		self.view.window?.rootViewController?.dismiss(animated: true)
	}
	@IBAction func doneButtonPressed(_ sender: Any) {
		//Append yourself as admin.
		print("Admin name: \(currentUser!.userName) UserID: \(currentUser!.userID)")
		tempMembers.removeValue(forKey: "ToRemove")
		groupService.shared.groupUpdateAndWrite(with: ProjdularGroupDB(id: "", adminName: currentUser!.userName, adminID: currentUser!.userID, nameOfGroup: nameTF.text!, members: [currentUser!.userID:["name":currentUser!.userName]], pendingMembers: tempMembers, description: descriptionTF.text ?? ""), isWriteNotUpdate: true)
	}
	
	func setButtonViews() {
		backButton.setTitle("", for: .normal)
		backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		
		homeButton.setTitle("", for: .normal)
		homeButton.setImage(UIImage(systemName: "house"), for: .normal)
		
		doneB.layer.cornerRadius = 10
		
		doneB.isEnabled = false
	}
}

extension NewGroupViewController: GenericTableWithHeaderDelegate, UITableViewDelegate {
	func setGenericTableWithHeaderView() {
		print("**Hello")
	}
	
	func plusButtonTappedLogic() {
		print("**Hello 2")
	}
	
	func searchButtonTappedLogic() {
		print("**Hello 3")
	}
	
	enum Section {
		case main
	}
	func setTableViewDelegateAndDataSource() {
		friendService.shared.startObservingFriends(for: Auth.auth().currentUser!.uid)
		friendService.shared.delegate = self
		
		addFriendsTable.delegate = self
		addFriendsTable.tableView.delegate = self
		
		addFriendsTable.tableView.register(UINib(nibName: "FriendsTableViewTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsTableCell")
	}
	func setTableViews() {
		addFriendsTable.headerLabel.text = "Add Friends to Group"
		addFriendsTable.addPlusAndSearchButton()
		
		addFriendsTable.tableView.allowsMultipleSelection = true
	}
	func configureTableViewDataSources() {
		print("**Here 2")
		friendsTableViewDiffableDataSource = UITableViewDiffableDataSource(tableView: addFriendsTable.tableView) { [self] (tableView, indexPath, friend) -> UITableViewCell? in
			print("**Here 3")
			let cellOne = self.addFriendsTable.tableView.dequeueReusableCell(withIdentifier: "friendsTableCell", for: indexPath) as! FriendsTableViewTableViewCell
			
			print("**friend: \(friend)")
			
			cellOne.nameLabel.text = friend.userName
			cellOne.emailLabel.text = friend.email
			if(initialLoadOfFriends == true) {
				userService.shared.loadProfilePhoto(for: friend.id, completion: { [weak self] result in
					switch result {
					case .success(let image):
						cellOne.friendProfilePhoto.image = image
					case .failure(let error):
						print("**error: ", error)
					}
				})
				print("--initialLoadingOfDataForFriendTableView == true")
				self.initialLoadOfFriends = false
			} else {
				userService.shared.loadProfilePhotoWithCaching(for: friend.id, completion: { [weak self] result in
					switch result {
					case .success(let image):
						cellOne.friendProfilePhoto.image = image
					case .failure(let error):
						print("**error: ", error)
					}
				})
				print("--initialLoadingOfDataForFriendTableView == false")
			}
			cellOne.friendProfilePhoto.layer.cornerRadius = (self.addFriendsTable.tableView.frame.width/5.5)/2
			cellOne.setFriend(friend: friend)
			print("friend set: \(cellOne.getFriend())")
			
			return cellOne
		}
		print("**Here 4 \(String(describing: friendsTableViewDiffableDataSource))")
	}
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		let cellOne = self.addFriendsTable.tableView.dequeueReusableCell(withIdentifier: "friendsTableCell", for: indexPath) as! FriendsTableViewTableViewCell
//		if cellOne.isSelected {
//			cellOne.setSelected(true, animated: true)
//		} else {
//			cellOne.setSelected(false, animated: false)
//		}
//	}
	func applyFriendsSnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Friend>()
		snapshot.appendSections([.main])
		snapshot.appendItems(friendList)
		friendsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: !initialLoadOfFriends) { [weak self] in
			guard let self = self else {return}
//			initialLoadOfFriends = false
			let rowCount = friendList.count
			
			self.addFriendsTable.tableView.isScrollEnabled = rowCount > 1
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("**HereHere")
		
		if let cell = tableView.cellForRow(at: indexPath) {
			if let customCell = cell as? FriendsTableViewTableViewCell {
				print("customCell: \(customCell.friend)")
				tempMembers[customCell.friend.id] = ["name":customCell.friend.userName]
				print("**customCell done")
			}
		}
		
		print("**members select: \(String(describing: tempMembers))")
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		print("**HereHere")
//		tableView.cellForRow(at: indexPath)?.accessoryType = .none
//		print("**HereHere")
		
		if let cell = tableView.cellForRow(at: indexPath) {
			if let customCell = cell as? FriendsTableViewTableViewCell {
				print("customCell: \(customCell.friend)")
				tempMembers.removeValue(forKey: customCell.friend.id)
				print("**members deselect: \(tempMembers)")
			}
		}
	}

}

extension NewGroupViewController: friendServiceDelegate {
	func logicForDeletingFriendTableViewCell(_ databaseManager: friendService, indexPath: IndexPath) {
		print("**Logic for deleting tableview cell")
	}
	
	func friendWasFetched() {
		print("**Friend was fetched")
		applyFriendsSnapshot()
	}
}

extension NewGroupViewController: UITextFieldDelegate {
	func setTextFieldDelegates() {
		nameTF.delegate = self
		descriptionTF.delegate = self
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if(textField == nameTF) {
			textField.resignFirstResponder()
			descriptionTF.becomeFirstResponder()
			if(nameTF.text?.isEmpty == false) {
				doneB.isEnabled = true
			} else {
				doneB.isEnabled = false
			}
		} else if(textField == descriptionTF) {
			textField.resignFirstResponder()
			if(nameTF.text?.isEmpty == false) {
				doneB.isEnabled = true
			} else {
				doneB.isEnabled = false
			}
		}
		return true
	}
}

extension NewGroupViewController: groupServiceWriteDelegate {
	func setGroupServiceWriteDelegate() {
		groupService.shared.writeDelegate = self
	}
	func groupWasWritten(_success: Bool) {
		if(_success == true) {
			alertUserAndGoBack(view: self, title: "Success", content: "Successfully created new group.", dismissView: true)
		} else {
			alertUserAndGoBack(view: self, title: "Failed", content: "Failed to create new group. Please try again.", dismissView: true)
		}
	}
}
