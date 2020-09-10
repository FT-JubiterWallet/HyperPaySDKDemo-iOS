//
//  JUBListCell.h
//  JuBiterSDKDemo
//
//  Created by 张川 on 2020/5/14.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JUBListCell : UITableViewCell

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@end

NS_ASSUME_NONNULL_END
