//
//  TheData.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/10/21.
//

import Foundation

var num: [String] = []

let calendar = Calendar.current

///Finds the date one month away from the given date
func plusmonth(date: Date) -> Date
{
    return calendar.date(byAdding: .month, value: 1, to: date)!
}

///Finds the date one month before the given date
func minusMonth(date: Date) -> Date
{
    return calendar.date(byAdding: .month, value: -1, to: date)!
}

///Returns the number of days in the month of the date given
func numDaysInMonth(date: Date) -> Int
{
    let range = calendar.range(of: .day, in: .month, for: date)!
    return range.count
}

///Returns the string representation of the given date's month
func monthString(date: Date) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL"
    return dateFormatter.string(from: date)
}

///Returns the string form of the given date's year
func yearString(date: Date) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: date)
}

///Returns the integer of the given date's day
func dayOfMonth(date: Date) -> Int
{
    let components = calendar.dateComponents([.day], from: date)
    return components.day!
}

///Returns the date given's weekday in integer form. (If Sunday than 0)
func weekDay(date: Date) ->  Int
{
	let theComponent = calendar.dateComponents([.weekday], from: date)
	return theComponent.weekday! - 1
}

///Returns the date of the first day of the month that the given date is contained in.
func firstDayOfMonth(date: Date) -> Date
{
	if calendar.component(.day, from: date) != 1 {
		let firstDay: Date = calendar.nextDate(after: date, matching: DateComponents(day: 1), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)!
		return firstDay
	} else {
		return date
	}
}

///Filling the array nums[] 
func fillMonth(parDate: Date)
{
	num.removeAll()
	var x: Int = 0
	var startDate = minusMonth(date: parDate)
	while x < 3 {
		//print("x in loop: \(x)")
		let daysInMonth = numDaysInMonth(date: startDate)
		let firstDayMonth = firstDayOfMonth(date: startDate)
		let startingSpaces = weekDay(date: firstDayMonth)
		
		num.append("SU")
		num.append("MO")
		num.append("TU")
		num.append("WE")
		num.append("TH")
		num.append("FR")
		num.append("SA")
		
		var count: Int = 1
		
		while (count < 43)
		{
			if (count <= startingSpaces || count - startingSpaces > daysInMonth)
			{
				num.append("")
			}
			else
			{
				num.append(String(count - startingSpaces))
			}
			count += 1
		}
		x  += 1
		startDate = plusmonth(date: startDate)
	}
	
	print("done with fillMonth")
}

///Enter a date in the format "M d, yyyy" or "1 21, 2001" to get a date in return
func dateFromNumbers(date: String) -> Date {
	
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "M d, yyyy"
	
	let returnDate = dateFormatter.date(from: date)
	
	return returnDate!
}

///Enter a date in the format "MMMM d, yyyy" or " August 21, 2001" to get a date in return
func dateFromNumbersAndMonthLabel(date: String) -> Date {
	
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "MMMM d, yyyy"
	
	let returnDate = dateFormatter.date(from: date)
	print("--returnDate: \(String(describing: returnDate))--")
	
	return returnDate!
}
