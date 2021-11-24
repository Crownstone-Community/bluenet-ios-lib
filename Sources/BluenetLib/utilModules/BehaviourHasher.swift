//
//  BehaviourHasher.swift
//  BluenetLib
//
//  Created by Alex de Mulder on 04/12/2019.
//  Copyright © 2019 Alex de Mulder. All rights reserved.
//

import Foundation


public class BehaviourHasher {
    var behaviours : [Behaviour]!
    
    init() {}
    
    public convenience init(_ dictArray: [NSDictionary], dayStartTimeSecondsSinceMidnight: UInt32) {
        self.init()
        self.behaviours = [Behaviour]()
        for dict in dictArray {
            let behaviour = try? BehaviourDictionaryParser(dict, dayStartTimeSecondsSinceMidnight: dayStartTimeSecondsSinceMidnight)
            if behaviour != nil {
                behaviours.append(behaviour!)
            }
        }
        
        self.sort()
    }
    
    public convenience init(_ behaviourArray: [Behaviour]) {
        self.init()
        self.behaviours = behaviourArray
        self.sort()
    }
    
    func sort() {
        behaviours.sort( by: { a,b in
            if a.indexOnCrownstone != nil && b.indexOnCrownstone != nil {
                return a.indexOnCrownstone! < b.indexOnCrownstone!
            }
            return false
        })
    }
    
    public func getMasterHash() -> UInt32 {
        var hashPacket = [UInt8]()
        
        for behaviour in behaviours {
            if behaviour.indexOnCrownstone != nil {
                hashPacket.append(behaviour.indexOnCrownstone!)
                hashPacket.append(0)
                hashPacket += behaviour.getPaddedPacket()
            }
        }
        
        if hashPacket.count > 0 {
            return fletcher32(hashPacket)
        }
        
        return 0
    }    
}
