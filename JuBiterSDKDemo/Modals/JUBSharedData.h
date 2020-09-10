//
//  JUBSharedData.h
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/10.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JuBiterSDKUI/JuBiterSDKUI.h>

#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+DEV_BLE.h"
#import "JubSDKCore/JubSDKCore+COIN_BTC.h"


extern JubSDKCore* g_sdk;


typedef NS_ENUM(NSInteger, JUB_NS_ENUM_DEV_TYPE) {
    SEG_BLE
};


typedef enum : NSUInteger {
    VKPIN = 0x02,
    PIN,
    FGPT,
    VERIFY_MODE_ITEM
} JUB_NS_ENUM_VERIFY_MODE;


#define BUTTON_TITLE_USE_VK     @"Use virtual keyboard"
#define BUTTON_TITLE_USE_FGPT   @"Use fingerprint"
#define BUTTON_TITLE_USE_PIN    @"Use PIN"


@interface JUBSharedData : NSObject

@property (nonatomic, assign) NSInteger optItem;

@property (nonatomic, strong) NSString* userPin;
@property (nonatomic, strong) NSString* neoPin;
@property (nonatomic, strong) NSString* amount;
@property (nonatomic, assign) JUB_NS_ENUM_VERIFY_MODE verifyMode;
@property (nonatomic, assign) JUB_NS_ENUM_DEV_TYPE deviceType;
@property (nonatomic, assign) JUB_NS_BTC_UNIT_TYPE coinUnit;
@property (nonatomic, assign) JUB_NS_ENUM_COMMODE comMode;
@property (nonatomic, assign) JUB_NS_ENUM_DEVICE  deviceClass;

//@property (nonatomic, weak) UIViewController* selfClass;
@property (nonatomic, strong) NSString*  currMainPath;
@property (nonatomic, strong) BIP32Path* currPath;
@property (nonatomic, assign) NSUInteger currCoinType;

@property (nonatomic, assign) NSUInteger currDeviceID;
@property (nonatomic, assign) NSUInteger currContextID;

+ (JUBSharedData *) sharedInstance;

@end
