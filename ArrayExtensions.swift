//
//  ArrayExtensions.swift
//
//
//  Created by adam on 6/19/14.
//  Copyright (c) 2014 Adam Schoonmaker. All rights reserved.
//

import Foundation


extension Array {
    func contains(#object:AnyObject) -> Bool {
        return self.bridgeToObjectiveC().containsObject(object)
    }
    
    func indexOf(#object:AnyObject) -> Int {
        return self.bridgeToObjectiveC().indexOfObject(object)
    }
    
    mutating func moveObjectAtIndex(fromIndex: Int, toIndex: Int) {
        if ((fromIndex == toIndex) || (fromIndex > self.count) ||
            (toIndex > self.count)) {
                return
        }
        // Get object being moved so it can be re-inserted
        let object = self[fromIndex]
        
        // Remove object from array
        self.removeAtIndex(fromIndex)
        
        // Insert object in array at new location
        self.insert(object, atIndex: toIndex)
    }
}

// Causes a compile-time error
// Supposedly because of a bug, according to a Stack Overflow post...?
// http://stackoverflow.com/questions/24154163/xcode-swift-failed-with-exit-code-254
/*
protocol Identifiable {
    @infix func ===(lhs: Self, rhs: Self) -> Bool
}

func indexOf<T: Identifiable>(inout object: T, inArray array: T[]) -> Int? {
    var objectIndex: Int?
    for (index, element) in enumerate(array) {
        if element === object {
            objectIndex = index
        }
    }
    return objectIndex
}
*/



 