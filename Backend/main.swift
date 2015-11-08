//
//  main.swift
//  Backend
//
//  Created by damouse on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

let ROOM_CAP = 6
let HAND_SIZE = 6
let PICK_TIME = 15.0
let CHOOSE_TIME = 8.0
let SCORE_TIME = 3.0
let EMPTY_TIME = 1.0
let MIN_PLAYERS = 2


let app = RiffleAgent(domain: "xs.demo.cardsagainst")
Riffle.setDevFabric()


class Container: RiffleAgent {
    var rooms: [Room] = []
    var pg13 = Deck(questionPath: "q13", answerPath: "a13")
    var pg21 = Deck(questionPath: "q21", answerPath: "a21")
    
    
    override func onJoin() {
        print("Container joined")
        register("play", getRoom)
        subscribe("sessionLeft", agentLeft)
    }
    
    func getRoom(player: String) -> AnyObject {
        let emptyRooms = rooms.filter { $0.players.count < ROOM_CAP }
        var room: Room
        
        if emptyRooms.count == 0 {
            room = Room(deck: Deck(deck: pg13))
            rooms.append(room)
        } else {
            room = emptyRooms[Int(arc4random_uniform(UInt32(emptyRooms.count)))]
        }
        
        let x = room.addPlayer(player as String)
        return x
    }
    
    func agentLeft(domain: String) {
        
    }
}

Container(name: "container", superdomain: app).join()
NSRunLoop.currentRunLoop().run()


