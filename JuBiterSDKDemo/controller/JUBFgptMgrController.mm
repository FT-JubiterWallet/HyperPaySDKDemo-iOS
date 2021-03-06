//
//  JUBFgptMgrController.m
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/13.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBErrorCode.h"
#import "JUBSharedData.h"

#import "JUBFgptMgrController.h"


@interface JUBFgptMgrController ()

@end

@implementation JUBFgptMgrController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Fingerprint Management";
    
    self.navRightButtonTitle = @"Verify";
    
    self.timeOut = 20;
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSUInteger deviceID = [[JUBSharedData sharedInstance] currDeviceID];
        JUB_NS_ENUM_BOOL b = [g_sdk JUB_IsBootLoader:deviceID];
        NSUInteger rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_IsBootLoader() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_IsBootLoader() return OK.]"]];
        
        if (b) {
            [self addMsgData:[NSString stringWithFormat:@"[Is in main SE.]"]];
        }
        else {
            [self addMsgData:[NSString stringWithFormat:@"[Isn't in main SE.]"]];
        }
        
        //这个fingerArray可以任意时候向他赋值,界面会自动更新
        if (JUBR_OK != [self enum_fgpt_test:deviceID]) {
            [self setFingerArray:nil];
        }
    });
}


- (void) dealloc {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSUInteger deviceID = [sharedData currDeviceID];
    if (!deviceID) {
        JUB_NS_ENUM_BOOL b = [g_sdk JUB_IsBootLoader:deviceID];
        NSUInteger rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_IsBootLoader() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_IsBootLoader() return OK.]"]];
        
        if (b) {
            [self addMsgData:[NSString stringWithFormat:@"[Is in main SE.]"]];
        }
        else {
            [self addMsgData:[NSString stringWithFormat:@"[Isn't in main SE.]"]];
        }
    }
}


#pragma mark - 业务
//- (NSUInteger)identity_verify:(NSUInteger)deviceID
//                         mode:(JUB_NS_ENUM_IDENTITY_VERIFY_MODE)mode {
//
//    NSUInteger retry = [g_sdk JUB_IdentityVerify:deviceID
//                                            mode:mode];
//    NSUInteger rv = [g_sdk lastError];
//    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
//        ) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityVerify(%lu) return 0x%2lx.]", retry, rv]];
//        return rv;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityVerify() OK.]"]];
//
//    return rv;
//}
//
//
- (NSUInteger) identity_verifyPIN:(NSUInteger)deviceID
                             mode:(JUB_NS_ENUM_IDENTITY_VERIFY_MODE)mode
                              pin:(NSString*)pin {
    
    NSUInteger retry = [g_sdk JUB_IdentityVerifyPIN:deviceID
                                               mode:mode
                                             pinMix:pin];
    NSUInteger rv = [g_sdk lastError];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityVerifyPIN(%lu) return %@ (0x%2lx).]", retry, [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityVerifyPIN() OK.]"]];
    
    return rv;
}


- (NSUInteger) identity_showNineGrids:(NSUInteger)deviceID {
    
    [g_sdk JUB_IdentityShowNineGrids:deviceID];
    NSUInteger rv = [g_sdk lastError];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityShowNineGrids() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityShowNineGrids() OK.]"]];
    
    return rv;
}


- (NSUInteger) identity_cancelNineGrids:(NSUInteger)deviceID {
    
    [g_sdk JUB_IdentityCancelNineGrids:deviceID];
    NSUInteger rv = [g_sdk lastError];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityCancelNineGrids() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_IdentityCancelNineGrids() OK.]"]];
    
    return rv;
}


- (NSUInteger) identity_verify_test:(NSUInteger)deviceID {
    
    __block
    NSUInteger rv = JUBR_ERROR;
    
    __block
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
    __block
    BOOL isDone = NO;
    
//    JUBListAlert *listAlert = [JUBListAlert showCallBack:^(NSString *_Nonnull selectedItem) {
//        if (!selectedItem) {
//            NSLog(@"JUBFgptMgrController::JUBListAlert canceled");
//            rv = JUBR_USER_CANCEL;
//            isDone = YES;
//            return;
//        }
//
//        if ([selectedItem isEqual:BUTTON_TITLE_VIA_FGPT]
//            ) {
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//                __block
//                JUBAlertView *alertView;
//                alertView = [JUBAlertView showMsg:@"Identity verification via fgpt in progress..."];
//                {
//                    rv = [self identity_verify:deviceID
//                                          mode:JUB_NS_ENUM_IDENTITY_VERIFY_MODE::NS_VIA_FPGT];
//
//                        [alertView dismiss];
//                }
//                isDone = YES;
//            }); // dispatch_async(dispatch_get_global_queue(0, 0), ^ end
//        }
//        else if ([selectedItem isEqual:BUTTON_TITLE_VIA_9GRIDS]) {
            rv = [self identity_showNineGrids:deviceID];
            if (JUBR_OK != rv) {
                isDone = YES;
                return rv;
            }
            
            [JUBPinAlert showInputPinCallBack:^(NSString * _Nonnull pin) {
                if (!pin) {
                    [self identity_cancelNineGrids:deviceID];
                    rv = JUBR_USER_CANCEL;
                    isDone = YES;
                    return;
                }
                [sharedData setUserPin:pin];
                
                rv = [self identity_verifyPIN:deviceID
                                         mode:JUB_NS_ENUM_IDENTITY_VERIFY_MODE::NS_VIA_9GRIDS
                                          pin:pin];
                if (JUBR_OK != rv) {
                    isDone = YES;
                    return;
                }
                isDone = YES;
            }]; // [JUBPinAlert showInputPinCallBack:^(NSString * _Nonnull pin) end
//        }   // if ([selectedItem isEqual:BUTTON_TITLE_VIA_9GRIDS]) end
//    }]; // JUBListAlert *listAlert end
//
//    listAlert.title = @"Please select mode:";
//    [listAlert addItems:@[
//        BUTTON_TITLE_VIA_9GRIDS,
//        BUTTON_TITLE_VIA_FGPT
//    ]];
//    [listAlert setTextAlignment:NSTextAlignment::NSTextAlignmentLeft];

    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    return rv;
}


// Fingerprint timeout setting
- (void)timeOutEntry {
    
    JUBCustomInputAlert *customInputAlert = [JUBCustomInputAlert showCallBack:^(NSString * _Nonnull timeout,
                                                                                JUBDissAlertCallBack  _Nonnull dissAlertCallBack,
                                                                                JUBSetErrorCallBack  _Nonnull setErrorCallBack) {
        
        NSLog(@"content = %@", timeout);
        if (nil == timeout) {
            dissAlertCallBack();
        }
        else if (   [timeout integerValue] >=  8
                 && [timeout integerValue] <= 60
                 ) {
            //隐藏弹框
            dissAlertCallBack();
            
            self.timeOut = [timeout integerValue];
            
        }
        else {
            setErrorCallBack(@"The maximum fingerprint timeout is 60s.");
        }
    }
                                                                 keyboardType:UIKeyboardTypeDecimalPad];
    
    customInputAlert.message = @"Please input the timeout (8 ~ 60s):";
    
    customInputAlert.title = @"The fingerprint operation timeout setting";
}


- (NSUInteger) enum_fgpt_test:(NSUInteger)deviceID {
    
    NSUInteger rv = JUBR_ERROR;
    
    NSString *fgptList = [g_sdk JUB_EnumFingerprint:deviceID];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumFingerprint() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumFingerprint() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"FingerprintIDs are: %@.", fgptList]];
    
    [self setFingerArray:[fgptList componentsSeparatedByString:@" "]];
    
    return rv;
}


- (FgptEnrollResult) enroll_fgpt_test:(NSUInteger)deviceID
                            fgptIndex:(NSUInteger)fgptIndex
                                times:(NSUInteger)times
                               fgptID:(NSUInteger)fgptID {
    
    NSUInteger rv = JUBR_ERROR;
    
    NSUInteger fgptNextIndex = fgptIndex;
//    NSUInteger remainingTimes = times;
    NSUInteger assignedID = fgptID;
    FgptEnrollInfo info = [g_sdk JUB_EnrollFingerprint:deviceID
                                           fgptTimeout:self.timeOut
                                             fgptIndex:fgptNextIndex
                                                fgptID:assignedID];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnrollFingerprint() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return FgptEnrollResult{info, rv};
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnrollFingerprint() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"FgptNextIndex(%lu), times(%lu), FgptID(%lu).", info.nextIndex, info.times, info.modalityID]];
    
    return FgptEnrollResult{info, rv};
}


- (NSUInteger) erase_fgpt_test:(NSUInteger)deviceID {
    
    NSUInteger rv = JUBR_ERROR;
    
    [g_sdk JUB_EraseFingerprint:deviceID
                    fgptTimeout:self.timeOut];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EraseFingerprint() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EraseFingerprint() OK.]"]];
    
    return rv;
}


- (NSUInteger) delete_fgpt_test:(NSUInteger)deviceID
                         fgptID:(NSUInteger)fgptID {
    
    NSUInteger rv = JUBR_ERROR;
    
    [g_sdk JUB_DeleteFingerprint:deviceID
                     fgptTimeout:self.timeOut
                          fgptID:fgptID];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_DeleteFingerprint() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_DeleteFingerprint() OK.]"]];
    
    return rv;
}


#pragma mark - 回调子类方法
//导航栏右边按钮点击回调，重写该方法可以接管点击按钮的响应
- (void) navRightButtonCallBack {
    
    if (JUBR_OK != [self identity_verify_test:[[JUBSharedData sharedInstance] currDeviceID]]) {
        return;
    }
}


//指纹录入
- (void) fingerPrintEntry {
    
//    JUBFingerEntryAlert *fingerEntryAlert = [JUBFingerEntryAlert show];
//
//    [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
//
//        //在你使用的时候直接使用这部分内容就可以，定时器可以去掉了
//        if (fingerEntryAlert.fingerNumber == 5) {
//
//            [timer invalidate];
//
//            [fingerEntryAlert dismiss];
//
//            return;
//
//        }
//
//        //这个fingerNumber可以任意时候向他赋值,界面会自动更新
//        fingerEntryAlert.fingerNumber = fingerEntryAlert.fingerNumber + 1;
//        NSLog(@"fingerEntryAlert.fingerNumber = %ld.", fingerEntryAlert.fingerNumber);
//    }];
    
    NSUInteger deviceID = [[JUBSharedData sharedInstance] currDeviceID];
    
    JUBFingerEntryAlert *fingerEntryAlert = [JUBFingerEntryAlert show];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSUInteger fgptIndex = 0;
        NSUInteger times = 0;
        NSUInteger fgptID = 0;
        __block
        FgptEnrollResult result = [self enroll_fgpt_test:deviceID
                                               fgptIndex:fgptIndex
                                                   times:times
                                                  fgptID:fgptID];
        NSLog(@"....enrollInfo.nextIndex = %ld.", result.enrollInfo.nextIndex);
        if (JUBR_OK != result.rv) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [fingerEntryAlert dismiss];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [fingerEntryAlert setFingerNumberSum:result.enrollInfo.times];
            [fingerEntryAlert setFingerNumber:result.enrollInfo.nextIndex];
        });
        
        for (NSUInteger i=result.enrollInfo.nextIndex; i<result.enrollInfo.times; ++i) {
            
            //这个fingerNumber可以任意时候向他赋值,界面会自动更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [fingerEntryAlert setFingerNumberSum:result.enrollInfo.times];
                [fingerEntryAlert setFingerNumber:result.enrollInfo.nextIndex];
                NSLog(@"fingerEntryAlert.fingerNumber = %ld.", fingerEntryAlert.fingerNumber);
            });
            
            times = result.enrollInfo.times;
            fgptIndex = result.enrollInfo.nextIndex;
            fgptID    = result.enrollInfo.modalityID;
            result = [self enroll_fgpt_test:deviceID
                                  fgptIndex:fgptIndex
                                      times:times
                                     fgptID:fgptID];
            if (JUBR_OK != result.rv) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [fingerEntryAlert dismiss];
                });
                return;
            }
        }
        
        //这个fingerNumber可以任意时候向他赋值,界面会自动更新
        dispatch_async(dispatch_get_main_queue(), ^{
            [fingerEntryAlert setFingerNumberSum:result.enrollInfo.times];
            [fingerEntryAlert setFingerNumber:result.enrollInfo.nextIndex];
            NSLog(@"fingerEntryAlert.fingerNumber = %ld.", fingerEntryAlert.fingerNumber);
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [fingerEntryAlert dismiss];
        });
        
        [self enum_fgpt_test:deviceID];
    });
}


//清空指纹
- (void) clearFingerPrint {
    
    //向设备发送清空指纹的指令
    //
    if (JUBR_OK != [self erase_fgpt_test:[[JUBSharedData sharedInstance] currDeviceID]]) {
        return;
    }
    
    //这里应该先完成与设备的通信，设备清空成功，再刷新界面，如果通信失败，则不刷新界面
    self.fingerArray = nil;
}


//删除指纹
- (void) selectedFinger:(NSInteger)selectedFingerIndex {
    
    NSLog(@"selectedFingerIndex = %ld", (long)selectedFingerIndex);
    
    //向设备发送清空指纹的指令
    //
    if (JUBR_OK != [self delete_fgpt_test:[[JUBSharedData sharedInstance] currDeviceID]
                                   fgptID:(NSUInteger)selectedFingerIndex]) {
        return;
    }
    
    //这里应该先完成与设备的通信，设备清空成功，再刷新界面，如果通信失败，则不刷新界面
    NSMutableArray *fingerArray = [self.fingerArray mutableCopy];
    
    [fingerArray removeObjectAtIndex:selectedFingerIndex];
    
    self.fingerArray = fingerArray;
}

@end
