//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by damouse on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.


import Foundation
import Mantle

class Deck {
    var questions: [Card] = []
    var answers: [Card] = []
    
    init(questionPath: String, answerPath: String) {
        let load = { (name: String) -> [Card] in
            let jsonPath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
            let x = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: jsonPath!)!, options: NSJSONReadingOptions.AllowFragments)
            
            return try! MTLJSONAdapter.modelsOfClass(Card.self, fromJSONArray: x as! [[String: AnyObject]]) as! [Card]
        }
        
        questions = load(questionPath)
        answers = load(answerPath)
    }
    
    init(deck: Deck) {
        questions = deck.questions
        answers = deck.answers
    }
}


