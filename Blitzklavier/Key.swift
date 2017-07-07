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

class Key: CustomStringConvertible {
    
    var note: Note
    var number: Int
    
    init(note: Note, number: Int) {
        self.note = note
        self.number = number
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
    
    var description: String {
        return "\(note)\(number)"
    }
}










