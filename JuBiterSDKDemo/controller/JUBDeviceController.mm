//
//  JUBDeviceController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/6.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBErrorCode.h"
#import "JUBSharedData.h"

#import "JUBHomePageController.h"
#import "JUBDeviceController.h"

#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+DEV_BLE.h"


@interface JUBDeviceController ()

@end


@implementation JUBDeviceController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Device options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_DEVICE;
    
    NSArray *buttonTitleArray = @[
        BUTTON_TITLE_QUERYBATTERY,
        BUTTON_TITLE_DEVICEINFO,
        BUTTON_TITLE_DEVICEAPPLETS,
        BUTTON_TITLE_DEVICECERT,
    ];
    
    NSMutableArray *buttonModelArray = [NSMutableArray array];
    
    for (NSString *title in buttonTitleArray) {
        
        JUBButtonModel *model = [[JUBButtonModel alloc] init];
        
        model.title = title;
        
        //默认支持全部通信类型，不传就是默认，如果传多个通信类型可以直接按照首页顶部的通信类型index传，比如说如果支持NFC和BLE，则直接传@"01"即可，同理如果只支持第一和第三种通信方式，则传@"02"
        model.transmitTypeOfButton = [NSString stringWithFormat:@"%li",
                                      (long)JUB_NS_ENUM_DEV_TYPE::SEG_BLE];
        
        [buttonModelArray addObject:model];
    }
    
    self.buttonArray = buttonModelArray;
}


//测试类型的按钮点击回调
- (void) selectedTestActionTypeIndex:(NSInteger)index {
    
    NSLog(@"JUBDeviceController--selectedTransmitTypeIndex = %ld, Type = %ld, selectedTestActionTypeIndex = %ld", (long)self.selectedTransmitTypeIndex, (long)self.selectedMenuIndex, (long)index);
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    self.optIndex = index;
    
    switch (self.optIndex) {
    case JUB_NS_ENUM_DEV_OPT::QUERY_BATTERY:
    {
        switch (self.selectedTransmitTypeIndex) {
        case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
        {
            [self beginBLESession];
            break;
        }
        default:
            break;
        }   // switch (self.selectedTransmitTypeIndex) end
        break;
    }
    case JUB_NS_ENUM_DEV_OPT::DEVICE_INFO:
    case JUB_NS_ENUM_DEV_OPT::DEVICE_APPLETS:
    case JUB_NS_ENUM_DEV_OPT::DEVICE_CERT:
    {
        switch (self.selectedTransmitTypeIndex) {
        case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
        {
            [self beginBLESession];
            break;
        }
        default:
            break;
        }   // switch (self.selectedTransmitTypeIndex) end
        break;
    }
    default:
        break;
    }   // switch (self.optIndex) end
}


#pragma mark - 通讯库寻卡回调
- (void) DeviceOpt:(NSUInteger)deviceID {
    
    switch (self.optIndex) {
    case JUB_NS_ENUM_DEV_OPT::QUERY_BATTERY:
    {
        [self query_device_battery:deviceID];
        break;
    }
    case JUB_NS_ENUM_DEV_OPT::DEVICE_INFO:
    {
        [self get_device_info_test:deviceID];
        break;
    }
    case JUB_NS_ENUM_DEV_OPT::DEVICE_APPLETS:
    {
        [self get_device_applet_test:deviceID];
        break;
    }
    case JUB_NS_ENUM_DEV_OPT::DEVICE_CERT:
    {
        [self get_device_cert_test:deviceID];
        break;
    }
    default:
        break;
    }   // switch (self.optIndex) end
}


#pragma mark - 业务
- (void) query_device_battery:(NSUInteger)deviceID {
    
    NSString *percent = [g_sdk JUB_QueryBattery:deviceID];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_QueryBattery() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_QueryBattery() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Device Battery: %@.", percent]];
}


- (void) get_device_info_test:(NSUInteger)deviceID {
    
    DeviceInfo *info = [g_sdk JUB_GetDeviceInfo:deviceID];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetDeviceInfo() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetDeviceInfo() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"DeviceInfo.label: %@.", info.label]];
    [self addMsgData:[NSString stringWithFormat:@"DeviceInfo.sn:    %@.", info.sn]];
    [self addMsgData:[NSString stringWithFormat:@"DeviceInfo.pinRetry:    %li.", info.pinRetry]];
    [self addMsgData:[NSString stringWithFormat:@"DeviceInfo.pinMaxRetry: %li.", info.pinMaxRetry]];
    [self addMsgData:[NSString stringWithFormat:@"DeviceInfo.bleVersion:      %@.", info.bleVersion]];
    [self addMsgData:[NSString stringWithFormat:@"DeviceInfo.firmwareVersion: %@.", info.firmwareVersion]];
}


- (void) get_device_applet_test:(NSUInteger)deviceID {
    
    NSString* appList = [g_sdk JUB_EnumApplets:deviceID];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumApplets() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumApplets() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Applets are %@.", appList]];
    
    for (auto appID : appList) {
        if (NSComparisonResult::NSOrderedSame == [appID compare:[NSString stringWithCString:""
                                                                                   encoding:[NSString defaultCStringEncoding]]]) {
            continue;
        }
        auto version = [g_sdk JUB_GetAppletVersion:deviceID
                                             appID:appID];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAppletVersion return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAppletVersion() OK.]"]];
        
        [self addMsgData:[NSString stringWithFormat:@"Applet Version: %@.", version]];
    }
    
    NSString* coinList = [g_sdk Jub_EnumSupportCoins:deviceID];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[Jub_EnumSupportCoins() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[Jub_EnumSupportCoins() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Support coins are %@.", coinList]];
}


- (void) get_device_cert_test:(NSUInteger)deviceID {
    
    NSString* cert = [g_sdk JUB_GetDeviceCert:deviceID];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetDeviceCert() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetDeviceCert() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Device Cert is %@.", cert]];
}


@end
