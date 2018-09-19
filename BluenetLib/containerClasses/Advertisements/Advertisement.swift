//
//  Advertisement.swift
//  BluenetLibIOS
//
//  Created by Alex de Mulder on 17/06/16.
//  Copyright © 2016 Alex de Mulder. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftyJSON

/**
 * Wrapper for all relevant data of the object
 *
 */
public class Advertisement {
    public var handle : String
    public var name : String
    public var rssi : NSNumber
    public var referenceId : String // id of the entity that provides the keys
    
    public var isCrownstoneFamily  : Bool = false
    public var isInDFUMode         : Bool = false
    
    public var serviceData = [String: [UInt8]]()
    public var serviceDataAvailable : Bool
    public var serviceUUID : String?
    public var scanResponse : ScanResponsePacket?
    
    init(handle: String, name: String?, rssi: NSNumber, serviceData: Any, serviceUUID: Any, referenceId: String, liteParse: Bool = false) {
        self.referenceId = referenceId

        if (name != nil) {
            self.name = name!
        }
        else {
            self.name = ""
        }
        self.handle = handle
        self.rssi = rssi
        self.serviceDataAvailable = false

        if let castData = serviceUUID as? [CBUUID] {
            self.serviceUUID = castData[0].uuidString // assuming only one service data uuid
            self.isInDFUMode = self.serviceUUID == DFUServiceUUID
        }
        
        if let castData = serviceData as? [CBUUID: Data] {
            for (serviceCUUID, data) in castData {
                // convert data to uint8 array
                let uint8Arr = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
                self.serviceData[serviceCUUID.uuidString] = uint8Arr
                self.serviceUUID = serviceCUUID.uuidString
                self.serviceDataAvailable = true
                self.isInDFUMode = false
            }
        }
        
        for (id, data) in self.serviceData {
            if (id == CrownstonePlugAdvertisementServiceUUID ||
                id == CrownstoneBuiltinAdvertisementServiceUUID ||
                id == GuidestoneAdvertisementServiceUUID) {
                self.scanResponse        =  ScanResponsePacket(data, liteParse : liteParse)
                self.isCrownstoneFamily  =  self.scanResponse!.hasCrownstoneDataFormat()
                break
            }
        }
    }
    
    func getNumberArray(_ data: [UInt8]) -> [NSNumber] {
        var numberArray = [NSNumber]()
        for uint8 in data {
            numberArray.append(NSNumber(value: uint8))
        }
        return numberArray
    }
    
    func getServiceDataJSON() -> JSON {
        if (self.serviceDataAvailable) {
            for (id, data) in self.serviceData {
                if ((
                    id == CrownstonePlugAdvertisementServiceUUID ||
                    id == CrownstoneBuiltinAdvertisementServiceUUID ||
                    id == GuidestoneAdvertisementServiceUUID) &&
                    self.scanResponse != nil) {
                    return self.scanResponse!.getJSON()
                }
                else {
                    return JSON(self.getNumberArray(data))
                }
            }
        }

        return JSON([])
    }

    public func getUniqueElement() -> String {
        if ((scanResponse) != nil) {
            return scanResponse!.getUniqueElement()
        }
        return ""
    }
    
    public func getJSON() -> JSON {
        return JSON(self.getDictionary())
    }
    
    public func getDictionary() -> NSDictionary {
        var returnDict : [String: Any] = [
            "handle" : self.handle,
            "name"   : self.name,
            "rssi"   : self.rssi,
            "isCrownstoneFamily"   : self.isCrownstoneFamily,
            "isInDFUMode"          : self.isInDFUMode,
            "referenceId"          : self.referenceId
        ]
        
        if (self.serviceUUID != nil) {
            returnDict["serviceUUID"] = self.serviceUUID!
        }
        
        if (self.serviceDataAvailable) {
            if (self.isCrownstoneFamily) {
                returnDict["serviceData"] = self.scanResponse!.getDictionary()
            }
            else {
                returnDict["serviceData"] = self.getNumberArray(self.serviceData[self.serviceUUID!]!)
            }
        }
        
        return returnDict as NSDictionary
    }

    
    public func stringify() -> String {
        return JSONUtils.stringify(self.getJSON())
    }
    
    
    public func isSetupPackage() -> Bool {
        if (serviceDataAvailable && self.scanResponse != nil) {
            return self.scanResponse!.isSetupPackage()
        }
        return false
    }
    
    public func isDFUPackage() -> Bool {
        return self.isInDFUMode
    }
    
    public func hasScanResponse() -> Bool {
        return (serviceDataAvailable && self.scanResponse != nil)
    }
    
    public func decrypt( _ key: [UInt8] ) {
        if (serviceDataAvailable && self.scanResponse != nil) {
            self.scanResponse!.decrypt(key)
        }
    }
    
    public func fullParse() {
        if (serviceDataAvailable && self.scanResponse != nil) {
            self.scanResponse!.parse(liteParse: false)
            self.scanResponse!.dataReadyForUse = true
        }
    }
}




