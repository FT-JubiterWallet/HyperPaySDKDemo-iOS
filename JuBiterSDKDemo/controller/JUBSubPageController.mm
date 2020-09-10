//
//  JUBSubPageController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/9.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBScanDeviceInfo.h"
#import "JUBNotification.h"

#import "JUBSubPageController.h"

#pragma mark - BLE 通讯库寻卡回调
int BLEReadFuncCallBack(unsigned long int devHandle, unsigned char* data, unsigned int dataLen) {
    
    return -1;
}


void BLEScanFuncCallBack(unsigned char* devName, unsigned char* uuid, unsigned int type) {
    
    NSLog(@"Scan: [%s:%s:0x%u]", devName, uuid, type);
    
    JUBScanDeviceInfo* deviceInfo = [[JUBScanDeviceInfo alloc] init];
    deviceInfo.name = [NSString stringWithCString:(char*)devName
                                         encoding:NSUTF8StringEncoding];
    deviceInfo.uuid = [NSString stringWithCString:(char*)uuid
                                         encoding:NSUTF8StringEncoding];
    deviceInfo.type = NSUInteger(type);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DEVICE_SCAN
                                                        object:nil
                                                      userInfo:@{SCAN_DEVICE_INFO_UUID:[NSString stringWithCString:(char*)uuid
                                                                                            encoding:NSUTF8StringEncoding],
                                                                 SCAN_DEVICE_INFO_DEVICE:deviceInfo}];
}


void BLEDiscFuncCallBack(unsigned char* uuid) {
    
    NSLog(@"Disc: [%s]", uuid);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DEVICE_DISC
                                                        object:nil
                                                      userInfo:@{SCAN_DEVICE_INFO_UUID:[NSString stringWithCString:(char*)uuid
                                                                                            encoding:NSUTF8StringEncoding]}];
}


@interface JUBSubPageController ()

@end


@implementation JUBSubPageController
//@synthesize selfClass;
@synthesize optItem;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cSelf = self;
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    cSelf = nil;
}


- (void) beginBLESession {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
//    [data setSelfClass:self.selfClass];
    [sharedData setOptItem:self.optItem];
    
    [self MenuOption:[sharedData currDeviceID]];
}


#pragma mark - 操作菜单 通讯库寻卡回调
- (void) MenuOption:(NSUInteger)deviceID {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
//    JUBSubPageController *selfClass = (JUBSubPageController*)data.selfClass;
    
    switch ([sharedData optItem]) {
    case JUB_NS_ENUM_MAIN::OPT_DEVICE:
    {
        JUBAlertView *alertView = [JUBAlertView showMsg:@"Processing..."];
        {
            [self DeviceOpt:deviceID];
            [alertView dismiss];
        }
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_BTC:
    {
        [self CoinBTCOpt:deviceID];
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_ETH:
    {
        [self CoinETHOpt:deviceID];
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_EOS:
    {
        [self CoinEOSOpt:deviceID];
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_XRP:
    {
        [self CoinXRPOpt:deviceID];
        break;
    }
    default:
        break;
    }   // switch (data.optItem) end
}


#pragma mark - Device 通讯库寻卡回调
- (void) DeviceOpt:(NSUInteger)deviceID {
    
}


#pragma mark - BTC 通讯库寻卡回调
- (void) CoinBTCOpt:(NSUInteger)deviceID {
    
}


#pragma mark - ETH 通讯库寻卡回调
- (void) CoinETHOpt:(NSUInteger)deviceID {
    
}


#pragma mark - EOS 通讯库寻卡回调
- (void) CoinEOSOpt:(NSUInteger)deviceID {
    
}


#pragma mark - XRP 通讯库寻卡回调
- (void) CoinXRPOpt:(NSUInteger)deviceID {
    
}


@end
