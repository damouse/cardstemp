//
//  Views.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 10/9/15.
//  Copyright © 2015 paradrop. All rights reserved.
//
//  This is UI and UX code. It does not rely on any fabric functionality.

import Foundation
import Riffle
import RMSwipeTableViewCell
import M13ProgressSuite


class CardTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource, RMSwipeTableViewCellDelegate {
    var cards: [Card] = []
    var table: UITableView
    var parent: GameViewController
    
    
    init(tableview: UITableView!, parent p: GameViewController) {
        table = tableview
        parent = p
        super.init()
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 100
        table.rowHeight = UITableViewAutomaticDimension
    }
    
    func setTableCards(newCards: [Card]) {
        cards = newCards
        table.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("card") as! CardCell
        cell.delegate = self
        cell.labelTitle.text = cards[indexPath.row].text
        
        let backView = UIView(frame: cell.frame)
        backView.backgroundColor = UIColor.clearColor()
        cell.backgroundView = backView
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backViewbackgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func swipeTableViewCell(swipeTableViewCell: RMSwipeTableViewCell!, didSwipeToPoint point: CGPoint, velocity: CGPoint) {
        let cell = swipeTableViewCell as! CardCell
        
        let index = table.indexPathForCell(cell)
        let card = cards[index!.row]
        
        // right side selection
        if point.x >= MAX || point.x <= (-1 * MAX) {
            // reset the cell
            cell.resetContentView()
            cell.interruptPanGestureHandler = true
            parent.playerSwiped(card)
        }
        
        // Left side selection. Defer for now, although this should represent a "rejection" when choosing
    }
    
    //MARK: Utility
    func removeCellsExcept(keep: [Card]) {
        // removes all cards from the tableview and the table object except those passed
        
        var ret: [NSIndexPath] = []
        
        for i in 0...(cards.count - 1) {
            if !keep.contains(cards[i]) {
                ret.append(NSIndexPath(forRow: i, inSection: 0))
            }
        }
        
        cards = keep
        table.deleteRowsAtIndexPaths(ret, withRowAnimation: .Left)
    }
}

class PlayerCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate  {
    var players: [Player] = []
    var collection: UICollectionView
    var parent: GameViewController
    
    
    init(collectionview: UICollectionView, parent p: GameViewController) {
        collection = collectionview
        parent = p
        super.init()
        
        collection.delegate = self
        collection.dataSource = self
    }
    
    func playersChanged(incoming: [Player]) {
        players = incoming
        collection.reloadData()
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("player", forIndexPath: indexPath) as! PlayerCell
        let player = players[indexPath.row]
        
        cell.labelName.text = player.domain.stringByReplacingOccurrencesOfString("pd.demo.cardsagainst.", withString: "")
        cell.labelScore.text = "\(player.score)"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2, height: 100)
    }
}


class CardCell: RMSwipeTableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewHolder: UIView!
    
    func resetContentView() {
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.contentView.frame = CGRectOffset(self.contentView.bounds, 0.0, 0.0)
        }) { (b: Bool) -> Void in
            self.shouldAnimateCellReset = true
            self.cleanupBackView()
            self.interruptPanGestureHandler = false
            self.panner.enabled = true
        }
    }
}

class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelScore: UILabel!
}


class TickingView: M13ProgressViewBar {
    // A simple subclass that ticks down when given a time
    var timer: NSTimer?
    var current: Double = 1.0
    var increment: Double = 0.1
    let tickRate = 0.1
    
    func countdown(time: Double) {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }

        self.primaryColor = UIColor.whiteColor()
        self.secondaryColor = UIColor.blackColor()
        
        increment = tickRate / time
        current = 1.0
        self.setProgress(CGFloat(current), animated: true)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(tickRate, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    func tick() {
        current -= increment
        
        if current <= 0 {
            timer?.invalidate()
            timer = nil
            current = 1.0
        } else {
            self.setProgress(CGFloat(current), animated: true)
        }
    }
}


//MARK: General Utility
func flashCell(target: Player, model: [Player], collection: UICollectionView) {
    var index = -1
    
    for i in 0...model.count {
        if model[i] == target {
            index = i
            break
        }
    }
    
    // Why does this fail?
//    let index = model.indexOf(target)
    
    let cell = collection.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
    UIView.animateWithDuration(0.15, animations: { () -> Void in
        cell?.backgroundColor = UIColor.whiteColor()
    }) { (_ :Bool) -> Void in
        cell?.backgroundColor = UIColor.blackColor()
    }
}


