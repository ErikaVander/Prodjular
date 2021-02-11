//
//  ViewController.swift
//  CollectionViewTesting
//
//  Created by Vanderhoff on 2/9/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{

    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setCellViews()
        
        //fillTitlesF(month: "Jan")
        fillMonth()
    }
    
    
    
    
    //Functions to create the calendar and scroll to other months
    
    func fillMonth()
    {
        num.removeAll()
        let daysInMonth = numDaysInMonth(date: selectedDate)
        let firstDayMonth = firstDayOfMonth(date: selectedDate)
        let startingSpaces = weekDay(date: firstDayMonth)
        
        var count: Int = 1
     
        while (count < 42)
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
    }
    
    func fillNextMonth()
    {
        selectedDate = minusMonth(date: selectedDate)
        fillMonth()
    }
    
    func fillPreviousMonth()
    {
        selectedDate = plusmonth(date: selectedDate)
        fillMonth()
    }
    
    
    
    
    
    //Setting up the Collection view
    
    func setCellViews() {
        let width = (collectionView.frame.size.width - 2)/8
        let height = (collectionView.frame.size.height - 2)/8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        collectionView.layer.cornerRadius = 5
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tempNum = num.count
        return tempNum
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let cellIndex = indexPath.item
        
        let tempString = num[cellIndex]
        
        cellOne.label.text = tempString
        
        return cellOne
    }

}

