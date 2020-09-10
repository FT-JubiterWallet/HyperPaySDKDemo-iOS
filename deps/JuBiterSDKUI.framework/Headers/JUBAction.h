//
//  JUBAction.h
//  JuBiterSDKUI
//
//  Created by zhangchuan on 2020/8/27.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JUBAction : NSObject

/// Creates a control object for the function execution process
+ (JUBAction *)action;

/// Wait for the object's action to execute
- (void)await;

/// Execute the action of the object
- (void)doAction;

@end

NS_ASSUME_NONNULL_END
