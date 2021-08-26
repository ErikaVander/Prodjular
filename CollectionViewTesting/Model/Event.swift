//
//  Event.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 6/16/21.
//

import UIKit

///An array of ProjdularEvents
var eventList = [ProjdularEvent]()

///Adds an event to daysEvents which is an array of ProjdularEvents
func eventsForDate(parDate: Date) -> [ProjdularEvent] {
	
	var daysEvents = [ProjdularEvent]()
	for event in eventList
	{
		let eventDate = calendar.dateComponents([.day, .month, .year], from: event.date)
		let parDateC = calendar.dateComponents([.day, .month, .year], from: parDate)
		if(eventDate == parDateC)
		{
			daysEvents.append(event)
			//print("addedEvent")
		}
	}
	return daysEvents
}
