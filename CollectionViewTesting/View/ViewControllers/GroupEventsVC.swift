//
//  GroupEventsVC.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/15/25.
//

import UIKit

class GroupEventsVC: UIViewController {
	var groupID: String?
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setButtonViews()
		groupEventService.shared.startObservingGroupEvents(for: groupID!)
		print("**GroupID: \(groupID!)")
		groupEventService.shared.delegate = self
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	@IBAction func goBack(_ sender: Any) {
		groupEventService.shared.stopObserving()
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		groupEventService.shared.stopObserving()
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let vc = storyboard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else {
			print("**ERROR: Could not instantiate viewController")
			return
		}
		
		vc.modalPresentationStyle = .fullScreen
		
		self.present(vc, animated: true, completion: nil)
	}
	
	func setButtonViews() {
		homeButton.setTitle("", for: .normal)
		homeButton.setImage(UIImage(systemName: "house"), for: .normal)
		
		settingsButton.setTitle("", for: .normal)
		settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
		
		backButton.setTitle("", for: .normal)
		backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
	}
}
extension GroupEventsVC: GenericTableWithHeaderDelegate {

	func setGenericTableWithHeaderView() {
		print("**Hello")
	}
	
	func plusButtonTappedLogic() {
		print("**Hello 2")
	}
	
	func searchButtonTappedLogic() {
		print("**Hello 3")
	}
}
extension GroupEventsVC: groupEventServiceDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: groupEventService, indexPath: IndexPath) {
		print("**logic for deleting table view cell")
	}
	
	func groupEventWasAdded(_ event: groupEvent) {
		print("**group event was added \(event)")
	}
	
	func groupEventWasChanged(_ event: groupEvent, at index: Int) {
		print("**group event was changed \(event)")
	}
	
	func groupEventWasRemoved(at index: Int) {
		print("**group event was removed")
	}
	
	func didReceiveError(_ error: any Error) {
		print("**ERROR: \(error)")
	}
	
	
}
