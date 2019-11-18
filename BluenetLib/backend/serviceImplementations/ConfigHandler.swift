//
//  ConfigHandler.swift
//  BluenetLibIOS
//
//  Created by Alex de Mulder on 10/08/16.
//  Copyright © 2016 Alex de Mulder. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBluetooth

public class ConfigHandler {
    let bleManager : BleManager!
    var settings : BluenetSettings!
    let eventBus : EventBus!
    
    init (bleManager:BleManager, eventBus: EventBus, settings: BluenetSettings) {
        self.bleManager = bleManager
        self.settings   = settings
        self.eventBus   = eventBus
    }
    
    public func setIBeaconUUID(_ uuid: String) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.ibeacon_UUID).load(uuid)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getDimmerTempUp() -> Promise<Float> {
        return self._getConfig(ConfigurationType.DIMMER_TEMP_UP_VOLTAGE)
    }
    
    public func setDimmerTempUp(_ voltage: Float) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.DIMMER_TEMP_UP_VOLTAGE).load(voltage)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setIBeaconMajor(_ major: UInt16) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.ibeacon_MAJOR).load(major)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setIBeaconMinor(_ minor: UInt16) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.ibeacon_MINOR).load(minor)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setPWMPeriod(_ pwmPeriod: NSNumber) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.pwm_PERIOD).load(pwmPeriod.uint32Value)
        return self._writeToConfig(packet: data.getPacket())
    }

    
    public func getPWMPeriod() -> Promise<NSNumber> {
        return Promise<NSNumber> { seal in
            let configPromise : Promise<UInt32> = self._getConfig(ConfigurationType.pwm_PERIOD)
            configPromise
                .done{ period -> Void in seal.fulfill(NSNumber(value: period)) }
                .catch{err in seal.reject(err)}
        }
    }
    
    public func setScanDuration(_ scanDurationsMs: NSNumber) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.scan_DURATION).load(scanDurationsMs.uint16Value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setScanSendDelay(_ scanSendDelay: NSNumber) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.scan_SEND_DELAY).load(scanSendDelay.uint16Value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setScanBreakDuration(_ scanBreakDuration: NSNumber) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.scan_BREAK_DURATION).load(scanBreakDuration.uint16Value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setScanFilter(_ scanFilter: NSNumber) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.scan_BREAK_DURATION).load(scanFilter.uint8Value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func setScanFilterFraction(_ scanFilterFraction: NSNumber) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.scan_FILTER_FRACTION).load(scanFilterFraction.uint16Value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getSwitchcraftThreshold() -> Promise<Float> {
        return self._getConfig(ConfigurationType.SWITCHCRAFT_THRESHOLD)
    }
    
    public func setSwitchcraftThreshold(value: Float) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.SWITCHCRAFT_THRESHOLD).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getMaxChipTemp() -> Promise<Int8> {
        return self._getConfig(ConfigurationType.max_CHIP_TEMP)
    }
    
    public func setMaxChipTemp(value: Int8) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.max_CHIP_TEMP).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getDimmerCurrentThreshold() -> Promise<UInt16> {
        return self._getConfig(ConfigurationType.CURRENT_CONSUMPTION_THRESHOLD_DIMMER)
    }
    
    public func setDimmerCurrentThreshold(value: UInt16) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.CURRENT_CONSUMPTION_THRESHOLD_DIMMER).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getDimmerTempUpThreshold() -> Promise<Float> {
        return self._getConfig(ConfigurationType.DIMMER_TEMP_UP_VOLTAGE)
    }
    
    public func setDimmerTempUpThreshold(value: Float) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.DIMMER_TEMP_UP_VOLTAGE).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getDimmerTempDownThreshold() -> Promise<Float> {
        return self._getConfig(ConfigurationType.DIMMER_TEMP_DOWN_VOLTAGE)
    }
    
    public func setDimmerTempDownThreshold(value: Float) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.DIMMER_TEMP_DOWN_VOLTAGE).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getVoltageZero() -> Promise<Int32> {
        return self._getConfig(ConfigurationType.voltage_ZERO)
    }
    
    public func setVoltageZero(value: Int32) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.voltage_ZERO).load(Conversion.int32_to_uint32(value))
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getCurrentZero() -> Promise<Int32> {
        return self._getConfig(ConfigurationType.current_ZERO)
    }
    
    public func setCurrentZero(value: Int32) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.current_ZERO).load(Conversion.int32_to_uint32(value))
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getPowerZero() -> Promise<Int32> {
        return self._getConfig(ConfigurationType.power_ZERO)
    }
    
    public func setPowerZero(value: Int32) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.power_ZERO).load(Conversion.int32_to_uint32(value))
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getVoltageMultiplier() -> Promise<Float> {
        return self._getConfig(ConfigurationType.voltage_MULTIPLIER)
    }
    
    public func setVoltageMultiplier(value: Float) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.voltage_MULTIPLIER).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    public func getCurrentMultiplier() -> Promise<Float> {
        return self._getConfig(ConfigurationType.current_MULITPLIER)
    }
    
    public func setCurrentMultiplier(value: Float) -> Promise<Void> {
        let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.current_MULITPLIER).load(value)
        return self._writeToConfig(packet: data.getPacket())
    }
    
    
    public func setUartState(_ state: NSNumber) -> Promise<Void> {
        return Promise<Void> { seal in
            if (state == 3 || state == 1 || state == 0) {
                let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.UART_ENABLED).load(state.uint8Value)
                self._writeToConfig(packet: data.getPacket())
                    .done{ _ in seal.fulfill(()) }
                    .catch{err in seal.reject(err)}
            }
            else {
                LOG.warn("BluenetLib: setUartState: Only 0, 1, or 3 are allowed inputs. You gave: \(state).")
                seal.reject(BluenetError.INVALID_INPUT)
            }
        }
    }
    
    public func setMeshChannel(_ channel: NSNumber) -> Promise<Void> {
        return Promise<Void> { seal in
            if (channel == 37 || channel == 38 || channel == 39) {
                let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.MESH_CHANNEL).load(channel.uint8Value)
                self._writeToConfig(packet: data.getPacket())
                    .done{ _ in seal.fulfill(()) }
                    .catch{err in seal.reject(err)}
            }
            else {
                LOG.warn("BluenetLib: setMeshChannel: Only 37, 38 or 39 are allowed inputs. You gave: \(channel).")
                seal.reject(BluenetError.INVALID_INPUT)
            }
        }
    }
    
    public func getMeshChannel() -> Promise<NSNumber> {
        return Promise<NSNumber> { seal in
            let configPromise : Promise<UInt8> = self._getConfig(ConfigurationType.MESH_CHANNEL)
            configPromise
                .done{ channel -> Void in seal.fulfill(NSNumber(value: channel)) }
                .catch{err in seal.reject(err)}
        }
    }
    
    public func setSwitchcraft(enabled: Bool) -> Promise<Void> {
        LOG.info("BLUENET_LIB: setSwitchcraft")
        return _writeGenericControlPacket(bleManager: self.bleManager, ControlPacketsGenerator.getSwitchCraftPacket(enabled))
    }
    
    public func setTapToToggle(enabled: Bool) -> Promise<Void> {
        var enabledValue : UInt8 = 1
        if enabled == false {
            enabledValue = 0
        }
        let packet = ControlStateSetPacket.init(type: .TAP_TO_TOGGLE_ENABLED, payload8: enabledValue).getPacket()
        return _writeGenericControlPacket(bleManager: self.bleManager, packet)
    }
    
    public func setTapToToggleThreshold(threshold: Int8) -> Promise<Void> {
        let packet = ControlStateSetPacket.init(type: .TAP_TO_TOGGLE_ENABLED, payload8: Conversion.int8_to_uint8(threshold)).getPacket()
        return _writeGenericControlPacket(bleManager: self.bleManager, packet)
    }
    
    public func setTxPower (_ txPower: NSNumber) -> Promise<Void> {
        return Promise<Void> { seal in
            if (txPower == -40 || txPower == -30 || txPower == -20 || txPower == -16 || txPower == -12 || txPower == -8 || txPower == -4 || txPower == 0 || txPower == 4) {
                let data = StatePacketsGenerator.getWritePacket(type: ConfigurationType.tx_POWER).load(txPower.int8Value)
                self._writeToConfig(packet: data.getPacket())
                    .done{ _ in seal.fulfill(()) }
                    .catch{ err in seal.reject(err) }
            }
            else {
                seal.reject(BluenetError.INVALID_TX_POWER_VALUE)
            }
        }
    }
    
    func _writeToConfig(packet: [UInt8]) -> Promise<Void> {
        if self.bleManager.connectionState.operationMode == .setup {
            if self.bleManager.connectionState.controlVersion == .v2 {
                return self.bleManager.writeToCharacteristic(
                    CSServices.SetupService,
                    characteristicId: SetupCharacteristics.SetupControlV3,
                    data: Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count),
                    type: CBCharacteristicWriteType.withResponse
                )
            }
            else {
                return self.bleManager.writeToCharacteristic(
                   CSServices.SetupService,
                   characteristicId: SetupCharacteristics.ConfigControl,
                   data: Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count),
                   type: CBCharacteristicWriteType.withResponse
               )
            }
            
        }
        else {
            if self.bleManager.connectionState.controlVersion == .v2 {                
                return self.bleManager.writeToCharacteristic(
                    CSServices.CrownstoneService,
                    characteristicId: CrownstoneCharacteristics.ControlV2,
                    data: Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count),
                    type: CBCharacteristicWriteType.withResponse
                )
            }
            else {
                return self.bleManager.writeToCharacteristic(
                    CSServices.CrownstoneService,
                    characteristicId: CrownstoneCharacteristics.ConfigControl,
                    data: Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count),
                    type: CBCharacteristicWriteType.withResponse
                )
            }
        }
    }
    
    
    public func _getConfig<T>(_ config : ConfigurationType) -> Promise<T> {
        return self._getConfig(StateTypeV2(rawValue: UInt16(config.rawValue))!)
    }
    
    public func _getConfig<T>(_ config : StateTypeV2) -> Promise<T> {
        let readParams = _getConfigReadParameters()
            
        return Promise<T> { seal in
            let writeCommand : voidPromiseCallback = {
                return self._writeToConfig(packet: StatePacketsGenerator.getReadPacket(type: config).getPacket())
            }
            self.bleManager.setupSingleNotification(readParams.service, characteristicId: readParams.characteristicToReadFrom, writeCommand: writeCommand)
                .done{ data -> Void in
                    let resultPacket = StatePacketsGenerator.getReturnPacket()
                    resultPacket.load(data)
                    
                    if (resultPacket.valid == false) {
                        return seal.reject(BluenetError.INCORRECT_RESPONSE_LENGTH)
                    }
                                        
                    do {
                        let result : T = try Convert(resultPacket.payload)
                        seal.fulfill(result)
                    }
                    catch let err {
                        seal.reject(err)
                    }
                
                }
                .catch{ err in seal.reject(err) }
        }
       
    }

    
    func _getConfigReadParameters() -> ReadParamaters {
        var service                  = CSServices.CrownstoneService;
        var characteristicToReadFrom = CrownstoneCharacteristics.ConfigRead
        
        //determine where to write
        if self.bleManager.connectionState.controlVersion == .v2 {
            characteristicToReadFrom = CrownstoneCharacteristics.ResultV2
        }
        if self.bleManager.connectionState.operationMode == .setup {
            service = CSServices.SetupService;
            if self.bleManager.connectionState.controlVersion == .v2 {
                characteristicToReadFrom = SetupCharacteristics.ResultV2
            }
            else {
                characteristicToReadFrom = SetupCharacteristics.ConfigRead
            }
        }
        return ReadParamaters(service: service, characteristicToReadFrom: characteristicToReadFrom)
    }
}


struct ReadParamaters {
    var service: String
    var characteristicToReadFrom: String
}
