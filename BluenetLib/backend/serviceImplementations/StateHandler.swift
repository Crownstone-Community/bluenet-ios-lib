//
//  StateHandler
//  BluenetLibIOS
//
//  Created by Alex de Mulder on 10/08/16.
//  Copyright © 2016 Alex de Mulder. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBluetooth

open class StateHandler {
    let bleManager : BleManager!
    var settings : BluenetSettings!
    let eventBus : EventBus!
    var deviceList : [String: AvailableDevice]!
    
    init (bleManager:BleManager, eventBus: EventBus, settings: BluenetSettings, deviceList: [String: AvailableDevice]) {
        self.bleManager = bleManager
        self.settings   = settings
        self.eventBus   = eventBus
        self.deviceList = deviceList
    }
    
    
    open func getErrors() -> Promise<CrownstoneErrors> {
        return Promise<CrownstoneErrors> { fulfill, reject in
            self.getErrorBitmask()
                .then{ data -> Void in
                    let relevantDataArray = [data[4],data[5],data[6],data[7]]
                    let uint32 = Conversion.uint8_array_to_uint32(relevantDataArray)
                    let csError = CrownstoneErrors(bitMask: uint32)
                    fulfill(csError)
                }
                .catch{ err in reject(err) }
        }
    }
    
    open func getErrorBitmask() -> Promise<[UInt8]> {        
        return self.bleManager.setupSingleNotification(CSServices.CrownstoneService, characteristicId: CrownstoneCharacteristics.StateRead) { () -> Promise<Void> in
            return self.bleManager.writeToCharacteristic(
                CSServices.CrownstoneService,
                characteristicId: CrownstoneCharacteristics.StateControl,
                data: NotificationStatePacket(type: StateType.error_BITMASK).getNSData(),
                type: CBCharacteristicWriteType.withResponse
            )
        }
    }
    
    open func getTime() -> Promise<NSNumber> {
        return Promise<NSNumber> { fulfill, reject in
            let timePromise : Promise<UInt32> = self._getState(StateType.time)
            timePromise.then{ time -> Void in fulfill(NSNumber(value: time))}.catch{ err in reject(err) }
        }
    }
    
    func _writeToState(packet: [UInt8]) -> Promise<Void> {
        return self.bleManager.writeToCharacteristic(
            CSServices.CrownstoneService,
            characteristicId: CrownstoneCharacteristics.StateControl,
            data: Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count),
            type: CBCharacteristicWriteType.withResponse
        )
    }
    
    public func _getState<T>(_ state : StateType) -> Promise<T> {
        return Promise<T> { fulfill, reject in
            let writeCommand : voidPromiseCallback = { _ in
                return self.bleManager.writeToCharacteristic(
                    CSServices.CrownstoneService,
                    characteristicId: CrownstoneCharacteristics.StateControl,
                    data: NotificationStatePacket(type: state).getNSData(),
                    type: CBCharacteristicWriteType.withResponse);
            }
            self.bleManager.setupSingleNotification(CSServices.CrownstoneService, characteristicId: CrownstoneCharacteristics.StateRead, writeCommand: writeCommand)
                .then{ data -> Void in
                    var validData = [UInt8]()
                    if (data.count > 3) {
                        for i in (4...data.count - 1) {
                            validData.append(data[i])
                        }
                        
                        do {
                            let result : T = try Convert(validData)
                            fulfill(result)
                        }
                        catch let err {
                            reject(err)
                        }
                    }
                    else {
                        reject(BleError.INCORRECT_RESPONSE_LENGTH)
                    }
                }
                .catch{ err in reject(err) }
        }
    }
    
}
