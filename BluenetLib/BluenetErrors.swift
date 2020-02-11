//
//  BluenetErrors.swift
//  BluenetLib
//
//  Created by Alex de Mulder on 04/12/2018.
//  Copyright © 2018 Alex de Mulder. All rights reserved.
//

import Foundation

public enum BluenetError : Error {
    case DISCONNECTED
    case CONNECTION_CANCELLED
    case CONNECTION_FAILED
    case NOT_CONNECTED
    case NO_SERVICES
    case NO_CHARACTERISTICS
    case SERVICE_DOES_NOT_EXIST
    case CHARACTERISTIC_DOES_NOT_EXIST
    case WRONG_TYPE_OF_PROMISE
    case INVALID_UUID
    case NOT_INITIALIZED
    case CANNOT_SET_TIMEOUT_WITH_THIS_TYPE_OF_PROMISE
    case TIMEOUT
    case DISCONNECT_TIMEOUT
    case ERROR_DISCONNECT_TIMEOUT
    case AWAIT_DISCONNECT_TIMEOUT
    case CANCEL_PENDING_CONNECTION_TIMEOUT
    case CONNECT_TIMEOUT
    case GET_SERVICES_TIMEOUT
    case GET_CHARACTERISTICS_TIMEOUT
    case READ_CHARACTERISTIC_TIMEOUT
    case WRITE_CHARACTERISTIC_TIMEOUT
    case ENABLE_NOTIFICATIONS_TIMEOUT
    case NOTIFICATION_STREAM_TIMEOUT
    case DISABLE_NOTIFICATIONS_TIMEOUT
    case CANNOT_WRITE_AND_VERIFY
    case CAN_NOT_CONNECT_TO_UUID
    case COULD_NOT_FACTORY_RESET
    case INCORRECT_RESPONSE_LENGTH
    case UNKNOWN_TYPE
    
    case INVALID_DATA_LENGTH
    
    case COULD_NOT_GET_LOCATION
    
    // encryption errors
    case INVALID_SESSION_REFERENCE_ID
    case INVALID_SESSION_DATA
    case NO_SESSION_NONCE_SET
    case COULD_NOT_VALIDATE_SESSION_NONCE
    case INVALID_SIZE_FOR_ENCRYPTED_PAYLOAD
    case INVALID_SIZE_FOR_SESSION_NONCE_PACKET
    case INVALID_PACKAGE_FOR_ENCRYPTION_TOO_SHORT
    case INVALID_KEY_FOR_ENCRYPTION
    case DO_NOT_HAVE_ENCRYPTION_KEY
    case COULD_NOT_ENCRYPT
    case COULD_NOT_ENCRYPT_KEYS_NOT_SET
    case COULD_NOT_DECRYPT_KEYS_NOT_SET
    case COULD_NOT_DECRYPT
    case CAN_NOT_GET_PAYLOAD
    case USERLEVEL_IN_READ_PACKET_INVALID
    case READ_SESSION_NONCE_ZERO_MAYBE_ENCRYPTION_DISABLED
    case SETUP_FAILED
    
    // recovery error
    case NOT_IN_RECOVERY_MODE
    case CANNOT_READ_FACTORY_RESET_CHARACTERISTIC
    case RECOVER_MODE_DISABLED
    
    // input errors
    case INVALID_TX_POWER_VALUE
    
    // mesh
    case NO_KEEPALIVE_STATE_ITEMS
    case NO_SWITCH_STATE_ITEMS
    
    // DFU
    case DFU_OVERRULED
    case DFU_ABORTED
    case DFU_ERROR
    case COULD_NOT_FIND_PERIPHERAL
    case PACKETS_DO_NOT_MATCH
    case NOT_IN_DFU_MODE
    
    // promise errors
    case REPLACED_WITH_OTHER_PROMISE
    case BLE_RESET
    
    
    // timer errors
    case INCORRECT_SCHEDULE_ENTRY_INDEX
    case INCORRECT_DATA_COUNT_FOR_ALL_TIMERS
    case NO_SCHEDULE_ENTRIES_AVAILABLE
    case NO_TIMER_FOUND
    
    // process errors
    case PROCESS_ABORTED_WITH_ERROR
    case UNKNOWN_PROCESS_TYPE
    
    // general errors
    case INVALID_INPUT
    
    // Broadcast Protocol errors
    case INVALID_BROADCAST_ACCESS_LEVEL
    case INVALID_BROADCAST_LOCATION_ID
    case INVALID_BROADCAST_PROFILE_INDEX
    case INVALID_BROADCAST_PAYLOAD_SIZE
    
    case BROADCAST_ERROR
    case BROADCAST_ABORTED
    
    
    // behaviour errors
    case BEHAVIOUR_INDEX_OUT_OF_RANGE
    
    case BEHAVIOUR_INVALID
    case BEHAVIOUR_INVALID_RESPONSE
    case BEHAVIOUR_NOT_FOUND_AT_INDEX
    
    case PROFILE_INDEX_MISSING
    case TYPE_MISSING
    case DATA_MISSING
    case ACTIVE_DAYS_MISSING
    case ACTIVE_DAYS_INVALID
    case NO_ACTIVE_DAYS
    case BEHAVIOUR_ACTION_MISSING
    case BEHAVIOUR_TIME_MISSING
    case BEHAVIOUR_INTENSITY_MISSING
    case TWILIGHT_CANT_HAVE_PRESENCE
    case TWILIGHT_CANT_HAVE_END_CONDITION
    case NO_TIME_TYPE
    case INVALID_TIME_TYPE
    case MISSING_TO_TIME
    case MISSING_FROM_TIME
    case MISSING_TO_TIME_TYPE
    case MISSING_FROM_TIME_DATA
    case MISSING_TO_TIME_DATA
    case MISSING_FROM_TIME_TYPE
    case INVALID_TIME_FROM_TYPE
    case INVALID_TIME_TO_TYPE
    case INVALID_FROM_DATA
    case INVALID_TO_DATA

    case INVALID_PRESENCE_TYPE
    case NO_PRESENCE_TYPE
    case NO_PRESENCE_DATA
    case NO_PRESENCE_DELAY
    case NO_PRESENCE_LOCATION_IDS
    
    case NO_END_CONDITION_TYPE
    case NO_END_CONDITION_PRESENCE
    case NO_END_CONDITION_DURATION
    
    case FIRMWARE_TOO_OLD
    case ERR_ALREADY_EXISTS
}


