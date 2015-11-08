//
//  Utilitues.swift
//  ExAgainst
//
//  Created by damouse on 11/8/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

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

