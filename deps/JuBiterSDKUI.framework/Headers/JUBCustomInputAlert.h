//
//  JUBCustomInputAlert.h
//  JuBiterSDKDemo
//
//  Created by 张川 on 2020/5/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JUBDissAlertCallBack)(void);

typedef void (^JUBSetErrorCallBack)(NSString *errorMessage);

typedef void (^JUBInputCallBackBlock)(NSString * _Nullable content, JUBDissAlertCallBack dissAlertCallBack, JUBSetErrorCallBack setErrorCallBack);

@interface JUBCustomInputAlert : UIView

+ (JUBCustomInputAlert *)showCallBack:(JUBInputCallBackBlock)inputCallBackBlock;

//纯数字键盘 UIKeyboardTypeNumberPad
//数字带小数点键盘 UIKeyboardTypeDecimalPad
+ (JUBCustomInputAlert *)showCallBack:(JUBInputCallBackBlock)inputCallBackBlock keyboardType:(UIKeyboardType)keyboardType;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *textFieldPlaceholder;

@property (nonatomic, copy) NSString *leftButtonTitle;

@property (nonatomic, copy) NSString *rightButtonTitle;

@property (nonatomic, assign) NSInteger limitLength;

@end

NS_ASSUME_NONNULL_END
