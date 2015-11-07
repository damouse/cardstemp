//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by Mickey Barboi on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.

// This code is shared across the app and the container.

import Foundation
import Riffle

class Deck {
    var questions: [Card] = []
    var answers: [Card] = []
    
    init(questionPath: String, answerPath: String) {
        let load = { (name: String) -> [Card] in
            let jsonPath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
            let x = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: jsonPath!)!, options: NSJSONReadingOptions.AllowFragments) as! [[String: AnyObject]]
            return x.map({ (json: [String: AnyObject]) -> Card in
                let card = Card()
                card.id = json["id"] as! Int
                card.text = json["text"] as! String
                return card
            })
        }
        
        questions = load(questionPath)
        answers = load(answerPath)
    }
    
    func drawCards(var cards: [Card], number: Int, remove: Bool = true) -> [Card] {
        var ret: [Card] = []
        
        for _ in 0...number {
            ret.append(randomElement(&cards, remove: remove))
        }
        
        return ret
    }
    
    func reshuffleCards(inout target: [Card], cards: [Card]) {
        // "Realease" the cards formerly in play by shuffling them back into the deck 
        target.appendContentsOf(cards)
    }
}


