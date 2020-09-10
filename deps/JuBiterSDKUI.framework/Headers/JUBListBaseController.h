//
//  JUBListBaseController.h
//  JuBiterSDKDemo
//
//  Created by 张川 on 2020/4/28.
//  Copyright © 2020 JuBiter. All rights reserved.
//  首页的基类，用户应该继承本类，去实现自己的业务逻辑

#import <UIKit/UIKit.h>
#import "FTConstant.h"
#import "JUBMainView.h"
#import "Tools.h"

NS_ASSUME_NONNULL_BEGIN

@interface JUBListBaseController : UIViewController

@property (nonatomic, strong) NSArray<JUBButtonModel *> *buttonArray;

@property (nonatomic, assign) NSInteger selectedTransmitTypeIndex;

@property (nonatomic, assign) BOOL showBLEButton;

@property (nonatomic, copy) NSString *leftNAVButtonTitle;

@property (nonatomic, copy) NSString *rightNAVButtonTitle;

- (void)addMsgData:(NSString *)msgData;

@end

NS_ASSUME_NONNULL_END
