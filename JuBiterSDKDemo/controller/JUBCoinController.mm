//
//  JUBCoinController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/9.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBCoinController.h"

#import "JubSDKCore/JubSDKCore+DEV.h"


@interface JUBCoinController ()

@end


@implementation JUBCoinController
@synthesize inputAddrView;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *buttonTitleArray = @[
        BUTTON_TITLE_TRANSACTION,
        BUTTON_TITLE_GETADDRESS,
        BUTTON_TITLE_SHOWADDRESS,
        BUTTON_TITLE_SETMYADDRESS,
        BUTTON_TITLE_SETTIMEOUT,
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
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    [sharedData setCurrMainPath:nil];
    [sharedData setCurrCoinType:-1];
    [sharedData setCurrContextID:0];
}


- (void) dealloc {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSUInteger contextID = [sharedData currContextID];
    if (!contextID) {
        [g_sdk JUB_ClearContext:contextID];
    }
    
    [sharedData setCurrMainPath:nil];
    [sharedData setCurrCoinType:-1];
    [sharedData setCurrContextID:0];
}


//选中币种之后的回调，你这可能用不到这个回调，先开放给你，用不到就可以直接删掉
- (void) selectCoinType {
    
    NSLog(@"JUBBTCController--selectCoinTypeIndex %ld", (long)self.selectCoinTypeIndex);
    
    self.optCoinType = (long)self.selectCoinTypeIndex;
}


//测试类型的按钮点击回调
- (void) selectedTestActionTypeIndex:(NSInteger)index {
    
    NSLog(@"JUBCoinController--selectedTransmitTypeIndex = %ld, CoinType = %ld, selectedTestActionType = %ld", (long)self.selectedTransmitTypeIndex, (long)self.selectCoinTypeIndex, (long)index);
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    self.optIndex = index;
    
    switch (self.optIndex) {
    case JUB_NS_ENUM_OPT::TRANSACTION:
    {
        switch (self.selectedTransmitTypeIndex) {
        case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
        {
            DeviceTypeInfo* info = [g_sdk JUB_GetDeviceType:[sharedData currDeviceID]];
            NSUInteger rv = [g_sdk lastError];
            if (JUBR_OK != rv) {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_GetDeviceType() return 0x%2lx.]", rv]];
                return;
            }
            [self addMsgData:[NSString stringWithFormat:@"[JUB_GetDeviceType() OK.]"]];
            switch (info.category) {
            case JUB_NS_ENUM_DEVICE::NS_BIO:
                [sharedData setVerifyMode:JUB_NS_ENUM_VERIFY_MODE::FGPT];
                break;
            case JUB_NS_ENUM_DEVICE::NS_BLADE:
            default:
                [sharedData setVerifyMode:JUB_NS_ENUM_VERIFY_MODE::VKPIN];
                break;
            }
            [self beginBLESession];
            break;
        }
        default:
            break;
        }   // switch (self.selectedTransmitTypeIndex) end
        break;
    }
    case JUB_NS_ENUM_OPT::GET_ADDRESS:
    case JUB_NS_ENUM_OPT::SHOW_ADDRESS:
    case JUB_NS_ENUM_OPT::SET_MY_ADDRESS:
    {
        inputAddrView = [JUBInputAddressView showCallBack:^(NSInteger change, NSInteger address) {
            
            NSLog(@"showCallBack change = %ld, address = %ld", (long)change, (long)address);
            
            self.change = change;
            self.addressIndex = address;
            
            switch (self.selectedTransmitTypeIndex) {
            case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
            {
                [self beginBLESession];
                break;
            }
            default:
                break;
            }   // switch (self.selectedTransmitTypeIndex) end
        }];
        inputAddrView.addressHeader = @"m/purpose'/coin_type'/account'";
        break;
    }
    case JUB_NS_ENUM_OPT::SET_TIMEOUT:
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


#pragma mark - 业务
- (void) CoinOpt:(NSUInteger)contextID
            root:(Json::Value)root
          choice:(int)choice {
    
    switch (choice) {
    case JUB_NS_ENUM_OPT::GET_ADDRESS:
    {
        [self get_address_pubkey:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::SHOW_ADDRESS:
    {
        [self show_address_test:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::SET_TIMEOUT:
    {
        [self set_time_out:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::SET_MY_ADDRESS:
    {
        [self set_my_address_test:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::TRANSACTION:
    {
        [self transaction_test:contextID
                          root:root];
        break;
    }
    default:
        break;
    }   // switch (choice) end
}


- (void) get_address_pubkey:(NSUInteger)contextID {
    
}


- (void) show_address_test:(NSUInteger)contextID {
    
}


- (void) set_my_address_test:(NSUInteger)contextID {
    
    __block
    NSUInteger rv = [self show_virtualKeyboard:contextID];
    if (JUBR_OK != rv) {
        return;
    }
    
    [JUBPinAlertView showInputPinAlert:^(NSString * _Nonnull pin) {
        if (nil == pin) {
            [self cancel_virtualKeyboard:contextID];
            rv = JUBR_USER_CANCEL;
            return;
        }
        [[JUBSharedData sharedInstance] setUserPin:pin];
        
        rv = [self verify_pin:contextID];
        if (JUBR_OK != rv) {
            return;
        }
        
        rv = [self set_my_address_proc:contextID];
        if (JUBR_OK != rv) {
            return;
        }
    }];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    return JUBR_IMPL_NOT_SUPPORT;
}


- (NSUInteger)set_unit_test:(NSUInteger)contextID {
    
    return JUBR_OK;
}


- (NSUInteger) set_time_out:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    NSUInteger timeout = 600;
    [g_sdk JUB_SetTimeOut:contextID
                  timeout:timeout];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetTimeOut() return 0x%2lx.]", rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetTimeOut() OK.]"]];
    
    return rv;
}


- (void) transaction_test:(NSUInteger)contextID
                     root:(Json::Value)root {
    
    __block
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    switch ([sharedData deviceType]) {
    case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
    {
        __block
        BOOL isDone = NO;
        switch ([sharedData verifyMode]) {
        case JUB_NS_ENUM_VERIFY_MODE::FGPT:
        {
            JUBListAlert *listAlert = [JUBListAlert showCallBack:^(NSString *_Nonnull selectedItem) {
                NSLog(@"Verify PIN mode selected: %@", selectedItem);
                if ([selectedItem isEqual:BUTTON_TITLE_USE_VK]) {
                    rv = [self show_virtualKeyboard:contextID];
                    if (JUBR_OK != rv) {
                        isDone = YES;
                        return;
                    }
                    
                    [JUBPinAlertView showInputPinAlert:^(NSString * _Nonnull pin) {
                        if (nil == pin) {
                            [self cancel_virtualKeyboard:contextID];
                            isDone = YES;
                            rv = JUBR_USER_CANCEL;
                            return;
                        }
                        [sharedData setUserPin:pin];
                        
                        rv = [self verify_pin:contextID];
                        if (JUBR_OK != rv) {
                            isDone = YES;
                            return;
                        }
                        
                        if (-1 != [sharedData currCoinType]) {
                            rv = [self set_unit_test:contextID];
                            if (JUBR_OK != rv) {
                                isDone = YES;
                                return;
                            }
                        }
                        
                        isDone = YES;
                    }];
                }   // if ([selectedItem isEqual:BUTTON_TITLE_USE_VK]) end
                else if ([selectedItem isEqual:BUTTON_TITLE_USE_FGPT]) {
                    rv = [self verify_fgpt:contextID];
                    if (JUBR_OK != rv) {
                        isDone = YES;
                        return;
                    }
                    
                    if (-1 != [sharedData currCoinType]) {
                        rv = [self set_unit_test:contextID];
                        if (JUBR_OK != rv) {
                            isDone = YES;
                            return;
                        }
                    }
                    
                    isDone = YES;
                }   // if ([selectedItem isEqual:BUTTON_TITLE_USE_FGPT]) end
            }];
            
            listAlert.title = @"Please select Verify PIN mode:";
            [listAlert addItems:@[
                BUTTON_TITLE_USE_VK,
                BUTTON_TITLE_USE_FGPT
            ]];
            break;
        }   // case JUB_NS_ENUM_VERIFY_MODE::FGPT end
        case JUB_NS_ENUM_VERIFY_MODE::VKPIN:
        {
            rv = [self show_virtualKeyboard:contextID];
            if (JUBR_OK != rv) {
                isDone = YES;
                break;
            }
            
            [JUBPinAlertView showInputPinAlert:^(NSString * _Nonnull pin) {
                if (nil == pin) {
                    [self cancel_virtualKeyboard:contextID];
                    isDone = YES;
                    rv = JUBR_USER_CANCEL;
                    return;
                }
                [sharedData setUserPin:pin];
                
                rv = [self verify_pin:contextID];
                if (JUBR_OK != rv) {
                    isDone = YES;
                    return;
                }
                
                if (-1 != [sharedData currCoinType]) {
                    rv = [self set_unit_test:contextID];
                    if (JUBR_OK != rv) {
                        isDone = YES;
                        return;
                    }
                }
                
                isDone = YES;
            }];
            break;
        }   // case JUB_NS_ENUM_VERIFY_MODE::VKPIN end
        case JUB_NS_ENUM_VERIFY_MODE::PIN:
        default:
            rv = JUBR_ARGUMENTS_BAD;
            isDone = YES;
            break;
        }   // switch (data.verifyMode) end
        
        while (!isDone) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
        }
        
        if (JUBR_OK != rv) {
            return;
        }
        
        JUBAlertView *alertView = [JUBAlertView showMsg:@"Transaction in progress..."];
        {
            rv = [self tx_proc:contextID
                          root:root];
            
            [alertView dismiss];
        }
        break;
    }   // case JUB_NS_ENUM_DEV_TYPE::SEG_BLE end
    default:
        break;
    }   // switch ([sharedData deviceType]) end
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                  root:(Json::Value)root {
    
    return JUBR_IMPL_NOT_SUPPORT;
}


- (NSUInteger) show_virtualKeyboard:(NSUInteger)contextID {
    
    [g_sdk JUB_ShowVirtualPwd:contextID];
    NSUInteger rv = [g_sdk lastError];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_ShowVirtualPwd() return 0x%2lx.]", rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_ShowVirtualPwd() OK.]"]];
    
    return rv;
}


- (NSUInteger) cancel_virtualKeyboard:(NSUInteger)contextID {
    
    [g_sdk JUB_CancelVirtualPwd:contextID];
    NSUInteger rv = [g_sdk lastError];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CancelVirtualPwd() return 0x%2lx.]", rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_CancelVirtualPwd() OK.]"]];
    
    return rv;
}


- (NSUInteger) verify_pin:(NSUInteger)contextID {
    
    NSUInteger retry = [g_sdk JUB_VerifyPIN:contextID
                                     pinMix:[[JUBSharedData sharedInstance] userPin]];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_VerifyPIN(%lu) return 0x%2lx.]", retry, rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_VerifyPIN() OK.]"]];
    
    return rv;
}


- (NSUInteger) verify_fgpt:(NSUInteger)contextID {
    
    NSUInteger retry = [g_sdk JUB_VerifyFingerprint:contextID];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_VerifyFingerprint(%lu) return 0x%2lx.]", retry, rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_VerifyFingerprint() OK.]"]];
    
    return rv;
}


@end
