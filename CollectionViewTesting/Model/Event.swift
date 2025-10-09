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
//	var tagName: String
	var tagColor: String?
	var type: String?
	var scheduleRange: Int?
	var scheduleRangeStartDate: Date!
	var description: String?
	var location: String
	var eventMembers: [EventMember]
}

struct EventMember : Equatable {
	var userID: String
	let isAttending: Bool
	let profilePhotoURL: String
	let didSubmitTimes: Bool
	let submittedTimes: [String: String]
}

protocol EventServiceDelegate {
	func logicForDeletingTableViewCell(databaseManager: EventService, indexPath: IndexPath)
	func eventDidLoad(event: ProjdularEvent)
	func pendingEventListDidLoad(events: [ProjdularEvent])
	func didReceiveError(error: Error)
}

final class EventService {
	static let shared = EventService()
	
	var delegate: EventServiceDelegate?
	
	private let database = Database.database().reference()
	private var observers: [DatabaseHandle] = []
	
	func startObservingUserEvents(for eventID: String) {
		stopObserving()
		let eventsRef = database.child("events").child(eventID)
		
		let valueObserver = eventsRef.observe(.value) {[weak self] snapshot in
			self?.handleInitialLoad(snapshot)
		}
		observers.append(valueObserver)
	}
	
	private func handleInitialLoad(_ snapshot: DataSnapshot) {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
		let impossibleStartDate = dateFormatter.date(from: "January 1, 2000 at 12:00:00 AM PDT")
		
		if let event = parseEvent(from: snapshot as? DataSnapshot) {
			DispatchQueue.main.async {
				self.delegate?.eventDidLoad(event: event)
			}
		}
	}
	
	private func parseEvent(from snapshot: DataSnapshot?) -> ProjdularEvent? {
		guard let snapshot = snapshot,
			  let eventID = snapshot.key as String?,
			  let data = snapshot.value as? [String: Any] else {
			return nil
		}
		let dateFormatter = DateFormatter()
		
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.locale = .current
		dateFormatter.timeZone = .current
		dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a zzz"
		
		let nameOfEvent = data["name"] as? String ?? ""
		let startDate = data["startDate"] as? String ?? "January 1, 2000 at 12:00:00 AM UTC"
		let endDate = data["endDate"] as? String ?? "January 1, 2000 at 12:00:00 AM UTC"
		let tagColor = data["tagColor"] as? String ?? ""
		let type = data["type"] as? String ?? "week"
		let scheduleRange = data["scheduleRange"] as? Int ?? 1
		let scheduleRangeStartDate = data["scheduleRangeStartDate"] as? String ?? dateFormatter.string(from: Date())
		let description = data["description"] as? String ?? ""
//		let location = data["location"] as? String ?? ""
		let address = data["address"] as? String ?? ""
		let city = data["city"] as? String ?? ""
		let state = data["state"] as? String ?? ""
		let zip = data["zip"] as? Int ?? 0
		let eventMembers = data["members"] as? [String:Any] ?? [:]
		let submittedTimes = data["submittedTimes"] as? [String: Any] ?? [:]
		
		var didSubmitTimes = false
		if(submittedTimes[Auth.auth().currentUser!.uid] != nil) {
			didSubmitTimes = true
		}
		print("**submittedTimes 1: \(submittedTimes) \(didSubmitTimes)")
		
		var members: [EventMember] = []
		for(userID, value) in eventMembers {
			if let memberData = value as? [String: Any],
			   let isAttending = memberData["isAttending"] as? Bool,
			   let profilePhotoURL = memberData["profilePhoto"] as? String {
				members.append(EventMember(userID: userID, isAttending: isAttending, profilePhotoURL: profilePhotoURL, didSubmitTimes: didSubmitTimes, submittedTimes: submittedTimes[userID] as? [String : String] ?? ["":""]))
			}
		}
		
		return ProjdularEvent(
			id: eventID,
			nameOfEvent: nameOfEvent,
			startDate: dateFormatter.date(from: startDate), // Fetch from users node
			endDate: dateFormatter.date(from: endDate),
			tagColor: tagColor,
			type: type,
			scheduleRange: scheduleRange,
			scheduleRangeStartDate: dateFormatter.date(from: scheduleRangeStartDate),
			description: description,
			location: "\(address)\n\(city) \(state) \(zip)",
			eventMembers: members
		)
	}
	
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
