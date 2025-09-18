//
//  Event.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 6/16/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

///An array of ProjdularEvents
var eventList = [ProjdularEvent]()
var pendingEventList = [ProjdularEvent]()

///The definition of a ProdjularEvent.
struct ProjdularEvent : Equatable {
	var id: String
	let nameOfEvent: String
	var startDate: Date!
	var endDate: Date!
	var tagName: String
	var tagColor: String?
//	var type: String?
//	var scheduleRange: Int?
//	var scheduleRangeStartDate: Date!
	var description: String?
//	var location: String
//	var eventMembers: [EventMember]
}

struct EventMember : Equatable {
	var userID: String
	let isAttending: Bool
	let profilePhotoURL: String
	let submittedTimesID: String
}

protocol eventServiceDelegate {
	func logicForDeletingTableViewCell(databaseManager: eventService, indexPath: IndexPath)
	func eventListDidLoad(events: [ProjdularEvent])
	func pendingEventListDidLoad(events: [ProjdularEvent])
	func didReceiveError(error: Error)
}

final class eventService {
	static let shared = eventService()
	
	var delegate: eventServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserEvents(for eventID: String) {
		stopObserving()
		let eventsRef = database.child("events").child(eventID)
		
		let valueObserver = eventsRef.observe(.value) {[weak self] snapshot in
			if(!snapshot.exists()) {
				let existingIndex = eventList.firstIndex(where: {$0.id == snapshot.key})
				let pendingExistingIndex = pendingEventList.firstIndex(where: {$0.id == snapshot.key})
				if(existingIndex != nil) {
					print("\n\n**eventList before: \(eventList)\n\n")
					eventList.remove(at: existingIndex!)
					print("**eventList: \(eventList)\n\n")
				}
				if (pendingExistingIndex != nil) {
					print("\n\n**pendingEventList before: \(pendingEventList)\n\n")
					pendingEventList.remove(at: existingIndex!)
					print("**pendingEventList: \(pendingEventList)\n\n")
				}
				self!.stopObserving()
			} else {
				self?.handleInitialLoad(snapshot)
			}
		}
		observers.append(valueObserver)
	}
	
	private func handleInitialLoad(_ snapshot: DataSnapshot) {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
		let impossibleStartDate = dateFormatter.date(from: "January 1, 2000 at 12:00:00 AM PDT")
		
//		if let event = parseEvent(from: snapshot as? DataSnapshot) {
//			if(event.startDate == impossibleStartDate) {
//				let existingIndex = pendingEventList.firstIndex(where: {$0.id == snapshot.key})
//				if(existingIndex == nil) {
//					pendingEventList.append(event)
//				} else {
//					pendingEventList[existingIndex!] = event
//				}
//				pendingEventList.sort{$0.startDate < $1.startDate}
//				DispatchQueue.main.async {
//					self.delegate?.pendingEventListDidLoad(events: eventList)
//				}
//			} else {
//				let existingIndex = eventList.firstIndex(where: {$0.id == snapshot.key})
//				if(existingIndex == nil) {
//					eventList.append(event)
//				} else {
//					eventList[existingIndex!] = event
//				}
//				eventList.sort{$0.startDate < $1.startDate}
//				DispatchQueue.main.async {
//					self.delegate?.eventListDidLoad(events: eventList)
//				}
//			}
//		}
	}
	
//	private func parseEvent(from snapshot: DataSnapshot?) -> ProjdularEvent? {
//		guard let snapshot = snapshot,
//			  let eventID = snapshot.key as String?,
//			  let data = snapshot.value as? [String: Any] else {
//			return nil
//		}
//		
//		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
//		
//		let nameOfEvent = data["name"] as? String ?? ""
//		let startDate = data["startDate"] as? String ?? "January 1, 2000 at 12:00:00 AM PDT"
//		let endDate = data["endDate"] as? String ?? "January 1, 2000 at 12:00:00 AM PDT"
//		let type = data["type"] as? String ?? "week"
//		let scheduleRange = data["scheduleRange"] as? Int ?? 1
//		let scheduleRangeStartDate = data["scheduleRangeStartDate"] as? String ?? dateFormatter.string(from: Date())
//		let description = data["description"] as? String ?? ""
//		let location = data["location"] as? String ?? ""
//		let eventMembers = data["members"] as? [String:Any] ?? [:]
//		
//		var members: [EventMember] = []
//		for(userID, value) in eventMembers {
//			if let memberData = value as? [String: Any],
//			   let isAttending = memberData["isAttending"] as? Bool,
//			   let profilePhotoURL = memberData["profilePhotoURL"] as? String,
//			   let submittedTimesID = memberData["submittedTimesID"] as? String {
//				members.append(EventMember(userID: userID, isAttending: isAttending, profilePhotoURL: profilePhotoURL, submittedTimesID: submittedTimesID))
//			}
//		}
//		
//		return ProjdularEvent(
//			id: eventID,
//			nameOfEvent: nameOfEvent,
//			startDate: dateFormatter.date(from: startDate), // Fetch from users node
//			endDate: dateFormatter.date(from: endDate),
//			type: type,
//			scheduleRange: scheduleRange,
//			scheduleRangeStartDate: dateFormatter.date(from: scheduleRangeStartDate),
//			description: description,
//			location: location,
//			eventMembers: members
//		)
//	}
	
	func stopObserving() {
		observers.forEach { handle in
			database.removeObserver(withHandle: handle)
		}
		observers.removeAll()
		eventList.removeAll()
		pendingEventList.removeAll()
	}
	
	///Returns a list of all events on a given date
	public func eventsForDate(parDate: Date) -> [ProjdularEvent] {
		var daysEvents = [ProjdularEvent]()
		for event in eventList {
			let eventDate = calendar.dateComponents([.day, .month, .year], from: event.startDate)
			let parDateC = calendar.dateComponents([.day, .month, .year], from: parDate)
			if(eventDate == parDateC) {
				daysEvents.append(event)
				//print("--addedEvent")
			}
		}
		return daysEvents
	}
	
	///Writes the new event into the firebase database.
	public func eventUpdateAndWrite(with event: ProjdularEvent, isWriteNotUpdate: Bool) {
		let dateformat = DateFormatter()
		dateformat.dateStyle = .long
		dateformat.timeStyle = .long
		var key: String
		if(isWriteNotUpdate == true) {
			//create a key in .child("events") to ensure the key is not a duplicate key. This line of code does not determine where the updates occur.
			guard let newKey = database.child("events").childByAutoId().key else {return}
			
			key = newKey
		} else {
			key = event.id
		}
		//create a group object that will be written to the database
		let event = ["name": event.nameOfEvent,
					 "startDate": dateformat.string(from: event.startDate),
					 "endDate": dateformat.string(from: event.endDate),
					 "tagName": event.tagName,
					 "tagColor": event.tagColor,
//					 "type": event.type,
//					 "scheduleRange": event.scheduleRange,
//					 "schedulerangeStartDate": dateformat.string(from: event.scheduleRangeStartDate),
					 "description": event.description,
//					 "location": event.location,
//					 "members": event.eventMembers] as [String:Any]
					 ]
		
		//create a list of paths to update
		let childUpdates = ["/events/\(key)":event]
		
		//update occurs here
		database.updateChildValues(childUpdates) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				print("\n\n**Data saved successfully at \(database.url).\n\n")
			}
		}
	}
	
	///Deletes event
	public func deleteEventFromUIView(with event: ProjdularEvent, indexPath: IndexPath) {
		/*self.database.ref.child("users/\(Auth.auth().currentUser!.uid)/events/\(String(describing: event.id))").removeValue() {_,_ in
		 print("--LogicForDeletingTableViewCell about to be called")
		 self.delegate?.logicForDeletingTableViewCell(self, indexPath: indexPath)
		 print("--at the end")
		 }*/
		database.child("events").child(String(describing: event.id)).setValue(nil) {
			(error: Error?, ref: DatabaseReference) in
			if let error = error {
				print("**Data could not be saved: \(error).")
			} else {
				self.delegate?.logicForDeletingTableViewCell(databaseManager: self, indexPath: indexPath)
				print("**Data saved successfully!")
			}
			
		}
	}
	
	public func eventDelete(with eventID: String) {
		database.child("events").child(eventID).setValue(nil) { error, database in
			if let error = error {
				print("\n\n**Data could not be saved: \(error).\n\n")
			} else {
				print("\n\n**Data saved successfully at \(database.url)\n\n")
			}
		}
	}
}
