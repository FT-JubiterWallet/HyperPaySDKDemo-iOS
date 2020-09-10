//
//  JUBBTCAmount.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/9/4.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBBTCAmount.h"
#import <JubSDKCore/JubSDKCore+COIN_BTC.h>


@implementation JUBBTCAmount


+ (NSString*)title:(JUB_NS_BTC_UNIT_TYPE)coinUnit {
    
    return [JUBAmount title:[JUBBTCAmount enumUnitToString:coinUnit]];
}


+ (NSString*)enumUnitToString:(JUB_NS_BTC_UNIT_TYPE)unit {
    
    NSString* strUnit = TITLE_UNIT_mBTC;
    switch (unit) {
    case JUB_NS_BTC_UNIT_TYPE::NS_BTC:
        strUnit = TITLE_UNIT_BTC;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_cBTC:
        strUnit = TITLE_UNIT_cBTC;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_uBTC:
        strUnit = TITLE_UNIT_uBTC;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_Satoshi:
        strUnit = TITLE_UNIT_Satoshi;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_mBTC:
    default:
        break;
    }
    
    return strUnit;
}


+ (JUB_NS_BTC_UNIT_TYPE)stringToEnumUnit:(NSString*)unitString {
    
    JUB_NS_BTC_UNIT_TYPE unit = JUB_NS_BTC_UNIT_TYPE::NS_BTC_UNIT_TYPE_NS;
    
    if ([unitString isEqual:TITLE_UNIT_BTC]) {
        unit = JUB_NS_BTC_UNIT_TYPE::NS_BTC;
    }
    else if ([unitString isEqual:TITLE_UNIT_cBTC]) {
        unit = JUB_NS_BTC_UNIT_TYPE::NS_cBTC;
    }
    else if ([unitString isEqual:TITLE_UNIT_mBTC]) {
        unit = JUB_NS_BTC_UNIT_TYPE::NS_mBTC;
    }
    else if ([unitString isEqual:TITLE_UNIT_uBTC]) {
        unit = JUB_NS_BTC_UNIT_TYPE::NS_uBTC;
    }
    else if ([unitString isEqual:TITLE_UNIT_Satoshi]) {
        unit = JUB_NS_BTC_UNIT_TYPE::NS_Satoshi;
    }
    
    return unit;
}


+ (NSUInteger)enumUnitToDecimal:(JUB_NS_BTC_UNIT_TYPE)unit {
    
    NSUInteger decimal = 0;
    
    switch (unit) {
    case JUB_NS_BTC_UNIT_TYPE::NS_BTC:
        decimal = 8;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_cBTC:
        decimal = 6;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_mBTC:
        decimal = 5;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_uBTC:
        decimal = 2;
        break;
    case JUB_NS_BTC_UNIT_TYPE::NS_Satoshi:
        decimal = 8;
        break;
    default:
        break;
    }
    
    return decimal;
}


+ (NSString*)convertToProperFormat:(NSString*)amount
                               opt:(JUB_NS_ENUM_BTC_COIN)opt {
    
    NSString *amt = amount;
    if (   nil == amount
        || [amount isEqual:@""]
        ) {
        return amt;
    }
    
    switch (opt) {
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
        amt = [JUBAmount convertToTheSmallestUnit:amount
                                            point:@"."
                                          decimal:decimalQRC20];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
        amt = [JUBAmount convertToTheSmallestUnit:amount
                                            point:@"."
                                          decimal:decimalUSDT];
        break;
    default:
        break;
    }
    
    return amt;
}


@end
