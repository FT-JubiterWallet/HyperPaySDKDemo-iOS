//
//  JUBSharedData.m
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/10.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"


JubSDKCore* g_sdk;


@implementation JUBSharedData
@synthesize currDeviceID = _currDeviceID;

static JUBSharedData *_sharedDataInstance;


- (id) init {
    
    if (self = [super init]) {
        // custom initialization
        if (nil == g_sdk) {
            g_sdk = [[JubSDKCore alloc] init];
        }
        
        _optItem = 0;
        
        _userPin = nil;
        _neoPin = nil;
        
        _verifyMode = VERIFY_MODE_ITEM;
        _deviceType = SEG_BLE;
        _coinUnit = NS_BTC_UNIT_TYPE_NS;
        _comMode = NS_COMMODE_NS_ITEM;
        _deviceClass = NS_DEVICE_NS_ITEM;
        
        _currPath = [[BIP32Path alloc] init];
        
        _currDeviceID = 0;
        _currContextID = 0;
    }
    
    return self;
}


+ (JUBSharedData *) sharedInstance {
    
    if (!_sharedDataInstance) {
        _sharedDataInstance = [[JUBSharedData alloc] init];
    }
    
    return _sharedDataInstance;
}


@end
