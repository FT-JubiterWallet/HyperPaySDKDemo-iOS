//
//  JUBHomeController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/13.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBScanDeviceInfo.h"
#import "JUBDevicePool.h"
#import "JUBNotification.h"

#import "JUBHomeController.h"
#import "JUBFgptMgrController.h"
#import "JUBDeviceController.h"
#import "JUBBTCController.h"
#import "JUBETHController.h"
//#import "JUBEOSController.h"
//#import "JUBXRPController.h"


@interface JUBHomeController ()
@property (nonatomic, weak) UIButton *disConnectBLEButton;
@property (nonatomic, weak) NSTimer* scanDeviceTimer;
@property (nonatomic, strong) NSMutableDictionary* scanDeviceDict;
@property (nonatomic, strong) NSMutableDictionary* connDeviceDict;
@property (nonatomic, weak) JUBBLEDeviceScanListView* BLEDeviceScanListView;
@end


@implementation JUBHomeController
@synthesize disConnectBLEButton;
@synthesize scanDeviceTimer;
@synthesize scanDeviceDict;
@synthesize connDeviceDict;


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scanDeviceDict = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceArrivalObserver:)
                                                 name:NSNotificationName(NOTIF_DEVICE_ARRVL)
                                               object:[JUBDevicePool shareDevicePool]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceScanObserver:)
                                                 name:NSNotificationName(NOTIF_DEVICE_SCAN)
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDiscObserver:)
                                                 name:NSNotificationName(NOTIF_DEVICE_DISC)
                                               object:nil];
    
    [self initData];
    
    [self initUI];
}


- (void) initData {
    
    JUB_NS_ENUM_DEV_TYPE defaultDeviceType = JUB_NS_ENUM_DEV_TYPE::SEG_BLE;
    
    NSString *indexStr = [[NSUserDefaults standardUserDefaults] objectForKey:selectedTransmitTypeIndexStr];
    if (!indexStr) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)JUB_NS_ENUM_DEV_TYPE::SEG_BLE]
                                                  forKey:selectedTransmitTypeIndexStr];
    }
    else {
        defaultDeviceType = (JUB_NS_ENUM_DEV_TYPE)[indexStr integerValue];
    }
    
    self.scanDeviceDict = [[NSMutableDictionary alloc] init];
    self.connDeviceDict = [[NSMutableDictionary alloc] init];
    
    [[JUBSharedData sharedInstance] setDeviceType:defaultDeviceType];
}


#pragma mark - 初始化UI
- (void) initUI {
    
    [super initUI];
    
    if (JUB_NS_ENUM_DEV_TYPE::SEG_BLE == [[JUBSharedData sharedInstance] deviceType]) {
        self.showBLEButton = YES;
    }
}


- (void) updateBLEDeviceList {
    
    [self.BLEDeviceScanListView cleanBLEDeviceArray];
    
    for (id device in self.scanDeviceDict) {
        JUBScanDeviceInfo* deviceInfo = [self->scanDeviceDict objectForKey:device];
        [self.BLEDeviceScanListView addBLEDeviceArray:[deviceInfo getName]];
    }
}


#pragma mark - 页面内部按钮回调方法
- (void) segmentAction:(UISegmentedControl *)seg {
    
    NSInteger index = [seg selectedSegmentIndex];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)index]
                                              forKey:selectedTransmitTypeIndexStr];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self selectTransmitTypeIndex:index];
    
    NSLog(@"segmentAction index = %ld", (long)index);
    
    [[JUBSharedData sharedInstance] setDeviceType:(JUB_NS_ENUM_DEV_TYPE)index];
}


- (JUBScanDeviceInfo*) searchScanDeviceInfo:deviceName {
    
    for (id device in self.scanDeviceDict) {
        JUBScanDeviceInfo* deviceInfo = [self->scanDeviceDict objectForKey:device];
        if ([deviceInfo getName] == deviceName) {
            return deviceInfo;
        }
    }
    
    return nil;
}


- (NSNumber*) searchConnDeviceInfo:deviceName {
    
    for (id deviceID in self.connDeviceDict) {
        JUBScanDeviceInfo* deviceInfo = [self->connDeviceDict objectForKey:deviceID];
        if ([deviceInfo getName] == deviceName) {
            return deviceID;
        }
    }
    
    return nil;
}


- (void) selectTransmitTypeIndex:(NSInteger)index {
    
    switch (index) {
    case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
    {
        self.showBLEButton = YES;
        break;
    }
    default:
        break;
    }   // switch (index) end
}


#pragma mark - 蓝牙通讯库寻卡回调
- (void) deviceArrivalObserver:notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //通讯库调用
        DeviceInitParam* param = [[DeviceInitParam alloc] init];
        param.readCallBack = &BLEReadFuncCallBack;
        param.scanCallBack = &BLEScanFuncCallBack;
        param.discCallBack = &BLEDiscFuncCallBack;
        [g_sdk JUB_initDevice:param];
        NSUInteger rv = [g_sdk JUB_LastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_initDevice() return 0x%lx.]", rv]];
            return;
        }
        
        [self addMsgData:[NSString stringWithFormat:@"[JUB_initDevice() OK.]"]];
    });
}


- (void) deviceScanObserver:(NSNotification *) notification {
    
    if (nil == [scanDeviceDict objectForKey:[[notification userInfo] objectForKey:SCAN_DEVICE_INFO_UUID]]) {
        
        [scanDeviceDict setObject:[[notification userInfo] objectForKey:SCAN_DEVICE_INFO_DEVICE]
                           forKey:[[notification userInfo] objectForKey:SCAN_DEVICE_INFO_UUID]];
    }
    
    [self updateBLEDeviceList];
}


- (void) deviceDiscObserver:(NSNotification *) notification {
    
//    if (nil == [deviceDict objectForKey:[[notification userInfo] objectForKey:SCAN_DEVICE_INFO_UUID]]) {
//
//        [deviceDict setObject:[[notification userInfo] objectForKey:SCAN_DEVICE_INFO_DEVICE]
//                       forKey:[[notification userInfo] objectForKey:SCAN_DEVICE_INFO_UUID]];
//    }
//
    [self updateBLEDeviceList];
}


#pragma mark - 懒加载
- (NSInteger) selectedTransmitTypeIndex {
    
    NSString *indexStr = [[NSUserDefaults standardUserDefaults] objectForKey:selectedTransmitTypeIndexStr];
    
    return [indexStr integerValue];
}


- (NSArray *) getTransmitTypeArray {
    
    return @[
        BUTTON_TITLE_BLE
    ];
}


//设置首页列表内容
- (NSArray<JUBButtonModel *> *) buttonArray {
    
    NSArray *buttonTitleArray = @[
        BUTTON_TITLE_FGPT,
        BUTTON_TITLE_DEVICE,
        BUTTON_TITLE_BTC,
        BUTTON_TITLE_ETH,
        BUTTON_TITLE_EOS,
        BUTTON_TITLE_XRP,
    ];
    
    NSMutableArray *buttonModelArray = [NSMutableArray array];
    for (NSString *title in buttonTitleArray) {
        JUBButtonModel *model = [[JUBButtonModel alloc] init];
        model.title = title;
        model.isNeedMainThread = YES;
        [buttonModelArray addObject:model];
    }
    
    return buttonModelArray;
}


//首页按钮点击响应事件
- (void) gotoDetailAccordingCoinSeriesType:(NSInteger)optType {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    if (0 == [sharedData currDeviceID]) {
        NSString *connDevAlertString = @"Please connect the device first...";
        JUBAlertView *alertView = [JUBAlertView showMsg:connDevAlertString];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),
                       ^ {
            [alertView dismiss];
            [self addMsgData:[NSString stringWithFormat:connDevAlertString]];
        });
        return;
    }
    
    JUBFingerManagerBaseController *fgpt = nil;
    JUBDetailBaseController *vc = nil;
    switch (optType) {
    case JUB_NS_ENUM_MAIN::OPT_FGPT:
    {
        fgpt = [[JUBFgptMgrController alloc] init];
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_DEVICE:
    {
        vc = [[JUBDeviceController alloc] init];
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_BTC:
    {
        vc = [[JUBBTCController alloc] init];
        break;
    }
    case JUB_NS_ENUM_MAIN::OPT_ETH:
    {
        vc = [[JUBETHController alloc] init];
        break;
    }
//    case JUB_NS_ENUM_MAIN::OPT_EOS:
//    {
//        vc = [[JUBEOSController alloc] init];
//        break;
//    }
//    case JUB_NS_ENUM_MAIN::OPT_XRP:
//    {
//        vc = [[JUBXRPController alloc] init];
//        break;
//    }
    default:
        return;
    }   // switch (optType) end
    
    if (vc) {
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
    else if (fgpt) {
        [self.navigationController pushViewController:fgpt
                                             animated:YES];
    }
}


- (void) scanBLEButtonClicked {
    
    NSLog(@"scanBLEButtonClicked");
    
    __block
    NSUInteger rv = JUBR_ERROR;
    
    [g_sdk JUB_enumDevices];
    rv = [g_sdk JUB_LastError];
    if (JUBR_OK != rv) {
        
        [self addMsgData:[NSString stringWithFormat:@"[JUB_enumDevices() return 0x%lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_enumDevices() OK.]"]];
    
    self.BLEDeviceScanListView = [JUBBLEDeviceScanListView showCallBack:^(NSString * _Nonnull deviceName) {
        
        NSLog(@"deviceName = %@", deviceName);
        JUBScanDeviceInfo *deviceInfo = [self searchScanDeviceInfo:deviceName];
        if (deviceInfo) {
//            JUBAlertView *alertView = [JUBAlertView showMsg:@"Connecting BLE device..."];
//            //蓝牙连接成功之后将alertView隐藏掉，延时可以去掉，需要隐藏的时候直接隐藏即可
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
//                                         (int64_t)(5 * NSEC_PER_SEC)),
//                           dispatch_get_main_queue(),
//                           ^ {
//                [alertView dismiss];
//            });
            
            JUBAlertView *alertView = [JUBAlertView showMsg:@"Connecting BLE device..."];
            {
                NSUInteger deviceID = 0;
                deviceID = [g_sdk JUB_connectDevice:deviceInfo.name
                                               uuid:deviceInfo.uuid
                                        connectType:(NSUInteger)deviceInfo.type
                                            timeout:30000];
                rv = [g_sdk JUB_LastError];
                if (JUBR_OK != rv) {
                    [self addMsgData:[NSString stringWithFormat:@"[JUB_connectDevice() return 0x%lx.]", rv]];
                }
                else {
                    [self addMsgData:[NSString stringWithFormat:@"[JUB_connectDevice() OK.]"]];
                    
                    [self.connDeviceDict setObject:deviceInfo
                                            forKey:[NSNumber numberWithUnsignedInteger:deviceID]];
                    
                    [[JUBSharedData sharedInstance] setCurrDeviceID:deviceID];
                }
                [alertView dismiss];
            }
        }
    }];
//
//    scanDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:10
//                                                      repeats:YES
//                                                        block:^(NSTimer * _Nonnull timer) {
//        rv = JUB_enumDevices();
//        if (JUBR_OK != rv) {
//
//            [self addMsgData:[NSString stringWithFormat:@"[JUB_enumDevices() ERROR.]"]];
//            return;
//        }
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_enumDevices() OK.]"]];
//    }];
}


//断开连接按钮回调
- (void) disConnectBLEButtonClicked {
    
    NSLog(@"disConnectBLEButtonClicked");
    
    __block
    NSNumber* disconnDeviceID = nil;
    
    JUBBLEDisconnectView *bleDisconnectView = [JUBBLEDisconnectView showCallBack:^(NSString * _Nonnull deviceName) {
        NSLog(@"deviceName = %@", deviceName);
        
        disconnDeviceID = [self searchConnDeviceInfo:deviceName];
        if (disconnDeviceID) {
//            JUBAlertView *alertView = [JUBAlertView showMsg:@"Disconnecting BLE device..."];
//
//            //蓝牙连接成功之后将alertView隐藏掉，延时可以去掉，需要隐藏的时候直接隐藏即可
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
//                                         (int64_t)(3 * NSEC_PER_SEC)),
//                           dispatch_get_main_queue(),
//                           ^ {
//                [alertView dismiss];
//            });
            
            JUBAlertView *alertView = [JUBAlertView showMsg:@"Disconnecting BLE device..."];
            {
                [g_sdk JUB_disconnectDevice:[disconnDeviceID unsignedIntegerValue]];
                NSUInteger rv = [g_sdk lastError];
                if (JUBR_OK != rv) {
                    [self addMsgData:[NSString stringWithFormat:@"[JUB_disconnectDevice() return 0x%lx.]", rv]];
                }
                else {
                    [self addMsgData:[NSString stringWithFormat:@"[JUB_disconnectDevice() OK.]"]];
                    [self.connDeviceDict removeObjectForKey:disconnDeviceID];
                }
                [alertView dismiss];
            }
        }
    }];
    
    NSMutableArray *deviceNames = [[NSMutableArray alloc] init];
    for (id deviceID in self.connDeviceDict) {
        JUBScanDeviceInfo* deviceInfo = [self.connDeviceDict objectForKey:deviceID];
        [deviceNames addObject:[deviceInfo getName]];
    }
    [bleDisconnectView addDeviceArray:deviceNames];
}


@end
