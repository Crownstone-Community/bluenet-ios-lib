//
//  characteristics.swift
//  BluenetLibIOS
//
//  Created by Alex de Mulder on 13/06/16.
//  Copyright © 2016 Alex de Mulder. All rights reserved.
//

import Foundation

/*
 *
 *
 *  These are valid for SDK 0.4.1
 *
 *
 */

public struct CrownstoneCharacteristics {
    public static let Control          = "24f00001-7d10-4805-bfc1-7663a01c3bff"
    public static let MeshControl      = "24f00002-7d10-4805-bfc1-7663a01c3bff"
    public static let ConfigControl    = "24f00004-7d10-4805-bfc1-7663a01c3bff"
    public static let ConfigRead       = "24f00005-7d10-4805-bfc1-7663a01c3bff"
    public static let StateControl     = "24f00006-7d10-4805-bfc1-7663a01c3bff"
    public static let StateRead        = "24f00007-7d10-4805-bfc1-7663a01c3bff"
}

public struct SetupCharacteristics {
    public static let Control          = "24f10001-7d10-4805-bfc1-7663a01c3bff"
    public static let MAC              = "24f10002-7d10-4805-bfc1-7663a01c3bff"
}

public struct GeneralCharacteristics {
    public static let Temperature      = "24f20001-7d10-4805-bfc1-7663a01c3bff"
    public static let Reset            = "24f20002-7d10-4805-bfc1-7663a01c3bff"
}

public struct PowerCharacteristics {
    public static let PWM              = "24f30001-7d10-4805-bfc1-7663a01c3bff"
    public static let Relay            = "24f30002-7d10-4805-bfc1-7663a01c3bff"
    public static let PowerSamples     = "24f30003-7d10-4805-bfc1-7663a01c3bff"
    public static let PowerConsumption = "24f30004-7d10-4805-bfc1-7663a01c3bff"
}

public struct IndoorLocalizationCharacteristics {
    public static let TrackControl     = "24f40001-7d10-4805-bfc1-7663a01c3bff"
    public static let TrackedDevices   = "24f40002-7d10-4805-bfc1-7663a01c3bff"
    public static let ScanControl      = "24f40003-7d10-4805-bfc1-7663a01c3bff"
    public static let ScannedDevices   = "24f40004-7d10-4805-bfc1-7663a01c3bff"
    public static let RSSI             = "24f40005-7d10-4805-bfc1-7663a01c3bff"
}

public struct ScheduleCharacteristics {
    public static let SetTime          = "24f50001-7d10-4805-bfc1-7663a01c3bff"
    public static let ScheduleWrite    = "24f50002-7d10-4805-bfc1-7663a01c3bff"
    public static let ScheduleRead     = "24f50003-7d10-4805-bfc1-7663a01c3bff"
}

public struct MeshCharacteristics {
    public static let MeshData         = "2a1e0004-fd51-d882-8ba8-b98c0000cd1e"
    public static let Value            = "2a1e0005-fd51-d882-8ba8-b98c0000cd1e"
}