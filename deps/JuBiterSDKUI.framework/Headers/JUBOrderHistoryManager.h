//
//  JUBOrderHistoryManager.h
//  JuBiterSDKUI
//
//  Created by zhangchuan on 2020/9/2.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JUBOrderHistoryManager : NSObject

/// 获取历史管理器单例
+ (instancetype)defaultManager;

/// 获取历史记录
- (NSMutableArray<NSString *> *)findHistory;

/// 保存历史记录
/// @param historys 历史记录
- (void)saveHistory:(NSArray<NSString *> *)historys;

@end

NS_ASSUME_NONNULL_END
