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


// Utility function to generate random strings
func randomStringWithLength (len : Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let rand = arc4random_uniform(UInt32(letters.length))
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return String(randomString)
}

// Retrieve a random element from the array and optionally remove it
func randomElement<T>(inout arr: [T], remove: Bool = false) -> T {
    let i = Int(arc4random_uniform(UInt32(arr.count)))
    let o = arr[i]
    
    if remove {
        arr.removeAtIndex(i)
    }
    
    return o
}

// Remove element by value
extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

