//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by Mickey Barboi on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.

// This code is shared across the app and the container.

import Foundation
import Riffle


// Player class. Holds data and game state
class Player: RiffleModel {
    var state: String = "Empty"
    var players: [Player] = []
    
    var score = 0
    var chooser = false
    var hand: [Card] = []
    var pick: Card?
    
    
    override class func ignoreProperties() -> [String] {
        //These properties will not be transferred when the object is transferred
        return ["hand", "pick", "players"]
    }
    
    
    // MARK: Game Functionality 
    
}

//MARK: Card Class
class Card: RiffleModel {
    var id = -1
    var text = ""
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.id == rhs.id
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.agent == rhs.agent
}

func getPlayer(players: [Player], domain: String) -> Player {
    return players.filter({$0.agent.domain == domain})[0]
}

