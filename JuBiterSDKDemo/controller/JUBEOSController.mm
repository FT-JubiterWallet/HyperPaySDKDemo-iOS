//
//  JUBEOSController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBEOSController.h"

#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+COIN_EOS.h"

#import "JUBEOSAmount.h"

@interface JUBEOSController ()

@end


@implementation JUBEOSController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"EOS options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_EOS;
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_EOS,
        BUTTON_TITLE_EOSTOKEN,
        BUTTON_TITLE_EOSBUYRAM,
        BUTTON_TITLE_EOSSELLRAM,
        BUTTON_TITLE_EOSSTAKE,
        BUTTON_TITLE_EOSUNSTAKE,
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinEOSOpt:(NSUInteger)deviceID {
    
    const char* json_file = "";
    switch (self.selectedMenuIndex) {
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS:
    {
        json_file = JSON_FILE_EOS;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_TOKEN:
    {
        json_file = JSON_FILE_EOS_TOKEN;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_BUYRAM:
    {
        json_file = JSON_FILE_EOS_BUYRAM;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_SELLRAM:
    {
        json_file = JSON_FILE_EOS_SELLRAM;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_STAKE:
    {
        json_file = JSON_FILE_EOS_STAKE;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_UNSTAKE:
    {
        json_file = JSON_FILE_EOS_UNSTAKE;
        break;
    }
    default:
        break;
    }   // switch (self.selectedMenuIndex) end
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self EOS_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - EOS applet
- (void) EOS_test:(NSUInteger)deviceID
             root:(Json::Value)root
           choice:(int)choice {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    try {
        NSUInteger contextID = [sharedData currContextID];
        if (0 != contextID) {
            [sharedData setCurrMainPath:nil];
            [sharedData setCurrCoinType:-1];
            [g_sdk JUB_ClearContext:contextID];
            rv = [g_sdk lastError];
            if (JUBR_OK != rv) {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            }
            else {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() OK.]"]];
            }
            [sharedData setCurrContextID:0];
        }
        
        ContextConfigEOS *cfg = [[ContextConfigEOS alloc] init];
        cfg.mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
        contextID = [g_sdk JUB_CreateContextEOS:deviceID
                                            cfg:cfg];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextEOS() OK.]"]];
        [sharedData setCurrMainPath:cfg.mainPath];
        [sharedData setCurrContextID:contextID];
        
        [self CoinOpt:contextID
                 root:root
               choice:choice];
    }
    catch (...) {
        error_exit("[Error format json file.]\n");
        [self addMsgData:[NSString stringWithFormat:@"[Error format json file.]"]];
    }
}


- (void) get_address_pubkey:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString* address = [g_sdk JUB_GetAddressEOS:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"address(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString *address = [g_sdk JUB_GetAddressEOS:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_TRUE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%ld/%ld) is: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
    NSString *address = [g_sdk JUB_SetMyAddressEOS:contextID
                                              path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressEOS() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Set my address(%@/%ld/%ld) is: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
    
    return rv;
}


- (NSString*) inputAmount {
    
    __block
    NSString *amount;
    
    __block
    BOOL isDone = NO;
    JUBCustomInputAlert *customInputAlert = [JUBCustomInputAlert showCallBack:^(
        NSString * _Nonnull content,
        JUBDissAlertCallBack _Nonnull dissAlertCallBack,
        JUBSetErrorCallBack  _Nonnull setErrorCallBack
    ) {
        NSLog(@"content = %@", content);
        if (nil == content) {
            isDone = YES;
            dissAlertCallBack();
        }
        else if (        [content isEqual:@""]
                 || [JUBEOSAmount isValid:content
                                      opt:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBEOSAmount formatRules:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBEOSAmount title:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex];
    customInputAlert.message = [JUBEOSAmount message];
    customInputAlert.textFieldPlaceholder = [JUBEOSAmount formatRules:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex];
    customInputAlert.limitLength = [JUBEOSAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    return [JUBEOSAmount convertToProperFormat:amount
                                           opt:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex];
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                amount:(NSString*)amount
                  root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    switch(self.selectedMenuIndex) {
    default:
        rv = [self transaction_proc:contextID
                             amount:amount
                               root:root];
        break;
    }   // switch(self.selectedMenuIndex) end
    
    return rv;
}


- (NSUInteger) transaction_proc:(NSUInteger)contextID
                         amount:(NSString*)amount
                           root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    BIP32Path *path = [[BIP32Path alloc] init];
    path.change = (JUB_NS_ENUM_BOOL)root["EOS"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["EOS"]["bip32_path"]["addressIndex"].asUInt();
    
    if (!root["EOS"]["actions"].isArray()) {
        return JUBR_ARGUMENTS_BAD;
    }
    
    NSMutableArray* actionArray = [NSMutableArray array];
    //EOS Test
    for (Json::Value::iterator it = root["EOS"]["actions"].begin(); it != root["EOS"]["actions"].end(); ++it) {
        ActionEOS *action = [[ActionEOS alloc] init];
        
        action.type = (JUB_NS_EOS_ACTION_TYPE)(*it)["type"].asUInt();
        action.currency = [NSString stringWithUTF8String:(*it)["currency"].asCString()];
        action.name     = [NSString stringWithUTF8String:(*it)["name"].asCString()];
        
        const char* sType = std::to_string((unsigned int)action.type).c_str();
        switch (action.type) {
        case JUB_NS_EOS_ACTION_TYPE::NS_XFER:
        {
            action.xfer = [[XferAction alloc] init];
            action.xfer.from  = [NSString stringWithUTF8String:(*it)[sType]["from"].asCString()];
            action.xfer.to    = [NSString stringWithUTF8String:(*it)[sType]["to"].asCString()];
            action.xfer.asset = [NSString stringWithUTF8String:(*it)[sType]["asset"].asCString()];
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [JUBEOSAmount replaceAmount:amount
                                                        asset:[NSString stringWithFormat:@"%@", action.xfer.asset]];
                action.xfer.asset = asset;
            }
            action.xfer.memo  = [NSString stringWithUTF8String:(*it)[sType]["memo"].asCString()];
            break;
        }
        case JUB_NS_EOS_ACTION_TYPE::NS_DELE:
        {
            action.dele = [[DeleAction alloc] init];
            action.dele.from     = [NSString stringWithUTF8String:(*it)[sType]["from"].asCString()];
            action.dele.receiver = [NSString stringWithUTF8String:(*it)[sType]["receiver"].asCString()];
            action.dele.netQty   = [NSString stringWithUTF8String:(*it)[sType]["stake_net_quantity"].asCString()];
            action.dele.cpuQty   = [NSString stringWithUTF8String:(*it)[sType]["stake_cpu_quantity"].asCString()];
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
                action.dele.netQty = asset;
                action.dele.cpuQty = asset;
            }
            action.dele.bStake = JUB_NS_ENUM_BOOL::BOOL_NS_TRUE;
            break;
        }
        case JUB_NS_EOS_ACTION_TYPE::NS_UNDELE:
        {
            action.dele = [[DeleAction alloc] init];
            action.dele.from     = [NSString stringWithUTF8String:(*it)[sType]["from"].asCString()];
            action.dele.receiver = [NSString stringWithUTF8String:(*it)[sType]["receiver"].asCString()];
            action.dele.netQty   = [NSString stringWithUTF8String:(*it)[sType]["unstake_net_quantity"].asCString()];
            action.dele.cpuQty   = [NSString stringWithUTF8String:(*it)[sType]["unstake_cpu_quantity"].asCString()];
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
                action.dele.netQty = asset;
                action.dele.cpuQty = asset;
            }
            action.dele.bStake = JUB_NS_ENUM_BOOL::BOOL_NS_FALSE;
            break;
        }
        case JUB_NS_EOS_ACTION_TYPE::NS_BUYRAM:
        {
            action.buyRam = [[BuyRamAction alloc] init];
            action.buyRam.payer    = [NSString stringWithUTF8String:(*it)[sType]["payer"].asCString()];
            action.buyRam.quant    = [NSString stringWithUTF8String:(*it)[sType]["quant"].asCString()];
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
                action.buyRam.quant = asset;
            }
            action.buyRam.receiver = [NSString stringWithUTF8String:(*it)[sType]["receiver"].asCString()];
            break;
        }
        case JUB_NS_EOS_ACTION_TYPE::NS_SELLRAM:
        {
            action.sellRam = [[SellRamAction alloc] init];
            action.sellRam.account = [NSString stringWithUTF8String:(*it)[sType]["account"].asCString()];
            action.sellRam.bytes   = [NSString stringWithUTF8String:(*it)[sType]["bytes"].asCString()];
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                action.sellRam.bytes = amount;
            }
            break;
        }
        case JUB_NS_EOS_ACTION_TYPE::NS_ITEM_ACTION_TYPE_NS:
        default:
            return JUBR_ARGUMENTS_BAD;
        }   // switch (action.type) end
        [actionArray addObject:action];
    }
    
    NSString* actions = [g_sdk JUB_BuildActionEOS:contextID
                                           action:actionArray];
    rv = [g_sdk JUB_LastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildActionEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildActionEOS() OK.]"]];
    if (actions) {
        [self addMsgData:[NSString stringWithFormat:@"action in JSON: %@.", actions]];
    }
    
    NSString* chainID    = [NSString stringWithUTF8String:root["EOS"]["chainID"].asCString()];
    NSString* expiration = [NSString stringWithUTF8String:root["EOS"]["expiration"].asCString()];
    NSString* referenceBlockId = [NSString stringWithUTF8String:root["EOS"]["referenceBlockId"].asCString()];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateBlockTime = [formatter dateFromString:[NSString stringWithUTF8String:(char*)root["EOS"]["referenceBlockTime"].asCString()]];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger zoneTime = [zone secondsFromGMT];
    NSDate* dateSum = [dateBlockTime dateByAddingTimeInterval:zoneTime];
    NSInteger refBlockTime = [dateSum timeIntervalSince1970];
    NSString* referenceBlockTime = [NSString stringWithFormat: @"%ld", refBlockTime];
    NSString* raw = [g_sdk JUB_SignTransactionEOS:contextID
                                             path:path
                                          chainID:chainID
                                       expiration:expiration
                                 referenceBlockId:referenceBlockId
                               referenceBlockTime:referenceBlockTime
                                           action:actions];
    rv = (long)[g_sdk JUB_LastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionEOS() OK.]"]];
    
    if (raw) {
        [self addMsgData:[NSString stringWithFormat:@"tx raw in JSON: %@.", raw]];
    }
    
    return JUBR_OK;
}


@end
