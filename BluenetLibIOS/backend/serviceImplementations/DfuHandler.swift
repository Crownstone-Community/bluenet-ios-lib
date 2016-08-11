//
//  DfuHandler.swift
//  BluenetLibIOS
//
//  Created by Alex de Mulder on 10/08/16.
//  Copyright © 2016 Alex de Mulder. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBluetooth

class NotifcationPacket {
    var OpCode : UInt8 = 0
    var ReqOpCode : UInt8 = 0
    var RespValue : UInt8 = 0
    
    init(){}
    
    func clear() {
        self.OpCode = 0
        self.ReqOpCode = 0
        self.RespValue = 0
    }
}

public class DfuHandler {
    let bleManager : BleManager!
    var settings : BluenetSettings!
    let eventBus : EventBus!
    var deviceList : [String: AvailableDevice]!
    
    var cccdNotificationId : Int?
    var notificationPacket : NotifcationPacket
    
    
    init (bleManager:BleManager, eventBus: EventBus, settings: BluenetSettings, deviceList: [String: AvailableDevice]) {
        self.bleManager = bleManager
        self.settings   = settings
        self.eventBus   = eventBus
        self.deviceList = deviceList
        self.notificationPacket = NotifcationPacket()
    }
    
    
    public func processFirmware(firmware: Firmware) -> Promise<Void> {
        return self.enableCccdNotifications()
            .then({notificationSubscription -> Promise<Void> in
                self.cccdNotificationId = notificationSubscription
                return self.sendOpcode(1)
            })
            .then({_ in self.writeImageSize(firmware)})
            .then({_ in self.writeImageSize(firmware)})
    }
    
    func enableCccdNotifications() -> Promise<Int> {
        let callback = {result in print(result)}
        return self.bleManager.enableNotifications(
            DFUServices.DFU,
            characteristicId: DFUCharacteristics.ControlPoint,
            callback: callback
        )
    }
    
    func sendOpcode(code: UInt8) -> Promise<Void> {
        let packet : [UInt8] = [code]
        return self.bleManager.writeToCharacteristic(
            DFUServices.DFU,
            characteristicId: DFUCharacteristics.ControlPoint,
            data: NSData(bytes: packet, length: packet.count),
            type: CBCharacteristicWriteType.WithResponse
        )
    }
    
    func writeImageSize(firmware: Firmware) -> Promise<Void> {
        let packet = firmware.getSizePacket()
        
        // clear the notification so we can listen for the change.
        self.notificationPacket.clear()
        return self.bleManager.writeToCharacteristic(
            DFUServices.DFU,
            characteristicId: DFUCharacteristics.Packet,
            data: NSData(bytes: packet, length: packet.count),
            type: CBCharacteristicWriteType.WithoutResponse
        )
    }
    
    
    func writeInitData(firmware: Firmware) -> Promise<Void> {
        let packet : [UInt8] = [0x02]
        return self.bleManager.writeToCharacteristic(
            DFUServices.DFU,
            characteristicId: DFUCharacteristics.ControlPoint,
            data: NSData(bytes: packet, length: packet.count),
            type: CBCharacteristicWriteType.WithResponse
        )
    }
    
    
   
    
   // public func writePackets(firmware: [UInt8]) -> Promise<Void> {
        
   // }
    
    /**
     * Set the switch state. If 0 or 1, switch on or off. If 0 < x < 1 then dim.
     * TODO: currently only relay is supported.
     */
    public func writePacket(state: NSNumber) -> Promise<Void> {
        print ("------ BLUENET_LIB: switching to \(state)")
        let roundedState = max(0, min(255, round(state.doubleValue * 255)))
        let switchState = UInt8(roundedState)
        let packet : [UInt8] = [switchState]
        return self.bleManager.writeToCharacteristic(
            CSServices.PowerService,
            characteristicId: PowerCharacteristics.Relay,
            data: NSData(bytes: packet, length: packet.count),
            type: CBCharacteristicWriteType.WithoutResponse
        )
    }
    
}
