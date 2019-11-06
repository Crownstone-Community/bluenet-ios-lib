//
//  ResultPacket.swift
//  BluenetLib
//
//  Created by Alex de Mulder on 30/04/2018.
//  Copyright © 2018 Alex de Mulder. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftyJSON

public class ResultBasePacket {
    public var payload : [UInt8] = []
    public var valid = true
    public var resultCode        : ResultValue   = .UNSPECIFIED
    public var commandTypeUInt16 : UInt16 = 65535
    
    func load(_ data : [UInt8]) {}
}

/**
 * Wrapper for all relevant data of the object
 */
public class ResultPacket : ResultBasePacket {
    public var type : UInt8 = 0
    public var opCode : UInt8 = 0
    public var length : UInt16 = 0
    
    override init() {
        super.init()
    }
       
    init(_ data : [UInt8]) {
        super.init()
        self.load(data)
    }
    
    override func load(_ data : [UInt8]) {
        if (data.count >= 4) {
            self.valid = true
            self.type = data[0]
            self.opCode = data[1]
            self.length = Conversion.uint8_array_to_uint16([data[2], data[3]])
            let totalSize : Int = 4 + NSNumber(value: self.length).intValue
            
            self.commandTypeUInt16 = UInt16(data[0])
            
            if (data.count >= totalSize) {
                for i in [Int](4...totalSize) {
                    self.payload.append(data[i])
                }
                
                if (self.length >= 2) {
                    let resultCode = ResultValue(rawValue: Conversion.uint8_array_to_uint16([self.payload[0], self.payload[1]]))
                    if resultCode != nil {
                        self.resultCode = resultCode!
                    }
                }
                
            }
            else {
                self.valid = false
            }
        }
        else {
            self.valid = false
        }
    }
}

public class ResultPacketV2 : ResultBasePacket {
    public var commandType : ControlTypeV2 = .UNSPECIFIED
    
    public var size        : UInt16 = 0
    
    override init() {
        super.init()
    }
    
    init(_ data : [UInt8]) {
        super.init()
        self.load(data)
    }
        
    override func load(_ data : [UInt8]) {
        let minSize = 6

        if (data.count >= minSize) {
            let commandType = ControlTypeV2(rawValue: Conversion.uint8_array_to_uint16([data[0], data[1]]))
            let resultCode  = ResultValue(rawValue: Conversion.uint8_array_to_uint16([data[2], data[3]]))
            
            if (commandType == nil || resultCode == nil) {
                self.valid = false
                return
            }
            
            self.commandType = commandType!
            self.commandTypeUInt16 = Conversion.uint8_array_to_uint16([data[0], data[1]])
            self.resultCode  = resultCode!
            self.size        = Conversion.uint8_array_to_uint16([data[4], data[5]])
                        
            let totalSize : Int = minSize + NSNumber(value: self.size).intValue
            if (data.count >= totalSize) {
                for i in [Int](minSize...totalSize) {
                    self.payload.append(data[i])
                }
            }
            else {
                self.valid = false
            }
        }
        else {
            self.valid = false
        }
    }
}

