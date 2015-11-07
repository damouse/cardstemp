//
//  main.swift
//  Backend
//
//  Created by Mickey Barboi on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

// a silly little hack until I get the prefixes in place
let ID = "pd.demo.cardsagainst"

let ROOM_CAP = 6
let HAND_SIZE = 6
let PICK_TIME = 15.0
let CHOOSE_TIME = 8.0
let SCORE_TIME = 3.0
let EMPTY_TIME = 1.0
let MIN_PLAYERS = 2

let app = RiffleAgent(domain: "pd.demo.cardsagainst")

class Container: RiffleAgent {
    var rooms: [Room] = []
    
    var pg13 = Deck(questionPath: "q13", answerPath: "a13")
    var pg21 = Deck(questionPath: "q21", answerPath: "a21")
    
    override func onJoin() {
        print("Session joined")
        register("pd.demo.cardsagainst/play", getRoom)
    }
    
    func getRoom(player: String) -> AnyObject {
        let emptyRooms = rooms.filter { $0.players.count < ROOM_CAP }
        var room: Room
        
        if emptyRooms.count == 0 {
            room = Room(session: self, deck: pg13)
            rooms.append(room)
        } else {
            room = emptyRooms[Int(arc4random_uniform(UInt32(emptyRooms.count)))]
        }
        
        let x = room.addPlayer(player as String)
        return x
    }
}


RiffleAgent(domain: "pd.demo.cardsagainst").connect()

NSRunLoop.currentRunLoop().run()


