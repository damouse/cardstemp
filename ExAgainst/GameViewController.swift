//
//  GameViewController.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

/*
Musings:
Table allows touches and interactivity based on the current chooser and the phase

Collection always shows the players
The chooser is always highlighted
The winner blinks when selected
*/


import UIKit
import Riffle
import RMSwipeTableViewCell
import M13ProgressSuite

// Testing ui code
let MAX = CGFloat(70.0)


class GameViewController: UIViewController {
    
    @IBOutlet weak var viewProgress: TickingView!
    @IBOutlet weak var labelActiveCard: UILabel!
    @IBOutlet weak var tableCard: UITableView!
    @IBOutlet weak var collectionPlayers: UICollectionView!
    @IBOutlet weak var buttonBack: UIButton!
    
    var app: RiffleAgent!
    var room: RiffleAgent!
    var me: RiffleAgent!
    var currentPlayer = Player()
    
    
    // Migrations from the old delegate code
    var cards: [Card] = []
    
    
    override func viewWillAppear(animated: Bool) {
        // These used to be in viewDidload
        buttonBack.imageView?.contentMode = .ScaleAspectFit
        //reloadPlayers(players)
        
        if currentPlayer.state == "Picking" {
            reloadCards(cards)
        }
        
        // These used to be in viewDidAppear
        room.subscribe("round/picking", picking)
        room.subscribe("round/choosing", choosing)
        room.subscribe("round/scoring", scoring)
        room.subscribe("play/picked", picked)
        room.subscribe("joined", newPlayer)
        room.subscribe("left", playerLeft)
        
        me.register("draw", draw)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Temporary
        currentPlayer.hand = []
        
        room.call("leave", currentPlayer, handler: nil)
        me.unregister("draw")
        room.leave()

    }
    
    @IBAction func leave(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func picking(player: Player, card: Card, time: Double) {
        state = "Picking"
        labelActiveCard.text = card.text
        _ = players.map { $0.chooser = $0 == player }
        reloadCards(player.domain == session!.domain ? [] : currentPlayer.hand)
        viewProgress.countdown(time)
    }
    
    func choosing(choices: [Card], time: Double) {
        state = "Choosing"
        reloadCards(choices)
        viewProgress.countdown(time)
    }
    
    func scoring(player: Player, time: Double) {
        state = "Scoring"
        player.score += 1
        flashCell(player, model: players, collection: collectionPlayers)
        collectionPlayers.reloadData()
        viewProgress.countdown(time)
    }
    
    func newPlayer(player: Player) {
        players.append(player)
        collectionPlayers.reloadData()
    }
    
    func playerLeft(player: Player) {
        players.removeObject(player)
        collectionPlayers.reloadData()
    }

    func picked(player: Player) {
        
    }
    
    func draw(cards: [Card]) {
        currentPlayer.hand += cards
    }
    
    
    //MARK: Interface for interacting with collection objects
    func reloadCards(newCards: [Card]) {
        cards = newCards
        tableCard.reloadData()
    }
    
    func reloadPlayers(newPlayers: [Player]) {
        players = newPlayers
        collectionPlayers.reloadData()
    }
    
    
    // MARK: UITableView Delegate and Data Source
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
        
        let index = tableCard.indexPathForCell(cell)
        let card = cards[index!.row]
        
        // right side selection
        if point.x >= MAX || point.x <= (-1 * MAX) {
            // reset the cell
            cell.resetContentView()
            cell.interruptPanGestureHandler = true

            // Move to the player class?
            if state == "Picking" && !currentPlayer.chooser {
                room.call("play/pick", currentPlayer, card, handler: nil)
                removeCellsExcept([card])
            } else if state == "Choosing" && currentPlayer.chooser {
                room.publish("play/choose", card)
                removeCellsExcept([card])
            } else {
                print("Pick occured outside a valid round! OurChoice: \(currentPlayer.chooser), state: \(state)")
            }
        }
        
        // Left side selection. Defer for now, although this should represent a "rejection" when choosing
    }
    
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

    
    //MARK: UICollectionView Delegate and Data Source
    
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
}


// Card cell for the UITableView
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


// Player cell for Collection View on bottom of screen
class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelScore: UILabel!
}


// Show progress for the current round with a progress bar
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

