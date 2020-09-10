//
//  JUBPinAlert.h
//  JuBiterSDKDemo
//
//  Created by zhangchuan on 2020/6/30.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JUBInputPinCallBack)(NSString * _Nullable pin);
typedef void (^JUBFingerprintsCallBack)(void);
typedef void (^JUBChangePinCallBack)(NSString *oldPin, NSString *newPin);


@interface JUBPinAlert : NSObject

/// 弹出输入pin码弹框
/// @param inputPinCallBack pin码回调block
+ (JUBPinAlert *)showInputPinCallBack:(JUBInputPinCallBack)inputPinCallBack;

/// 弹出输入pin码弹框  带有指纹验证选项
/// @param inputPinCallBack pin码回调block
+ (JUBPinAlert *)showInputPinCallBack:(JUBInputPinCallBack)inputPinCallBack
fingerprintsCallBack:(JUBFingerprintsCallBack)fingerprintsCallBack;

/// 弹出修改pin码弹框
/// @param changePinCallBack 新、旧pin码回调block
+ (JUBPinAlert *)showChangePinCallBack:(JUBChangePinCallBack)changePinCallBack;

////纯数字键盘 UIKeyboardTypeNumberPad
////数字带小数点键盘 UIKeyboardTypeDecimalPad
//@property (nonatomic, assign) UIKeyboardType keyboardType;

@end

NS_ASSUME_NONNULL_END
