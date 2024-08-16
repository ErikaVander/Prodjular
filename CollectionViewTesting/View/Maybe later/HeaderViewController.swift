//
//  HeaderViewViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 8/16/24.
//

import UIKit

class HeaderViewController: UIViewController {
	@IBOutlet var headerView: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

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
	
	func setHeaderViewControllerConstraints() {
		headerView.heightAnchor.constraint(equalToConstant: 50)
		
		let headerViewLeadingConstraint: NSLayoutConstraint = headerView.leadingAnchor.constraint(equalTo: headerView.superview!.leadingAnchor, constant: 0)
		headerViewLeadingConstraint.isActive = true
		headerViewLeadingConstraint.identifier = "headerView-Leading"
		
		let headerViewTrailingConstraint: NSLayoutConstraint = headerView.trailingAnchor.constraint(equalTo: headerView.superview!.trailingAnchor, constant: 0)
		headerViewLeadingConstraint.isActive = true
		headerViewLeadingConstraint.identifier = "headerView-Trailing"
	}

}
