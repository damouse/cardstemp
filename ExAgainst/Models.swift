//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by Mickey Barboi on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.

// This code is shared across the app and the container.

import Foundation
import Riffle

class Player: RiffleModel {
    var id = -1
    
    var domain = ""
    var score = 0
    
    var chooser = false
    var hand: [Card] = []
    var pick: Card?
    
    override class func ignoreProperties() -> [String] {
        return ["hand", "pick"]
    }
}

class Card: RiffleModel {
    var id = -1
    var text = ""
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.id == rhs.id
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.domain == rhs.domain
}

func getPlayer(players: [Player], domain: String) -> Player {
    return players.filter({$0.domain == domain})[0]
}

