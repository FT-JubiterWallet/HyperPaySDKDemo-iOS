//
//  JUBCoinTestDetailBaseController.h
//  JuBiterSDKDemo
//
//  Created by 张川 on 2020/4/28.
//  Copyright © 2020 Jubiter. All rights reserved.
//  此类为测试详情页面的基础类，不可在里面实现业务逻辑，用户应该继承自该类之后在自己的类里面实现具体的业务逻辑

#import <UIKit/UIKit.h>
#import "JUBCoinTestMainView.h"
#import "Tools.h"

NS_ASSUME_NONNULL_BEGIN

@interface JUBCoinTestDetailBaseController : UIViewController

@property (nonatomic, strong) NSArray<JUBButtonModel *> *buttonArray;

@property (nonatomic, strong) NSArray *coinTypeArray;

@property (nonatomic, assign) NSInteger selectedTransmitTypeIndex;

@property (nonatomic, assign) NSInteger selectCoinTypeIndex;

- (void)addMsgData:(NSString *)msgData;

@end

NS_ASSUME_NONNULL_END
