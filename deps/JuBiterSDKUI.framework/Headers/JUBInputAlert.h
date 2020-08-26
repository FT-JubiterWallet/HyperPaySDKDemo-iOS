//
//  JUBInputAlert.h
//  JuBiterSDKDemo
//
//  Created by zhangchuan on 2020/6/30.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JUBInputCallBack)( NSString * _Nullable pin);


@interface JUBInputAlert : NSObject

/// 弹出输入框弹框
/// @param inputPinCallBack 点击确认回调的block
+ (JUBInputAlert *)showInputPinAlert:(JUBInputCallBack)inputPinCallBack;

@end

NS_ASSUME_NONNULL_END
