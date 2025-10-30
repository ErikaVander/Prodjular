//
//  NewGroupViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 9/15/25.
//

import UIKit
import FirebaseAuth

class NewEventVC: UIViewController {
	var groupID: String = ""
	
	@IBOutlet weak var nameTF: UITextField!
	@IBOutlet weak var descriptionTF: PaddedTextField!
	@IBOutlet weak var streetTF: UITextField!
	@IBOutlet weak var cityTF: UITextField!
	@IBOutlet weak var stateTF: UITextField!
	@IBOutlet weak var zipTF: UITextField!
	@IBOutlet weak var startDateDP: UIDatePicker!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var homeButton: UIButton!
	@IBOutlet weak var doneB: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("**Here")
		
		setButtonViews()
		setTextFieldDelegates()
		setEventServiceWriteDelegate()
        // Do any additional setup after loading the view.
    }
	@IBAction func goBack(_ sender: Any) {
		self.dismiss(animated: true)
	}
	@IBAction func goHome(_ sender: Any) {
		self.view.window?.rootViewController?.dismiss(animated: true)
	}
	@IBAction func doneButtonPressed(_ sender: Any) {
		EventService.shared.eventUpdateAndWrite(with: ProjdularEvent(id: "", nameOfEvent: nameTF.text ?? "", startDate: startDateDP.date, address: streetTF.text ?? "No Address Provided", city: cityTF.text ?? "", state: stateTF.text ?? "", zip: zipTF.text ?? "", eventMembers: [], groupID: groupID), isWriteNotUpdate: true)
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

extension NewEventVC: UITextFieldDelegate {
	func setTextFieldDelegates() {
		nameTF.delegate = self
		descriptionTF.delegate = self
		streetTF.delegate = self
		cityTF.delegate = self
		stateTF.delegate = self
		zipTF.delegate = self
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
			streetTF.becomeFirstResponder()
			if(nameTF.text?.isEmpty == false) {
				doneB.isEnabled = true
			} else {
				doneB.isEnabled = false
			}
		} else if(textField == streetTF) {
			textField.resignFirstResponder()
			cityTF.becomeFirstResponder()
			if(nameTF.text?.isEmpty == false) {
				doneB.isEnabled = true
			} else {
				doneB.isEnabled = false
			}
		} else if(textField == cityTF) {
			textField.resignFirstResponder()
			stateTF.becomeFirstResponder()
			if(nameTF.text?.isEmpty == false) {
				doneB.isEnabled = true
			} else {
				doneB.isEnabled = false
			}
		} else if(textField == zipTF) {
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

extension NewEventVC: eventServiceWriteDelegate {
	func setEventServiceWriteDelegate() {
		EventService.shared.writeDelegate = self
	}
	func eventWasWritten(_success: Bool) {
		if(_success == true) {
			alertUserAndGoBack(view: self, title: "Success", content: "Successfully created new event.", dismissView: true)
		} else {
			alertUserAndGoBack(view: self, title: "Failed", content: "Failed to create new event. Please try again.", dismissView: true)
		}
	}
}
