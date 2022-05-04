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



public enum CrownstoneMode {
    case operation
    case setup
    case dfu
    case unknown
}

public class ScanResponsePacket {
    public var opCode              :   UInt8    = 0
    public var dataType            :   UInt8    = 0
    public var crownstoneId        :   UInt8    = 0
    public var switchState         :   UInt8    = 0
    public var flagsBitmask        :   UInt8    = 0
    public var temperature         :   Int8     = 0
    public var powerFactor         :   Double   = 1
    public var powerUsageReal      :   Double   = 0
    public var powerUsageApparent  :   Double   = 0
    public var accumulatedEnergy   :   Int64    = 0
    public var assetFiltersMasterVersion : UInt16 = 0
    public var assetFiltersCRC     : UInt32 = 0
    public var setupMode           :   Bool     = false
    public var stateOfExternalCrownstone : Bool = false
    public var alternativeState    :   Bool = false
    public var data                :   [UInt8]!
    public var encryptedDataStartIndex : Int = 1
    
    public var dimmerReady         :   Bool     = false
    public var dimmingAllowed      :   Bool     = false
    public var hasError            :   Bool     = false
    public var switchLocked        :   Bool     = false
    
    public var uartAlive           :   Bool     = false
    public var uartAliveEncrypted  :   Bool     = false
    public var uartEncryptionRequiredByCrownstone : Bool = false
    public var uartEncryptionRequiredByHub        : Bool = false
    public var hubHasBeenSetup     :   Bool     = false
    public var hubHasInternet      :   Bool     = false
    public var hubHasError         :   Bool     = false
    
    public var hubData             :   [UInt8]   = []
    
    public var partialTimestamp    :   UInt16   = 0
    public var timestamp           :   Double   = -1
    
    public var validation          :   UInt8  = 0x00 // Will be 0xFA if it is set.
    
    // TYPE ERROR (opCode 3, type 1)
    public var errorTimestamp      :   UInt32   = 0
    public var errorsBitmask       :   UInt32   = 0
    public var errorMode           :   Bool     = false
    public var timeSet             :   Bool     = false
    public var switchCraftEnabled  :   Bool     = false
    public var hubMode             :   Bool     = false
    public var tapToToggleEnabled  :   Bool     = false
    public var behaviourOverridden :   Bool     = false
    
    public var uniqueIdentifier    :   NSNumber = 0
    
    public var behaviourEnabled    :   Bool     = true
    public var behaviourMasterHash :   UInt16   = 0
    
    public var deviceType          :   DeviceType = .unset
    public var rssiOfExternalCrownstone : Int8  = 0
    
    var serviceUUID : CBUUID? = nil
    
    var validData = false
    public var dataReadyForUse = false // decryption is successful
    
    public init(_ data: [UInt8], serviceUUID: CBUUID? = nil) {        
        self.data = data
        self.serviceUUID = serviceUUID
        
        validData = true
        if (self.data.count == 18) {
            self.opCode = data[0]
            self.encryptedDataStartIndex = 2
        }
        else if (self.data.count == 17) {
            self.opCode = data[0]
            self.encryptedDataStartIndex = 1
        }
        else {
            validData = false
        }
    }
    
    
    func getOperationMode() -> CrownstoneMode {
        if (self.validData == false) {
            return CrownstoneMode.unknown
        }
        
        switch (self.opCode) {
            case 1:
                // this is a deprecated protocol. We checked if everything was 0 and that the setup flag was high.
                let bitmaskArray = Conversion.uint8_to_bit_array(data[4])
                if (bitmaskArray[7] && Conversion.uint8_array_to_uint16([data[1], data[2]]) == 0) {
                    return CrownstoneMode.setup
                }
                return CrownstoneMode.operation
            case 2, 3:
                return CrownstoneMode.operation
            case 4:
                return CrownstoneMode.setup
            case 5, 7:
                return CrownstoneMode.operation
            case 6:
                return CrownstoneMode.setup
            default:
                return CrownstoneMode.unknown
        }
    }
    
    func parsePublic() {
        if self.data != nil {
            if (self.validData) {
                switch (self.opCode) {
                case 1,2,3,4:
                    self._getLegacyDeviceType()
                case 5,6,7:
                    // 5 and 7 have the same payload, but they use a different key.
                    self.getDeviceTypeFromPublicData()
                default:
                    self.getDeviceTypeFromPublicData()
                }
            }
        }
    }
    
    
    func parseWithoutDecrypting() {
        if self.data != nil {
            self.parse(decryptedData: Array(self.data![self.encryptedDataStartIndex...]))
        }
    }
    
    func parse(decryptedData: [UInt8]) {
        if (self.validData) {
            switch (self.opCode) {
            case 1:
                self._getLegacyDeviceType()
                parseOpcode1(serviceData: self, data: decryptedData)
            case 2:
                self._getLegacyDeviceType()
                // this is not used and has never been released
                parseOpcode2(serviceData: self, data: decryptedData)
            case 3:
                self._getLegacyDeviceType()
                parseOpcode3(serviceData: self, data: decryptedData)
            case 4:
                self._getLegacyDeviceType()
                parseOpcode4(serviceData: self, data: decryptedData)
            case 5, 7:
                // 5 and 7 have the same payload, but they use a different key.
                self.getDeviceTypeFromPublicData()
                parseOpcode5(serviceData: self, data: decryptedData)
            case 6:
                // this is the setup mode
                self.getDeviceTypeFromPublicData()
                parseOpcode6(serviceData: self, data: decryptedData)
            default:
                self.getDeviceTypeFromPublicData()
                parseOpcode5(serviceData: self, data: decryptedData)
            }
        }
    }
    
    func getDeviceTypeFromPublicData() {
        if (self.data.count == 18) {
            if let type = DeviceType(rawValue: data[1]) {
                self.deviceType = type
            }
            else {
                self.deviceType = DeviceType.undefined
            }
        }
    }
    
    
    func _getLegacyDeviceType() {
        if let uuid = self.serviceUUID {
            switch (uuid) {
            case CrownstonePlugAdvertisementServiceUUID:
                self.deviceType = .plug
            case CrownstoneBuiltinAdvertisementServiceUUID:
                self.deviceType = .builtin
            case GuidestoneAdvertisementServiceUUID:
                self.deviceType = .guidestone
            default:
                self.deviceType = .undefined
            }
        }
    }
    
    
    public func hasCrownstoneDataFormat() -> Bool {
        return validData
    }
    
    
    public func getUniqueElement() -> String {
        return Conversion.uint8_array_to_hex_string(
                Conversion.uint32_to_uint8_array(self.uniqueIdentifier.uint32Value)
        )
    }
    
    
    public func getDictionary() -> NSDictionary {
        let errorsDictionary = CrownstoneErrors(bitMask: self.errorsBitmask).getDictionary()
        let returnDict : [String: Any] = [
            "opCode"               : NSNumber(value: self.opCode),
            "dataType"             : NSNumber(value: self.dataType),
            "stateOfExternalCrownstone" : self.stateOfExternalCrownstone,
            "alternativeState"     : self.alternativeState,
            "hubMode"              : self.hubMode,
            "hasError"             : self.hasError,
            "setupMode"            : self.setupMode,
            
            "crownstoneId"         : NSNumber(value: self.crownstoneId),
            "switchState"          : NSNumber(value: self.switchState),
            "flagsBitmask"         : NSNumber(value: self.flagsBitmask),
            "temperature"          : NSNumber(value: self.temperature),
            "powerFactor"          : NSNumber(value: self.powerFactor),
            "powerUsageReal"       : NSNumber(value: self.powerUsageReal),
            "powerUsageApparent"   : NSNumber(value: self.powerUsageApparent),
            "accumulatedEnergy"    : NSNumber(value: self.accumulatedEnergy),
            "timestamp"            : NSNumber(value: self.timestamp),
            
            "dimmerReady"          : self.dimmerReady,
            "dimmingAllowed"       : self.dimmingAllowed,
            "switchLocked"         : self.switchLocked,
            "switchCraftEnabled"   : self.switchCraftEnabled,
            "tapToToggleEnabled"   : self.tapToToggleEnabled,
            "behaviourOverridden"  : self.behaviourOverridden,
            
            "behaviourMasterHash"  : self.behaviourMasterHash,
            "assetFiltersMasterVersion" : self.assetFiltersMasterVersion,
            "assetFiltersCRC"       : self.assetFiltersCRC,
            
            "behaviourEnabled"     : self.behaviourEnabled,
            
            "errorMode"            : self.errorMode,
            "errors"               : errorsDictionary,
            
            "hubData"              : self.hubData,
            
            "uartAlive"            : self.uartAlive,
            "uartAliveEncrypted"   : self.uartAliveEncrypted,
            "uartEncryptionRequiredByCrownstone" : self.uartEncryptionRequiredByCrownstone,
            "uartEncryptionRequiredByHub"        : self.uartEncryptionRequiredByHub,
            "hubHasBeenSetup"      : self.hubHasBeenSetup,
            "hubHasInternet"       : self.hubHasInternet,
            "hubHasError"          : self.hubHasError,
            
            "uniqueElement"        : self.uniqueIdentifier,
            "timeSet"              : self.timeSet,
            "deviceType"           : String(describing: self.deviceType),
            "rssiOfExternalCrownstone" : self.rssiOfExternalCrownstone
        ]
        
        return returnDict as NSDictionary
    }
    
    
    public func getJSON() -> JSON {
        return JSON(self.getDictionary())
    }
    
    
    public func stringify() -> String {
        return JSONUtils.stringify(self.getJSON())
    }
    
    
    public func decrypt(_ key: [UInt8]) {
        if (validData == true) {
            do {
                let decryptedData = try EncryptionHandler.decryptAdvertisementSlice(self.data![self.encryptedDataStartIndex...], key: key)
                
                // parse the data based on the decrypted result
                self.parse(decryptedData: decryptedData)
                self.dataReadyForUse = true
            }
            catch let err {
                self.dataReadyForUse = false
                LOG.error("Could not decrypt advertisement \(err)")
            }
        }
    }
}
