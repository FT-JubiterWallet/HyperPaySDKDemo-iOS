//
//  JUBBTCController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/4/28.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"
#import "JUBBTCAmount.h"

#import "JUBBTCController.h"

#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+COIN_BTC.h"
#import "JubSDKCore/JubSDKCore+HCash.h"


@interface JUBBTCController ()

@end


@implementation JUBBTCController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"BTC options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_BTC;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    switch ([sharedData deviceType]) {
    case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
        self.navRightButtonTitle = BUTTON_TITLE_SETUNIT;
        break;
    default:
        break;
    }   // switch ([sharedData deviceType]) end
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_BTCP2PKH,
        BUTTON_TITLE_BTCP2WPKH,
        BUTTON_TITLE_LTC,
        BUTTON_TITLE_BCH,
        BUTTON_TITLE_QTUM,
        BUTTON_TITLE_QTUM_QRC20,
        BUTTON_TITLE_USDT,
        BUTTON_TITLE_HCASH
    ];
}


- (void) navRightButtonCallBack {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    JUBListAlert *listAlert = [JUBListAlert showCallBack:^(NSString *_Nonnull selectedItem) {
        NSLog(@"UNIT selected: %@", selectedItem);
        if (!selectedItem) {
            NSLog(@"JUBBTCController::JUBListAlert canceled");
            return;
        }
        
        JUB_NS_BTC_UNIT_TYPE unit = [JUBBTCAmount stringToEnumUnit:selectedItem];
        [sharedData setCoinUnit:unit];
    }];
    
    listAlert.title = @"Please select UNIT:";
    [listAlert addItems:@[
        TITLE_UNIT_BTC,
        TITLE_UNIT_cBTC,
        TITLE_UNIT_mBTC,
        TITLE_UNIT_uBTC,
        TITLE_UNIT_Satoshi
    ]];
    [listAlert setTextAlignment:NSTextAlignment::NSTextAlignmentRight];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinBTCOpt:(NSUInteger)deviceID {
    
    const char* json_file = "";
    JUB_NS_ENUM_COINTYPE_BTC coinType = JUB_NS_ENUM_COINTYPE_BTC::NS_COINBTC;
    switch ((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2PKH:
    {
        json_file = JSON_FILE_BTC_44;
        coinType = NS_COINBTC;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2WPKH:
    {
        json_file = JSON_FILE_BTC_49;
        coinType = NS_COINBTC;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_LTC:
    {
        json_file = JSON_FILE_LTC;
        coinType = NS_COINLTC;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_BCH:
    {
        json_file = JSON_FILE_BCH;
        coinType = NS_COINBCH;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM:
    {
        json_file = JSON_FILE_QTUM;
        coinType = NS_COINQTUM;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
    {
        json_file = JSON_FILE_QTUM_QRC20;
        coinType = NS_COINQTUM;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
    {
        json_file = JSON_FILE_BTC_USDT;
        coinType = NS_COINUSDT;
        break;
    }
    default:
        json_file = JSON_FILE_HCASH;
        break;
    }   // switch ((JUB_NS_ENUM_COINTYPE_BTC)self.selectedMenuIndex) end
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    switch (self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_HCASH:
    {
        [self HC_test:deviceID
                 root:root
               choice:(int)self.optIndex];
        break;
    }   // case JUB_NS_ENUM_BTC_COIN::BTN_HCASH end
    default:
    {
        [self BTC_test:deviceID
                  root:root
                choice:(int)self.optIndex
              coinType:coinType];
        break;
    }   // default end
    }   // switch (self.selectedMenuIndex) end
}


#pragma mark - BTC applet
- (void) BTC_test:(NSUInteger)deviceID
             root:(Json::Value)root
           choice:(int)choice
         coinType:(JUB_NS_ENUM_COINTYPE_BTC)coinType {
    
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
        
        ContextConfigBTC *cfg = [[ContextConfigBTC alloc] init];
        cfg.mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
        cfg.coinType = coinType;
        
        if (NS_COINBCH == coinType) {
            cfg.transType = JUB_NS_BTC_TRANS_TYPE::ns_p2pkh;
        }
        else {
            if (root["p2sh-segwit"].asBool()) {
                cfg.transType = JUB_NS_BTC_TRANS_TYPE::ns_p2sh_p2wpkh;
            }
            else {
                cfg.transType = JUB_NS_BTC_TRANS_TYPE::ns_p2pkh;
            }
        }
        
        contextID = [g_sdk JUB_CreateContextBTC:deviceID
                                            cfg:cfg];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextBTC() OK.]"]];
        [sharedData setCurrMainPath:cfg.mainPath];
        [sharedData setCurrCoinType:cfg.coinType];
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
    
    NSString* mainXpub = [g_sdk JUB_GetMainHDNodeBTC:contextID];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeBTC() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Main xpub(%@): %@.", [sharedData currMainPath], mainXpub]];
    
    NSString *xpub = [g_sdk JUB_GetHDNodeBTC:contextID
                                        path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeBTC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input xpub(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], xpub]];
    
    NSString *address = [g_sdk JUB_GetAddressBTC:contextID
                                         addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_OWN
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressBTC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input address(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString *address = [g_sdk JUB_GetAddressBTC:contextID
                                         addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_OWN
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_TRUE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressBTC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%ld%ld) is: %@.", [[JUBSharedData sharedInstance] currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
    NSString *address = [g_sdk JUB_SetMyAddressBTC:contextID
                                           addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_OWN
                                              path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressBTC() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"set my address is: %@.", address]];
    
    return rv;
}


- (NSUInteger) set_unit_test:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUB_NS_BTC_UNIT_TYPE unit = [[JUBSharedData sharedInstance] coinUnit];
    if (JUB_NS_BTC_UNIT_TYPE::NS_BTC_UNIT_TYPE_NS == unit) {
        return JUBR_OK;
    }
    
    [g_sdk JUB_SetUnitBTC:contextID
                     unit:unit];
    rv = [g_sdk lastError];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetUnitBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetUnitBTC() OK.]"]];
    
    return rv;
}


- (NSString*) inputAmount {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return nil;
    }
    
    if (JUB_NS_ENUM_BTC_COIN::BTN_HCASH == [sharedData currCoinType]) {
        return @"";
    }
    
    JUB_NS_BTC_UNIT_TYPE coinUnit = [sharedData coinUnit];
    
    __block
    NSString *amount = nil;
    
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
                 || [JUBBTCAmount isValid:content]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBBTCAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBBTCAmount title:coinUnit];
    customInputAlert.message = [JUBBTCAmount message];
    customInputAlert.textFieldPlaceholder = [JUBBTCAmount formatRules];
    customInputAlert.limitLength = [JUBBTCAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // Convert to the smallest unit
    NSString *smallestUnit;
    switch ((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
        smallestUnit = [JUBBTCAmount convertToProperFormat:amount
                                                       opt:(JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex];
        break;
    default:
        smallestUnit = [JUBBTCAmount convertToTheSmallestUnit:amount
                                                        point:@"."
                                                      decimal:[JUBBTCAmount enumUnitToDecimal:coinUnit]];
        break;
    }
    
    return smallestUnit;
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                amount:(NSString*)amount
                  root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    switch((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2PKH:
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2WPKH:
    case JUB_NS_ENUM_BTC_COIN::BTN_LTC:
    case JUB_NS_ENUM_BTC_COIN::BTN_BCH:
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM:
        rv = [self transaction_proc:contextID
                             amount:amount
                               root:root];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
        rv = [self transactionQTUM_proc:contextID
                                 amount:amount
                                   root:root];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
        rv = [self transactionUSDT_proc:contextID
                                 amount:amount
                                   root:root];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_HCASH:
        rv = [self transactionHC_proc:contextID
                               amount:amount
                                 root:root];
        break;
    default:
        break;
    }
    
    return rv;
}


InputBTC* JSON2InputBTC(int i, Json::Value root) {
    InputBTC* input = [[InputBTC alloc] init];
    
    if (!root["inputs"][i]["multisig"].asBool()) {
        input.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2PKH;
    }
    else {
        input.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2SH_MULTISIG;
    }
    
    input.preHash = [NSString stringWithUTF8String:(char*)root["inputs"][i]["preHash"].asCString()];
    input.preIndex = root["inputs"][i]["preIndex"].asInt();
    if (nil == input.path) {
        input.path = [[BIP32Path alloc] init];
    }
    if (root["inputs"][i]["bip32_path"]["change"].asBool()) {
        input.path.change = BOOL_NS_TRUE;
    }
    else {
        input.path.change = BOOL_NS_FALSE;
    }
    input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
    input.amount = root["inputs"][i]["amount"].asUInt64();
    
    return input;
}


OutputBTC* JSON2OutputBTC(int i, Json::Value root) {
    OutputBTC* output = [[OutputBTC alloc] init];
    
    if (!root["outputs"][i]["multisig"].asBool()) {
        output.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2PKH;
    }
    else {
        output.type = JUB_NS_SCRIPT_BTC_TYPE::NS_P2SH_MULTISIG;
    }
    
    if (nil == output.stdOutput) {
        output.stdOutput = [[StdOutput alloc] init];
    }
    if (nil == output.stdOutput.path) {
        output.stdOutput.path = [[BIP32Path alloc] init];
    }
    output.stdOutput.address = [NSString stringWithUTF8String:(char*)root["outputs"][i]["address"].asCString()];
    output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
    if (root["outputs"][i]["change_address"].asBool()) {
        output.stdOutput.isChangeAddress = BOOL_NS_TRUE;
    }
    else {
        output.stdOutput.isChangeAddress = BOOL_NS_FALSE;
    }
    if (root["outputs"][i]["bip32_path"]["change"].asBool()) {
        output.stdOutput.path.change = BOOL_NS_TRUE;
    }
    else {
        output.stdOutput.path.change = BOOL_NS_FALSE;
    }
    
    output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
    
    if (BOOL_NS_TRUE == output.stdOutput.isChangeAddress) {
        NSString* changeAddress = [g_sdk JUB_GetAddressBTC:[[JUBSharedData sharedInstance] currContextID]
                                                      path:output.stdOutput.path
                                                     bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
        if (JUBR_OK == [g_sdk lastError]) {
            output.stdOutput.address = changeAddress;
        }
    }
    
    return output;
}


- (NSUInteger) transaction_proc:(NSUInteger)contextID
                         amount:(NSString*)amount
                           root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    NSMutableArray *ins = [NSMutableArray array];
    int inputNumber = root["inputs"].size();
    
    InputBTC* selfdefInput = [[InputBTC alloc] init];
    for (int i = 0; i < inputNumber; i++) {
        InputBTC* input = JSON2InputBTC(i, root);
        [ins addObject:input];
        selfdefInput = input;
    }
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        selfdefInput.amount = [amount longLongValue];
        [ins addObject:selfdefInput];
    }
    NSArray* inputs = [NSArray arrayWithArray:ins];
    
    NSMutableArray *outs = [NSMutableArray array];
    int outputNumber = root["outputs"].size();
    
    OutputBTC *selfdefOutput = [[OutputBTC alloc] init];
    for (int i = 0; i < outputNumber; i++) {
        OutputBTC* output = JSON2OutputBTC(i, root);
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            output.stdOutput.isChangeAddress = JUB_NS_ENUM_BOOL::BOOL_NS_TRUE;
        }
        if (output.stdOutput.isChangeAddress) {
            NSString* changeAddress = [g_sdk JUB_GetAddressBTC:contextID
                                                       addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_OWN
                                                          path:output.stdOutput.path
                                                         bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
            if (JUBR_OK == [g_sdk lastError]) {
                output.stdOutput.address = changeAddress;
            }
        }
        [outs addObject:output];
        selfdefOutput = output;
    }
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        selfdefOutput.stdOutput.isChangeAddress = JUB_NS_ENUM_BOOL::BOOL_NS_FALSE;
        selfdefOutput.stdOutput.amount = [amount longLongValue];
        [outs addObject:selfdefOutput];
    }
    NSArray* outputs = [NSArray arrayWithArray:outs];
    
    NSString* raw = [g_sdk JUB_SignTransactionBTC:contextID
//                                          addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_LEGACY
                                       inputArray:inputs
                                      outputArray:outputs
                                         lockTime:0];
    rv = (long)[g_sdk JUB_LastError];
    if (JUBR_USER_CANCEL == rv) {
        [self addMsgData:[NSString stringWithFormat:@"[User cancel the transaction !]"]];
        return rv;
    }
    if (   JUBR_OK != rv
        || nullptr == raw
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() OK.]"]];
    
    if (raw) {
        size_t txLen = [raw length]/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %@.", txLen, raw]];
    }
    
    return rv;
}


- (NSUInteger) transactionQTUM_proc:(NSUInteger)contextID
                             amount:(NSString*)amount
                               root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    try {
        NSString* value = [NSString stringWithUTF8String:(char*)root["QRC20_amount"].asCString()];
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            value = amount;
        }
        NSArray *qtumouts = [g_sdk JUB_BuildQRC20Outputs:contextID
                                            contractAddr:[NSString stringWithUTF8String:(char*)root["QRC20_contractAddr"].asCString()]
                                                 decimal:root["QRC20_decimal"].asUInt64()
                                                  symbol:[NSString stringWithUTF8String:(char*)root["QRC20_symbol"].asCString()]
                                                gasLimit:root["gasLimit"].asUInt64()
                                                gasPrice:root["gasPrice"].asUInt64()
                                                      to:[NSString stringWithUTF8String:(char*)root["QRC20_to"].asCString()]
                                                   value:value];
        rv = (long)[g_sdk JUB_LastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildQRC20Outputs() return 0x%2lx.]", rv]];
            return rv;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildQRC20Outputs() OK.]"]];
        [self addMsgData:[NSString stringWithFormat:@"QTUM output[%li]", [qtumouts count]]];
        
        NSMutableArray *ins = [NSMutableArray array];
        int inputNumber = root["inputs"].size();
        for (int i = 0; i < inputNumber; i++) {
            InputBTC* input = JSON2InputBTC(i, root);
            [ins addObject:input];
        }
        NSArray* inputs = [NSArray arrayWithArray:ins];
        
        NSMutableArray *outs = [NSMutableArray array];
        int outputNumber = root["outputs"].size();
        for (int i = 0; i < outputNumber; i++) {
            OutputBTC* output = JSON2OutputBTC(i, root);
            if (output.stdOutput.isChangeAddress) {
                NSString* changeAddress = [g_sdk JUB_GetAddressBTC:contextID
                                                           addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_OWN
                                                              path:output.stdOutput.path
                                                             bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
                if (JUBR_OK == [g_sdk lastError]) {
                    output.stdOutput.address = changeAddress;
                }
            }
            [outs addObject:output];
        }
        
        for (NSUInteger i=0; i<[qtumouts count]; ++i) {
            [outs addObject:qtumouts[i]];
        }
        NSArray* outputs = [NSArray arrayWithArray:outs];
        
        NSString* raw = [g_sdk JUB_SignTransactionBTC:contextID
//                                              addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_LEGACY
                                           inputArray:inputs
                                          outputArray:outputs
                                             lockTime:0];
        rv = (long)[g_sdk JUB_LastError];
        if (JUBR_USER_CANCEL == rv) {
            NSLog(@"User cancel the transaction !\n");
            return rv;
        }
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return 0x%2lx.]", rv]];
            return rv;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() OK.]"]];
        [self addMsgData:[NSString stringWithFormat:@"USDT raw[%lu]: %@\n", [raw length]/2, raw]];
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
    
    return rv;
}


- (NSUInteger) transactionUSDT_proc:(NSUInteger)contextID
                             amount:(NSString*)amount
                               root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    try {
        NSMutableArray *ins = [NSMutableArray array];
        int inputNumber = root["inputs"].size();
        for (int i = 0; i < inputNumber; i++) {
            InputBTC* input = JSON2InputBTC(i, root);
            [ins addObject:input];
        }
        NSArray* inputs = [NSArray arrayWithArray:ins];
        
        NSMutableArray *outs = [NSMutableArray array];
        int outputNumber = root["outputs"].size();
        for (int i = 0; i < outputNumber; i++) {
            OutputBTC* output = JSON2OutputBTC(i, root);
            if (output.stdOutput.isChangeAddress) {
                NSString* changeAddress = [g_sdk JUB_GetAddressBTC:contextID
                                                           addrFmt:JUB_NS_ENUM_BTC_ADDRESS_FORMAT::NS_OWN
                                                              path:output.stdOutput.path
                                                             bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
                if (JUBR_OK == [g_sdk lastError]) {
                    output.stdOutput.address = changeAddress;
                }
            }
            [outs addObject:output];
        }
        
        NSUInteger USDTAmt = root["USDT_amount"].asUInt64();
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            USDTAmt = [amount longLongValue];
        }
        NSArray *usdtouts = [g_sdk JUB_BuildUSDTOutputs:contextID
                                                 USDTTo:[NSString stringWithUTF8String:(char*)root["USDT_to"].asCString()]
                                                 amount:USDTAmt];
        rv = (long)[g_sdk JUB_LastError];
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildUSDTOutputs() return 0x%2lx.]", rv]];
        if (JUBR_OK != rv) {
            return rv;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildUSDTOutputs() OK.]"]];
        [self addMsgData:[NSString stringWithFormat:@"USDT output[%lu]: %@.]", [usdtouts count], usdtouts]];
        
        for (NSUInteger i=0; i<[usdtouts count]; ++i) {
            [outs addObject:usdtouts[i]];
        }
        NSArray* outputs = [NSArray arrayWithArray:outs];
        
        NSString* raw = [g_sdk JUB_SignTransactionBTC:contextID
                                           inputArray:inputs
                                          outputArray:outputs
                                             lockTime:0];
        rv = [g_sdk JUB_LastError];
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return 0x%2lx.]", rv]];
        if (JUBR_USER_CANCEL == rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() CANCELED.]"]];
            return rv;
        }
        if (JUBR_OK != rv) {
            return rv;
        }
        [self addMsgData:[NSString stringWithFormat:@"USDT tx[%lu]: %@.]", [raw length]/2, raw]];
        
        return rv;
    }
    catch (...) {
        error_exit("Error format json file\n");
    }
    
    return rv;
}


#pragma mark - Hcash applet
- (void)HC_test:(NSUInteger)deviceID
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
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() return 0x%2lx.]", rv]];
            }
            else {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() OK.]"]];
            }
            [sharedData setCurrContextID:0];
        }
        
        ContextConfigHC *cfg = [[ContextConfigHC alloc] init];
        cfg.mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
        
        contextID = [g_sdk JUB_CreateContextHC:deviceID
                                           cfg:cfg];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextHC() return 0x%2lx.]", rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextHC() OK.]"]];
        [sharedData setCurrMainPath:cfg.mainPath];
        [sharedData setCurrContextID:contextID];
        
        switch (choice) {
        case JUB_NS_ENUM_OPT::GET_ADDRESS:
        {
            [self get_address_pubkey_HC:contextID];
            break;
        }
        case JUB_NS_ENUM_OPT::SHOW_ADDRESS:
        {
            [self show_address_test_HC:contextID];
            break;
        }
        case JUB_NS_ENUM_OPT::TRANSACTION:
        {
            if (JUBR_OK != [self verify_user:contextID]) {
                break;
            }
            
            [self transaction_test:contextID
                            amount:[[JUBSharedData sharedInstance] amount]
                              root:root];
            break;
        }
        case JUB_NS_ENUM_OPT::SET_TIMEOUT:
        {
            [self set_time_out:contextID];
            break;
        }
        case JUB_NS_ENUM_OPT::SET_MY_ADDRESS:
        default:
            break;
        }   // switch (choice) end
    }
    catch (...) {
        error_exit("[Error format json file.]\n");
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextHC() OK.]"]];
    }
}


- (void) get_address_pubkey_HC:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString* mainXpub = [g_sdk JUB_GetMainHDNodeHC:contextID];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeHC() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeHC() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Main xpub(%@): %@.", [sharedData currMainPath], mainXpub]];
    
    NSString *xpub = [g_sdk JUB_GetHDNodeHC:contextID
                                       path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeHC() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeHC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input xpub(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], xpub]];
    
    NSString *address = [g_sdk JUB_GetAddressHC:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input address(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (void) show_address_test_HC:(NSUInteger)contextID {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString *address = [g_sdk JUB_GetAddressHC:contextID
                                           path:[sharedData currPath]
                                          bShow:JUB_NS_ENUM_BOOL::BOOL_NS_TRUE];
    NSUInteger rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%ld/%ld): %@.", [[JUBSharedData sharedInstance] currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


InputHC* JSON2InputHC(int i, Json::Value root) {
    
    InputHC* input = [[InputHC alloc] init];
    
    if (root["inputs"][i]["bip32_path"]["change"].asBool()) {
        input.path.change = BOOL_NS_TRUE;
    }
    else {
        input.path.change = BOOL_NS_FALSE;
    }
    input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
    input.amount = root["inputs"][i]["amount"].asUInt64();
    
    return input;
}


OutputHC* JSON2OutputHC(int i, Json::Value root) {
    
    OutputHC* output = [[OutputHC alloc] init];
    
    if (root["outputs"][i]["change_address"].asBool()) {
        output.isChangeAddress = BOOL_NS_TRUE;
        output.path.change = BOOL_NS_TRUE;
    }
    else {
        output.isChangeAddress = BOOL_NS_FALSE;
        output.path.change = BOOL_NS_FALSE;
    }
    output.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
    
    return output;
}


- (NSUInteger) transactionHC_proc:(NSUInteger)contextID
                           amount:(NSString*)amount
                             root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    NSMutableArray *ins = [NSMutableArray array];
    int inputNumber = root["inputs"].size();
    
    for (int i = 0; i < inputNumber; i++) {
        InputHC* input = JSON2InputHC(i, root);
        [ins addObject:input];
    }
    NSArray* inputs = [NSArray arrayWithArray:ins];
    
    NSMutableArray *outs = [NSMutableArray array];
    int outputNumber = root["outputs"].size();
    
    for (int i = 0; i < outputNumber; i++) {
        OutputHC* output = JSON2OutputHC(i, root);
        [outs addObject:output];
    }
    NSArray* outputs = [NSArray arrayWithArray:outs];
    
    NSString* unsignedTx = [NSString stringWithUTF8String:(char*)root["unsigned_tx"].asCString()];
    
    NSString* raw = [g_sdk JUB_SignTransactionHC:contextID
                                      inputArray:inputs
                                     outputArray:outputs
                                   unsignedTrans:unsignedTx];
    rv = [g_sdk JUB_LastError];
    
    if (JUBR_USER_CANCEL == rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionHC() CALCELED.]"]];
        return rv;
    }
    if (   JUBR_OK != rv
        || nullptr == raw
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionHC() return 0x%2lx.]", rv]];
        return rv;
    }
    if (raw) {
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %@", [raw length]/2, raw]];
    }
    
    return rv;
}


@end
