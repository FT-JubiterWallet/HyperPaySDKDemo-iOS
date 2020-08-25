//
//  JUBDetailBaseController.h
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/9.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JubSDKCore/JubSDKCore+DEV_BLE.h"
#import "JubSDKCore/JubSDKCore+DEV_BIO.h"
#include "JUB_SDK_main.h"

#import "JUBHomeController.h"


NS_ASSUME_NONNULL_BEGIN

@class JUBDetailBaseController;
static JUBDetailBaseController *cSelf;

int  BLEReadFuncCallBack(unsigned long int devHandle,  unsigned char* data, unsigned int dataLen);
void BLEScanFuncCallBack(unsigned char* devName, unsigned char* uuid, unsigned int type);
void BLEDiscFuncCallBack(unsigned char* uuid);


@interface JUBDetailBaseController : JUBCoinTestDetailBaseController

//@property (weak, nonatomic, readwrite) JUBDetailBaseController *selfClass;
@property (nonatomic, nonatomic, readwrite) NSInteger optItem;

@property (nonatomic, nonatomic, readwrite) long optCoinType;
@property (nonatomic, nonatomic, readwrite) long optIndex;

- (void)beginBLESession;


#pragma mark - 操作菜单 通讯库寻卡回调
- (void)MenuOption:(NSUInteger)deviceID;


#pragma mark - Device 通讯库寻卡回调
- (void)DeviceOpt:(NSUInteger)deviceID;


#pragma mark - BTC 通讯库寻卡回调
- (void)CoinBTCOpt:(NSUInteger)deviceID;


#pragma mark - ETH 通讯库寻卡回调
- (void)CoinETHOpt:(NSUInteger)deviceID;


#pragma mark - EOS 通讯库寻卡回调
- (void)CoinEOSOpt:(NSUInteger)deviceID;


#pragma mark - XRP 通讯库寻卡回调
- (void)CoinXRPOpt:(NSUInteger)deviceID;


@end


NS_ASSUME_NONNULL_END
