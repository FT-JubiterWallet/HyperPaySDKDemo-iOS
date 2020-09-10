//
//  JUBListAlert.h
//  JuBiterSDKDemo
//
//  Created by zhangchuan on 2020/8/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JUBSelectCellCallBackBlock)(NSString * _Nullable selectedItem);

typedef void (^JUBDeleteCellCallBackBlock)(NSString * _Nullable deletedItem);

@interface JUBListAlert : UIView

+ (JUBListAlert *)showCallBack:(JUBSelectCellCallBackBlock)selectCellCallBackBlock;

@property (nonatomic, copy) NSString *title;

//NSTextAlignmentLeft  NSTextAlignmentCenter  NSTextAlignmentRight
@property (nonatomic, assign) NSTextAlignment textAlignment;

//单个添加内容
- (void)addItem:(NSString *)item;

//批量添加内容
- (void)addItems:(NSArray<NSString *> *)items;

//单个移除内容
- (void)removeItem:(NSString *)item;

//批量移除内容
- (void)removeAllItems;

@property (nonatomic, copy) JUBDeleteCellCallBackBlock deleteCellCallBackBlock;

@end

NS_ASSUME_NONNULL_END
