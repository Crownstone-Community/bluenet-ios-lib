//
//  ServiceData.swift
//  BluenetLib
//
//  Created by Alex de Mulder on 08/01/2018.
//  Copyright © 2018 Alex de Mulder. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftyJSON

open class ScanResponsePacket {
    open var opCode              :   UInt8    = 0
    open var dataType            :   UInt8    = 0
    open var crownstoneId        :   UInt8    = 0
    open var switchState         :   UInt8    = 0
    open var flagsBitmask        :   UInt8    = 0
    open var temperature         :   Int8     = 0
    open var powerFactor         :   Double   = 0
    open var powerUsageReal      :   Double   = 0
    open var powerUsageApparent  :   Double   = 0
    open var accumulatedEnergy   :   Int32    = 0
    open var setupMode           :   Bool     = false
    open var stateOfExternalCrownstone : Bool = false
    open var data                :   [UInt8]!
    
    open var dimmingAvailable    :   Bool     = false
    open var dimmingAllowed      :   Bool     = false
    open var hasError            :   Bool     = false
    open var switchLocked        :   Bool     = false
    
    open var partialTimestamp    :   UInt16   = 0
    open var timestamp           :   UInt32   = 0
    
    open var validation          :   UInt16   = 0x0000 // Will be 0xFACE if it is set.
    
    // TYPE ERROR (opCode 3, type 1)
    open var errorTimestamp      :   UInt32   = 0
    open var errorsBitmask       :   UInt32   = 0
    open var errorMode           :   Bool     = false
    
    open var uniqueIdentifier    : NSNumber = 0
    
    var validData = false
    
    init(_ data: [UInt8]) {
        self.data = data
        self.parse()
    }
    
    func parse() {
        if (data.count == 17) {
            self.opCode = data[0]
            switch (self.opCode) {
            case 1:
                parseOpcode1(serviceData: self, data: data)
            case 2:
                parseOpcode2(serviceData: self, data: data)
            case 3:
                parseOpcode3(serviceData: self, data: data)
            case 4:
                parseOpcode4(serviceData: self, data: data)
            default:
                parseOpcode3(serviceData: self, data: data)
            }
            validData = true
        }
        else {
            validData = false
        }
    }
    
    
    
    open func hasCrownstoneDataFormat() -> Bool {
        return validData
    }
    
    open func getUniqueElement() -> String {
        return Conversion.uint8_array_to_hex_string(
                Conversion.uint32_to_uint8_array(self.uniqueIdentifier.uint32Value)
        )
    }
    
    open func getDictionary() -> NSDictionary {
        let errorsDictionary = CrownstoneErrors(bitMask: self.errorsBitmask).getDictionary()
        let returnDict : [String: Any] = [
            "opCode"               : NSNumber(value: self.opCode),
            "dataType"             : NSNumber(value: self.dataType),
            "stateOfExternalCrownstone" : self.stateOfExternalCrownstone,
            "hasError"             : self.hasError,
            "setupMode"            : self.isSetupPackage(),
            
            "crownstoneId"         : NSNumber(value: self.crownstoneId),
            "switchState"          : NSNumber(value: self.switchState),
            "flagsBitmask"         : NSNumber(value: self.flagsBitmask),
            "temperature"          : NSNumber(value: self.temperature),
            "powerFactor"          : NSNumber(value: self.powerFactor),
            "powerUsageReal"       : NSNumber(value: self.powerUsageReal),
            "powerUsageApparent"   : NSNumber(value: self.powerUsageApparent),
            "accumulatedEnergy"    : NSNumber(value: self.accumulatedEnergy),
            "timestamp"            : NSNumber(value: self.timestamp),
            
            "dimmingAvailable"     : self.dimmingAvailable,
            "dimmingAllowed"       : self.dimmingAllowed,
            "switchLocked"         : self.switchLocked,
            
            "errorMode"            : self.errorMode,
            "errors"               : errorsDictionary,
            
            "uniqueElement"        : self.uniqueIdentifier
        ]
        
        return returnDict as NSDictionary
    }
    
    open func getJSON() -> JSON {
        return JSON(self.getDictionary())
    }
    
    open func stringify() -> String {
        return JSONUtils.stringify(self.getJSON())
    }
    
    open func isSetupPackage() -> Bool {
        if (validData == false) {
            return false
        }
        
        switch (self.opCode) {
        case 1,2:
            if (crownstoneId == 0 && switchState == 0 && powerUsageReal == 0 && accumulatedEnergy == 0 && setupMode == true) {
                return true
            }
            else {
                return false
            }
        case 3:
            return false
        case 4:
            return true
        default:
            return false
        }
    }
    
    open func decrypt(_ key: [UInt8]) {
        if (validData == true) {
            var encryptedData = [UInt8](repeating: 0, count: 16)
            // copy the data we want to encrypt into a buffer
            for i in [Int](1...data.count-1) {
                encryptedData[i-1] = data[i]
            }
            
            do {
                let result = try EncryptionHandler.decryptAdvertisement(encryptedData, key: key)
                
                for i in [Int](0...result.count-1) {
                    self.data[i+1] = result[i]
                }
                // parse the data again based on the decrypted result
                self.parse()
            }
            catch let err {
                LOG.error("Could not decrypt advertisement \(err)")
            }
        }
        else {
            
        }
    }
}
