//
//  SwitchHistory.swift
//  BluenetLib
//
//  Created by Alex de Mulder on 03/06/2020.
//  Copyright © 2020 Alex de Mulder. All rights reserved.
//

import Foundation


class SwitchHistoryList {
     
    var items : [Dictionary<String, NSNumber>]
    
    init(_ dataBlob: [UInt8]) throws {
        let stepper = DataStepper(dataBlob)
        
        let length = try stepper.getUInt8()
        self.items =  [Dictionary<String, NSNumber>]()
        for _ in [Int](0...(NSNumber(value: length).intValue)-1) {
            let timestamp     = try stepper.getUInt32()
            let switchCommand = try stepper.getUInt8()
            let switchState   = try stepper.getUInt8()
            let source        = try stepper.getUInt16()
            self.items.append([
                "timestamp":     NSNumber(value: timestamp),
                "switchCommand": NSNumber(value: switchCommand),
                "switchState":   NSNumber(value: switchState),
                "source":        NSNumber(value: source)
            ])
        }
    }
    }