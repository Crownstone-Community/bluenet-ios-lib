//
//  AvailableDevice.swift
//  BluenetLibIOS
//
//  Created by Alex de Mulder on 17/06/16.
//  Copyright © 2016 Alex de Mulder. All rights reserved.
//

import Foundation

let AMOUNT_OF_REQUIRED_MATCHES = 3



public class AvailableDevice {
    var rssiHistory = [Double: Int]()
    var rssi : Int!
    var name : String?
    var handle : String
    var crownstoneId : UInt16 = 0
    var lastUpdate : Double = 0
    var cleanupCallback : () -> Void
    var avgRssi : Double!
    var verified = false
    
    // config
    let timeout : Double = 5 //seconds
    let rssiTimeout : Double = 2 //seconds
    var consecutiveMatches : Int = 0
    
    init(_ data: Advertisement, _ cleanupCallback: () -> Void) {
        self.name = data.name
        self.handle = data.handle
        self.cleanupCallback = cleanupCallback
        self.avgRssi = data.rssi.doubleValue
        if (data.isCrownstone) {
            if (data.isSetupPackage()) {
                self.verified = true;
            }
            else {
                self.crownstoneId = data.scanResponse!.crownstoneId
            }
        }
        self.update(data)
    }
    
    func checkTimeout(referenceTime : Double) {
        // if they are equal, no update has happened since the scheduling of this check.
        if (self.lastUpdate == referenceTime) {
            self.cleanupCallback()
        }
    }
    
    func clearRSSI(referenceTime : Double) {
        self.rssiHistory.removeValueForKey(referenceTime)
        self.calculateRssiAverage()
    }
    
    func update(data: Advertisement) {
        self.rssi = data.rssi.integerValue
        self.lastUpdate = NSDate().timeIntervalSince1970
        self.rssiHistory[self.lastUpdate] = self.rssi;
        self.verify(data.scanResponse)
        self.calculateRssiAverage()
        
        delay(self.timeout, {_ in self.checkTimeout(self.lastUpdate)});
        delay(self.rssiTimeout, {_ in self.clearRSSI(self.lastUpdate)});
    }
    
    
    // check if we consistently get the ID of this crownstone.
    func verify(data: ScanResponcePacket?) {
        if let response = data {
            if (response.isSetupPackage()) {
                self.verified = true
                self.consecutiveMatches = 0
            }
            else {
                if (response.crownstoneId == self.crownstoneId && response.stateOfExternalCrownstone == false) {
                    if (self.consecutiveMatches >= AMOUNT_OF_REQUIRED_MATCHES) {
                        self.verified = true
                    }
                    else {
                        self.consecutiveMatches += 1
                    }
                }
                else if (response.crownstoneId != self.crownstoneId && response.stateOfExternalCrownstone == true) {
                    // dont do anything
                }
                else {
                    self.consecutiveMatches = 0
                    self.verified = false
                    self.crownstoneId = response.crownstoneId
                }
            }
        }
    }
    
    func calculateRssiAverage() {
        var count = 0
        var total : Double = 0
        for (_, rssi) in self.rssiHistory {
            total = total + Double(rssi)
            count += 1
        }
        self.avgRssi = total/Double(count);
    }
}