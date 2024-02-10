//
//  TheData.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/10/21.
//

import Foundation

var numMonth: [String] = []
var numWeek: [String] = []

let calendar = Calendar.current

///Finds the date one month away from the given date
func plusmonth(date: Date) -> Date
{
    return calendar.date(byAdding: .month, value: 1, to: date)!
}

///Finds the date one week away from the given date
func plusWeek(date: Date) -> Date
{
	return calendar.date(byAdding: .weekOfYear, value: 1, to: date)!
}

///Finds the date one day after the given date
func plusDay(date: Date) -> Date
{
	return calendar.date(byAdding: .day, value: 1, to: date)!
}

///Finds the date one month before the given date
func minusMonth(date: Date) -> Date
{
    return calendar.date(byAdding: .month, value: -1, to: date)!
}

///Finds the date one week before the given date
func minusWeek(date: Date) -> Date
{
	return calendar.date(byAdding: .weekOfMonth, value: -1, to: date)!
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

func firstDayOfWeek(date: Date) -> Date
{
	if calendar.component(.weekday, from: date) != 1 {
		let firstDay: Date = calendar.nextDate(after: date, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)!
		return firstDay
	} else {
		return date
	}
}

///Filling the array numsMonth[]
func fillMonth(parDate: Date) {
	numMonth.removeAll()
	var x: Int = 0
	var startDate = minusMonth(date: parDate)
	while x < 3 {
		//print("x in loop: \(x)")
		let daysInMonth = numDaysInMonth(date: startDate)
		let firstDayMonth = firstDayOfMonth(date: startDate)
		let startingSpaces = weekDay(date: firstDayMonth)
		
		numMonth.append("SU")
		numMonth.append("MO")
		numMonth.append("TU")
		numMonth.append("WE")
		numMonth.append("TH")
		numMonth.append("FR")
		numMonth.append("SA")
		
		var count: Int = 1
		
		while (count < 43)
		{
			if (count <= startingSpaces || count - startingSpaces > daysInMonth)
			{
				numMonth.append("")
			}
			else
			{
				numMonth.append(String(count - startingSpaces))
			}
			count += 1
		}
		x  += 1
		startDate = plusmonth(date: startDate)
	}
	
	print("done with fillMonth")
}

///Filling the array numWeek[]
func fillWeek(parDate: Date) {
	numWeek.removeAll()

	let startDate = minusWeek(date: parDate)
	let firstDayWeek = firstDayOfWeek(date: startDate)
	
	var date: Date = firstDayWeek
	var count = 0
	while (count <= 20)
	{
		numWeek.append(String(dayOfMonth(date: date)))
		date = plusDay(date: date)
		count += 1
	}
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
	
	return returnDate!
}

func currentDateAndTime() -> Date {
	let month = calendar.component(.month, from: Date())
	let day = calendar.component(.day, from: Date())
	let year = calendar.component(.year, from: Date())
	
	let hour = calendar.component(.hour, from: Date())
	let minute = calendar.component(.minute, from: Date())
	
	return calendar.date(from: .init(timeZone: TimeZone(abbreviation: "UTC"), year: year, month: month, day: day, hour: hour, minute: minute))!
}
