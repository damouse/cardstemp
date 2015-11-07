//
//  Room.swift
//  FabAgainstBackend
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//


import Foundation
import Riffle

class Room: NSObject {
    var app: RiffleAgent
    var me: RfifleAgent
    
    var name = ID + "/room" + randomStringWithLength(6)
    
    var state: String = "Empty"
    var deck: Deck
    var players: [Player] = []
    
    var timer: NSTimer?
    
    
    init(app s: Container, deck d: Deck) {
        app = s
        me = RiffleAgent(name: randomStringWithLength(6), superdomain: app)
        
        deck = d
        
        super.init()
        
        room.register("leave", playerLeft)
        room.register("play/pick", playerLeft)
        room.subscribe("play/choose", choose)
        
        // Move to container
        //session.subscribe(ID + "/sessionLeft", sessionLeft)
    }
    
    func sessionLeft(domain: String) {
        print("Session left: \(domain)")
    }
    
    // MARK: Player Changes
    func addPlayer(domain: String) -> [AnyObject] {
        print("Adding Player \(domain)")
        // Called from main session when player assigned to the room
        // Returns the information the player needs to get up to date
        
        // TODO: Assumes no duplicates, obviously
        let player = Player()
        player.id = Int(arc4random_uniform(UInt32.max))
        player.domain = domain
        players.append(player)
        
        me.publish("joined", player)
        
        defer {
            if players.count > 1 {
                startTimer(EMPTY_TIME, selector: "startPicking")
            } else {
                print("Not enough players to start play. Waiting")
            }
        }
        
        return [deck.drawCards(deck.answers, number: HAND_SIZE), players, String(state), name]
    }
    
    func playerLeft(player: Player) {
        print("Player left: " + player.domain)

        me.publish("left", player)
        deck.reshuffleCards(&deck.answers, cards: player.hand)
        players.removeObject(player)
        
        // Make sure there are enough players left
        // What if the chooser leaves?
        // Shuffle the leaver's cards back into the deck
    }
    
    
    // MARK: Picking
    func startPicking() {
        print("STATE: Picking")
        state = "Picking"
        
        let question = deck.drawCards(deck.questions, number: 1, remove: false)[0]
        let chooser = setNextChooser()
        
        print("Next picker set: \(chooser)")

        me.publish("round/picking", chooser, question, PICK_TIME)
        startTimer(PICK_TIME, selector: "startChoosing")
    }
    
    func pick(player: Player, card: Card) {
        print("Player \(player) picked \(card)")
        
        // Ensure state, throw exception
        if state != "Picking" || player.pick != nil || !player.hand.contains(card) {
            print("ERROR: illegal play from player \(player.domain)")
            return
        }
        
        player.pick = card
        me.publish("play/picked", player)
        
        // Check and see if all players have picked cards. If they have, end the round early.
        let notPicked = players.filter { $0.pick == nil && $0 != getChooser()! }
        
        if notPicked.count == 0 {
            print("All players picked. Ending timer early. ")
            startTimer(0.1, selector: "startChoosing")
        }
    }
    
    
    // MARK: Choosing
    func startChoosing() {
        print("STATE: choosing")

         for p in players {
            if p.pick == nil {
                p.pick = randomElement(&p.hand, remove: true)
                me.publish("play/picked", p.pick!)
            }
        }
        
        me.publish("round/choosing", players.map({ $0.pick! }), CHOOSE_TIME)
        state = "Choosing"
        startTimer(CHOOSE_TIME, selector: "startScoring:")
    }
    
    func choose(card: Card) {
        let picks = players.filter { $0.pick == card }
        
        if picks.count == 0 {
            print("No one played the choosen card \(card)")
            // TODO: Choose on at random? This is malicious activity or a serious bug
        } else if picks.count != 1 {
            print("More than one winning pick selected!")
        }
        
        print("Winner choosen: " + picks[0].domain)
        startTimer(0.0, selector: "startScoring:", info: picks[0].domain)
    }
    
    
    //MARK: Scoring
    func startScoring(timer: NSTimer) {
        print("STATE: scoring")
        state = "Scoring"
        var pickers = players.filter { !$0.chooser }
        
        // if nil, no player was choosen. Autochoose one.
        var player: Player?
        if let domain = timer.userInfo as? String {
            let filters = players.filter { $0.domain == domain }
            
            // Make sure we weren't lied to
            if filters.count != 1 {
                print("ERR: submission \(domain) not found in players!")
            } else {
                player = filters[0]
            }
        }
        
        // Choose a winner at random
        if player == nil {
             print("No players picked cards! Choosing one at random")
            player = randomElement(&pickers)
        }
        
        player!.score += 1
        me.publish("round/scoring", player!, SCORE_TIME)

        // draw cards for all players
        for p in pickers {
            if let c = p.pick {
                deck.reshuffleCards(&deck.answers, cards: [c])
                p.hand.removeObject(c)
            }
            
            p.pick = nil
            RiffleAgent(name: p.domain, superdomain: app).call("draw", deck.drawCards(deck.answers, number: 1)[0], handler:nil)
        }
        
        startTimer(SCORE_TIME, selector: "startPicking")
    }
    
    
    //MARK: Utils
    func startTimer(time: NSTimeInterval, selector: String, info: AnyObject? = nil) {
        // Run the timer for the given target with the given parameters. 
        // Cancels the existing timer if called while one is active
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        print("Starting timer for \(time) on \(selector)")
        timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector(selector), userInfo: info, repeats: false)
    }
    
    func cancelTimer() {
        if let t = timer {
            t.invalidate()
            timer = nil
        }
    }
    
    func setNextChooser() -> Player {
        let f = players.filter { $0.chooser == true }
        let player = f.count == 0 ? players[0] : players[players.indexOf(f[0])! + 1 % (players.count - 1)]
        player.chooser = true
        return player
    }
    
    func getChooser() -> Player? {
        let f = players.filter { $0.chooser == true }
        if f.count != 1 {
            print("No chooser found!")
            return nil
        }
        
        return f[0]
    }
}


