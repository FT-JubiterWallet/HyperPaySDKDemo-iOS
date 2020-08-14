//
//  JUBSharedData.h
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/10.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JubSDKCore/JUB_SDK_BTC.h>


typedef NS_ENUM(NSInteger, JUB_NS_ENUM_DEV_TYPE) {
    SEG_NFC,
    SEG_BLE
};


typedef enum : NSUInteger {
    VKPIN = 0x02,
    PIN,
    FGPT,
    VERIFY_MODE_ITEM
} JUB_NS_ENUM_VERIFY_MODE;


@interface JUBSharedData : NSObject

@property (nonatomic, assign) NSInteger optItem;

@property (nonatomic, strong) NSString* userPin;
@property (nonatomic, strong) NSString* neoPin;
@property (nonatomic, assign) JUB_NS_ENUM_VERIFY_MODE verifyMode;
@property (nonatomic, assign) JUB_NS_ENUM_DEV_TYPE deviceType;
@property (nonatomic, assign) JUB_ENUM_BTC_UNIT_TYPE coinUnit;

//@property (nonatomic, weak) UIViewController* selfClass;
@property (nonatomic, strong) NSNumber* currDeviceID;
@property (nonatomic, strong) NSNumber* currContextID;

+ (JUBSharedData *) sharedInstance;

@end
