//
//  CalendarViewController_Database.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 1/12/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseCore

//MARK: FirebaseRealtimeDatabase
extension CalendarViewController {
	///Getting all the events created by the user and storing them in eventList so that the table view can display them.
	func observeEvents() {
		let eventRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("events")
		
		eventRef.observe(.value, with: { snapshot in
			
			var tempEvents = [ProjdularEvent]()
			
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let id = childSnapshot.key as? String,
				   let dict = childSnapshot.value as? [String: Any]
				{
					let nameOfEvent = dict["name"] as? String ?? ""
					let startDate = dict["startDate"] as? String ?? "January 1, 2000 at 12:00:00 AM PDT"
					let endDate = dict["endDate"] as? String ?? "January 1, 2000 at 12:00:00 AM PDT"
//					let tagName = dict["tagName"] as? String ?? ""
					let tagColor = dict["tagColor"] as? String ?? ""
					let type = dict["type"] as? String ?? ""
					let scheduleRage = dict["scheduleRange"] as? Int ?? 1
					let scheduleRangeStartDate = dict["scheduleRangeStartDate"] as? String ?? ""
					let description = dict["description"] as? String
					let address = dict["address"] as? String ?? ""
					let city = dict["city"] as? String ?? ""
					let state = dict["state"] as? String ?? ""
					let zip = dict["zip"] as? Int ?? 00000
					let eventMembers = dict["members"] as? [String:Any] ?? [:]
				
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
				
					var members: [EventMember] = []
					for(userID, value) in eventMembers {
						if let memberData = value as? [String: Any],
						   let isAttending = memberData["isAttending"] as? Bool,
						   let profilePhotoURL = memberData["profilePhotoURL"] as? String,
						   let submittedTimesID = memberData["submittedTimesID"] as? String {
							members.append(EventMember(userID: userID, isAttending: isAttending, profilePhotoURL: profilePhotoURL, didSubmitTimes: true, submittedTimes: ["":""]))
						}
					}
					
				let event = ProjdularEvent(id: id, nameOfEvent: nameOfEvent, startDate: dateFormatter.date(from: startDate), endDate: dateFormatter.date(from: endDate), tagColor: tagColor, type: type, scheduleRange: scheduleRage, scheduleRangeStartDate: dateFormatter.date(from: scheduleRangeStartDate), description: description, address: address, city: city, state: state, zip: String(zip), eventMembers: members)
					
					tempEvents.append(event)
				}
			}
			eventList = tempEvents
			if(initialLoadingOfData == true) {
				self.tableView.reloadData()
				initialLoadingOfData = false
			}
			
			self.collectionView.reloadData()
			
			let dateToSelectPlusSeven = 7+weekDay(date: firstDayOfMonth(date: selectedDateCalendarViewController))+dayOfMonth(date: selectedDateCalendarViewController)
			
			self.collectionView.selectItem(at: IndexPath(item: (49+dateToSelectPlusSeven-1), section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.init(rawValue: UInt(dateToSelectPlusSeven)))
			
			previouslySelectedCellIndexPath = self.collectionView.indexPathsForSelectedItems?.first
		})
		
	}
	///Get all colors made by the user and stored on firebase by the current user.
	func observeColors() {
		let eventRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("colors")
		
		eventRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let dict = childSnapshot.value as? [String: Any],
				   let name = dict["name"] as? String,
				   let redValue = dict["redValue"] as? Float,
				   let blueValue = dict["blueValue"] as? Float,
				   let greenValue = dict["greenValue"] as? Float
				{
					ColorsArray.append(Colors(name: name, redValue: redValue, blueValue: blueValue, greenValue: greenValue))
				}
			}
		})
	}
	func observeUserSettings() {
		let settingsRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("userSettings")
		
		settingsRef.observe(.value, with: { snapshot in
			for child in snapshot.children {
				if let childSnapshot = child as? DataSnapshot,
				   let dict = childSnapshot.value as? [String: Any],
				   let autoBreakLength = dict["autoBreakLength"] as? Float,
				   let autoPrepLength = dict["autoPrepLength"] as? Float,
				   let addNewDirection = dict["addNewDirection"] as? String,
				   let autoWorkDays = dict["autoWorkDays"] as? [String]
				{
				currentUserSettings = SettingsHelper.init(autoBreakLength: autoBreakLength, autoPrepLength: autoPrepLength, addNewDirection: addNewDirection, autoWorkDays: autoWorkDays)
				}
			}
		})
	}
}


