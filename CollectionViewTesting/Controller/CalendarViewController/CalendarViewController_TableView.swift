//
//  CalendarViewController_TableView.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 1/12/22.
//

import UIKit

//MARK: TableViewDataSource
extension CalendarViewController: UITableViewDataSource {
	///Determines the number of rows in each section of the tableView which is 	determined by the function eventsForDate which returns all the events that are associated with any givin date.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		eventsForTableViewCell = eventsForDate(parDate: selectedDate)
		
		if eventsForDate(parDate: selectedDate).isEmpty == false {
			return eventsForTableViewCell.count
		} else {
			return 0
		}
		
	}
	
	///Sets each row in the tableView after each reload of data.
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellOne = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableViewCell
		
		//		let majorStackViewConstraint: NSLayoutConstraint = cellOne.majorHorizontalStackView.widthAnchor.constraint(equalTo: tableView.widthAnchor, constant: 0)
		//		majorStackViewConstraint.isActive = true
		//		majorStackViewConstraint.identifier = "majorStackViewConstraint-width"
		
		eventsForTableViewCell = eventsForDate(parDate: selectedDate)
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			
			noEventsScheduledLabel.textColor = UIColor.placeholderText
			noEventsScheduledLabel.text = "no events scheduled"
			
			cellOne.TimeLabel.text = ""
			
			cellOne.ViewInTableViewCell.backgroundColor = .clear
			
		} else {
			
			noEventsScheduledLabel.text = ""
			
			cellOne.EventLabel.textColor = UIColor.label
			cellOne.EventLabel.text = eventsForTableViewCell[indexPath.item].nameOfEvent
			cellOne.descriptionLabel.textColor = UIColor.placeholderText
			cellOne.descriptionLabel.text = "\(String(describing: eventsForTableViewCell[indexPath.item].description!))"
			
			let temp = DateFormatter()
			temp.timeStyle = .short
			temp.dateStyle = .none
			
			cellOne.TimeLabel.text = temp.string(from: eventsForTableViewCell[indexPath.item].startDate)
			
			cellOne.ViewInTableViewCell.backgroundColor = UIColor(named: eventsForTableViewCell[indexPath.item].tagColor!)
			
		}
		return cellOne
	}
}

//MARK: TableViewDelegate
extension CalendarViewController: UITableViewDelegate, DatabaseManagerDelegate {
	func logicForDeletingTableViewCell(_ databaseManager: DatabaseManager, indexPath: IndexPath) {
		DispatchQueue.main.async {
			
			eventsForTableViewCell.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .fade)
			
			if(self.tableView.numberOfRows(inSection: 0) == 0) {
				self.noEventsScheduledLabel.text = "no events scheduled"
			}
		}
		
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if eventsForTableViewCell.isEmpty == true && indexPath.item == 0 {
			return false
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			DatabaseManager.shared.deleteEvent(with: eventsForTableViewCell[indexPath.item], indexPath: indexPath)
		}
	}
}

