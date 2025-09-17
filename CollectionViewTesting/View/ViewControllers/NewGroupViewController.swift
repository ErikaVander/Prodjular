//
//  NewGroupViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/15/25.
//

import UIKit

class NewGroupViewController: UIViewController {
	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var homeButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setButtonViews()
        // Do any additional setup after loading the view.
    }
	@IBAction func goBack(_ sender: Any) {
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let vc = storyboard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else {
			return
		}
		
		vc.modalPresentationStyle = .fullScreen
		
		self.present(vc, animated: true, completion: nil)
	}
	func setButtonViews() {
		backButton.setTitle("", for: .normal)
		backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		
		homeButton.setTitle("", for: .normal)
		homeButton.setImage(UIImage(systemName: "house"), for: .normal)
		
		doneButton.layer.cornerRadius = 10
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
