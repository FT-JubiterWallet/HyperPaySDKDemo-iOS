//
//  JUBCoinDetailController.h
//  nfcTagTest
//
//  Created by 张川 on 2020/4/28.
//  Copyright © 2020 JuBiter. All rights reserved.
//  此类为测试详情页面的基础类，不可在里面实现业务逻辑，用户应该继承自该类之后在自己的类里面实现具体的业务逻辑

#import <UIKit/UIKit.h>
#import "JUBMainView.h"
#import "Tools.h"

NS_ASSUME_NONNULL_BEGIN

@interface JUBFingerManagerBaseController : UIViewController

@property (nonatomic, strong, nullable) NSArray<NSString *> *fingerArray;

@property (nonatomic, assign) NSInteger selectedFingerIndex;

//此值为非空值时导航栏右边的按钮将会显示该值，并且点击可以切换单位
@property (nonatomic, copy) NSString *navRightButtonTitle;

//设置timeout的时间
@property (nonatomic, assign) NSInteger timeOut;

- (void)addMsgData:(NSString *)msgData;

@end

NS_ASSUME_NONNULL_END
