//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by damouse on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.


import Foundation

class Deck {
    var questions: [Card] = []
    var answers: [Card] = []
    
    init(questionPath: String, answerPath: String) {
        let load = { (name: String) -> [Card] in
            let jsonPath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
            let x = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: jsonPath!)!, options: NSJSONReadingOptions.AllowFragments) as! [[String: AnyObject]]
            
            return x.map { (element: [String: AnyObject]) -> Card in
                let c = Card()
                c.id = element["id"] as! Int
                c.text = element["text"] as! String
                return c
            }
        }
        
        questions = load(questionPath)
        answers = load(answerPath)
    }
    
    init(deck: Deck) {
        questions = deck.questions
        answers = deck.answers
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


