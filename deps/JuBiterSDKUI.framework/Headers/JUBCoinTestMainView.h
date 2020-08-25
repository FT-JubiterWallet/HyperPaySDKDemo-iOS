//
//  JUBCoinTestMainView.h
//  JuBiterSDKDemo
//
//  Created by 张川 on 2020/4/8.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JUBButtonModel.h"
#import "FTResultDataModel.h"

typedef void (^JUBCoinTestMainViewCallBackBlock)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface JUBCoinTestMainView : UIView

@property (nonatomic, strong) NSArray<JUBButtonModel *> *buttonArray;;

+ (JUBCoinTestMainView *)coinTestMainViewWithFrame:(CGRect)frame buttonArray:(nullable NSArray<JUBButtonModel *> *)btnArray;

- (void)addMsgData:(NSString *)msgData;

@property (nonatomic, strong) JUBCoinTestMainViewCallBackBlock transmissionViewCallBackBlock;

@end

NS_ASSUME_NONNULL_END
