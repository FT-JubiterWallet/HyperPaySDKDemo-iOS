//
//  JUBMainView.h
//  JuBiterSDKDemo
//
//  Created by 张川 on 2020/4/8.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JUBButtonModel.h"
#import "FTResultDataModel.h"

typedef void (^JUBMainViewCallBackBlock)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface JUBMainView : UIView

@property (nonatomic, strong) NSArray<JUBButtonModel *> *buttonArray;;

+ (JUBMainView *)coinTestMainViewWithFrame:(CGRect)frame buttonArray:(nullable NSArray<JUBButtonModel *> *)btnArray;

- (void)addMsgData:(NSString *)msgData;

@property (nonatomic, strong) JUBMainViewCallBackBlock transmissionViewCallBackBlock;

@end

NS_ASSUME_NONNULL_END
