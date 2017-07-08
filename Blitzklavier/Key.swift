//
//  Key.swift
//  Blitzklavier
//
//  Created by Jože Ws on 08/07/2017.
//  Copyright © 2017 JožeWs. All rights reserved.
//

import Foundation

enum Note {
    case C, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B
}

class Key: CustomStringConvertible, Comparable {
    
    // MARK:- MODEL
    
    var note: Note
    var number: Int
    
    // MARK:- CLASS
    
    class func whiteDistance(key0: Key, key1: Key) -> Int {
        var distance = (key1.number - key0.number)*7
        distance += key1.whiteIndex - key0.whiteIndex
        return distance
    }
    
    // MARK:- INIT
    
    init(note: Note, number: Int) {
        self.note = note
        self.number = number
    }
    
    convenience init(whiteKey: Int) {
        
        let whiteKeyIndex = whiteKey % 7
        
        var note = Note.C // default
        let number = whiteKey/7
        
        switch whiteKeyIndex {
        case 0:
            note = .C
        case 1:
            note = .D
        case 2:
            note = .E
        case 3:
            note = .F
        case 4:
            note = .G
        case 5:
            note = .A
        case 6:
            note = .B
        default:
            break
        }
        self.init(note: note, number: number)
    }
    
    convenience init(whiteKey: Int, sharp: Bool) {
        
        let whiteKeyIndex = whiteKey % 7
        
        var note = Note.C // default
        let number = whiteKey/7
        
        switch whiteKeyIndex {
        case 0:
            note = !sharp ? .C : .Cs
        case 1:
            note = !sharp ? .D : .Ds
        case 2:
            note = !sharp ? .E : .F
        case 3:
            note = !sharp ? .F : .Fs
        case 4:
            note = !sharp ? .G : .Gs
        case 5:
            note = !sharp ? .A : .As
        case 6:
            note = !sharp ? .B : .C
        default:
            break
        }
        self.init(note: note, number: number)
    }
    
    convenience init(whiteKey: Int, flat: Bool) {
        
        let whiteKeyIndex = whiteKey % 7
        
        var note = Note.C // default
        let number = whiteKey/7
        
        switch whiteKeyIndex {
        case 0:
            note = !flat ? .C : .B
        case 1:
            note = !flat ? .D : .Cs
        case 2:
            note = !flat ? .E : .Ds
        case 3:
            note = !flat ? .F : .E
        case 4:
            note = !flat ? .G : .Fs
        case 5:
            note = !flat ? .A : .Gs
        case 6:
            note = !flat ? .B : .As
        default:
            break
        }
        self.init(note: note, number: number)
    }
    
    // MARK:- CUSTOM STRING PRINTABLE
    
    var description: String {
        return "\(note)\(number)"
    }
    
    // MARK:- COMPARABLE
    
    static func <(lhs: Key, rhs: Key) -> Bool {
        return lhs.number != rhs.number ? lhs.number < rhs.number : lhs.whiteIndex < rhs.whiteIndex
    }
    
    static func == (key0: Key, key1: Key) -> Bool {
        return key0.note == key1.note && key0.number == key1.number
    }
    
    static func != (key0: Key, key1: Key) -> Bool {
        return key0.note != key1.note || key0.number != key1.number
    }
    
    // MARK:- UTIL
    
    var isBlack: Bool {
        return note == .Cs || note == .Ds || note == .Fs || note == .Gs || note == .As
    }
    
    var whiteIndex: Int {
        switch note {
        case .C, .Cs:
            return 0
        case .D, .Ds:
            return 1
        case .E:
            return 2
        case .F, .Fs:
            return 3
        case .G, .Gs:
            return 4
        case .A, .As:
            return 5
        case .B:
            return 6
        }
    }
    
    var hasBlackKeyOnRight: Bool {
        guard !isBlack else { return false }
        return whiteIndex == 0 || whiteIndex == 1 || whiteIndex == 3 || whiteIndex == 4 || whiteIndex == 5
    }
    
    var hasBlackKeyOnLeft: Bool {
        guard !isBlack else { return false }
        return whiteIndex == 1 || whiteIndex == 2 || whiteIndex == 4 || whiteIndex == 5 || whiteIndex == 6
    }
}







