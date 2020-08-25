//
//  JUBDeviceController.h
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/6.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBDetailBaseController.h"


NS_ASSUME_NONNULL_BEGIN


#define BUTTON_TITLE_QUERYBATTERY       @"QUERY_BATTERY"
#define BUTTON_TITLE_DEVICEINFO         @"DEVICE_INFO"
#define BUTTON_TITLE_DEVICEAPPLETS      @"DEVICE_APPLETS"
#define BUTTON_TITLE_DEVICECERT         @"DEVICE_CERT"


typedef NS_ENUM(NSInteger, JUB_NS_ENUM_DEV_OPT) {
    QUERY_BATTERY,
    DEVICE_INFO,
    DEVICE_APPLETS,
    DEVICE_CERT,
};


@interface JUBDeviceController : JUBDetailBaseController
@end

NS_ASSUME_NONNULL_END
