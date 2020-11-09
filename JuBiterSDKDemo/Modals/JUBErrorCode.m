//
//  JUBErrorCode.m
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/9/7.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBErrorCode.h"
//#import "JubSDKCore/JubSDKCore+DEV_BIO.h"

@implementation JUBErrorCode


+ (NSString*) GetErrMsg:(NSUInteger)rv {
    
    NSString* errMsg;
    switch (rv) {
    // JubSDKCore.h
    case JUBR_OK:                   { errMsg = @"JUBR_OK"; break; }
    case JUBR_ERROR:                { errMsg = @"JUBR_ERROR"; break; }
    case JUBR_HOST_MEMORY:          { errMsg = @"JUBR_HOST_MEMORY"; break; }
    case JUBR_ARGUMENTS_BAD:        { errMsg = @"JUBR_ARGUMENTS_BAD"; break; }
    case JUBR_IMPL_NOT_SUPPORT:     { errMsg = @"JUBR_IMPL_NOT_SUPPORT"; break; }
    case JUBR_MEMORY_NULL_PTR:      { errMsg = @"JUBR_MEMORY_NULL_PTR"; break; }
    case JUBR_INVALID_MEMORY_PTR:   { errMsg = @"JUBR_INVALID_MEMORY_PTR"; break; }
    case JUBR_REPEAT_MEMORY_PTR:    { errMsg = @"JUBR_REPEAT_MEMORY_PTR"; break; }
    case JUBR_BUFFER_TOO_SMALL:     { errMsg = @"JUBR_BUFFER_TOO_SMALL"; break; }
    case JUBR_MULTISIG_OK:          { errMsg = @"JUBR_MULTISIG_OK"; break; }
    
    // JubSDKCore+DEV.h
    case JUBR_INIT_DEVICE_LIB_ERROR:{ errMsg = @"JUBR_INIT_DEVICE_LIB_ERROR"; break; }
    case JUBR_CONNECT_DEVICE_ERROR: { errMsg = @"JUBR_CONNECT_DEVICE_ERROR"; break; }
    case JUBR_TRANSMIT_DEVICE_ERROR:{ errMsg = @"JUBR_TRANSMIT_DEVICE_ERROR"; break; }
    case JUBR_NOT_CONNECT_DEVICE:   { errMsg = @"JUBR_NOT_CONNECT_DEVICE"; break; }
    case JUBR_DEVICE_PIN_ERROR:     { errMsg = @"JUBR_DEVICE_PIN_ERROR"; break; }
    case JUBR_USER_CANCEL:          { errMsg = @"JUBR_USER_CANCEL"; break; }
    case JUBR_ERROR_ARGS:           { errMsg = @"JUBR_ERROR_ARGS"; break; }
    case JUBR_PIN_LOCKED:           { errMsg = @"JUBR_PIN_LOCKED"; break; }
    
    case JUBR_DEVICE_BUSY:          { errMsg = @"JUBR_DEVICE_BUSY"; break; }
    case JUBR_TRANSACT_TIMEOUT:     { errMsg = @"JUBR_TRANSACT_TIMEOUT"; break; }
    case JUBR_OTHER_ERROR:          { errMsg = @"JUBR_OTHER_ERROR"; break; }
    case JUBR_CMD_ERROR:            { errMsg = @"JUBR_CMD_ERROR"; break; }
    case JUBR_BT_BOND_FAILED:       { errMsg = @"JUBR_BT_BOND_FAILED"; break; }
    
//    // JubSDKCore+DEV_BIO.h
//    case JUBR_BIO_FINGERPRINT_MODALITY_ERROR:{ errMsg = @"JUBR_BIO_FINGERPRINT_MODALITY_ERROR"; break; }
//    case JUBR_BIO_SPACE_LIMITATION: { errMsg = @"JUBR_BIO_SPACE_LIMITATION"; break; }
//    case JUBR_BIO_TIMEOUT:          { errMsg = @"JUBR_BIO_TIMEOUT"; break; }
    
    default:                        { errMsg = @"UNKNOWN ERROR."; break; }
    }   // switch (rv) end
    
    return errMsg;
}


@end
