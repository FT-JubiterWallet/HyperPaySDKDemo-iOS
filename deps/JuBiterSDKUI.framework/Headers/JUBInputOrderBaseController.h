//
//  FTInputOrderBaseController.h
//  F4000BleTest
//
//  Created by zhangchuan on 2020/8/31.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JuBiterSDKUI/JuBiterSDKUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface JUBInputOrderBaseController : UIViewController

@property (nonatomic, strong) NSArray<JUBButtonModel *> *buttonArray;

@property (nonatomic, assign) NSInteger selectedTransmitTypeIndex;

@property (nonatomic, copy) NSString *apduContent;

- (void)addMsgData:(NSString *)msgData;

@end

NS_ASSUME_NONNULL_END
