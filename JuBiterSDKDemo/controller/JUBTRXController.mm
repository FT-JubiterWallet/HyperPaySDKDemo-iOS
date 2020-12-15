//
//  JUBTRXController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/12/13.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBTRXController.h"
#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+COIN_TRX.h"

#import "JUBTRXAmount.h"

@interface JUBTRXController ()

@end


@implementation JUBTRXController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"TRX options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_TRX;
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_TRX,
        BUTTON_TITLE_TRC10,
        BUTTON_TITLE_TRC20
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinTRXOpt:(NSUInteger)deviceID {
    
    const char* json_file = "";
    switch (self.selectedMenuIndex) {
    case JUB_NS_ENUM_TRX_OPT::BTN_TRX:
    {
        json_file = JSON_FILE_TRX;
        break;
    }
    case JUB_NS_ENUM_TRX_OPT::BTN_TRC10:
    {
        json_file = JSON_FILE_TRC10;
        break;
    }
    case JUB_NS_ENUM_TRX_OPT::BTN_TRC20:
    {
        json_file = JSON_FILE_TRC20;
        break;
    }
    default:
        break;
    }   // switch (self.selectedMenuIndex) end
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self TRX_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - TRX applet
- (void) TRX_test:(NSUInteger)deviceID
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
        
        ContextConfigTRX *cfg = [[ContextConfigTRX alloc] init];
        cfg.mainPath = [NSString stringWithUTF8String:root["main_path"].asCString()];
        contextID = [g_sdk JUB_CreateContextTRX:deviceID
                                            cfg:cfg];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextTRX() OK.]"]];
        [sharedData setCurrMainPath:[NSString stringWithFormat:@"%@", cfg.mainPath]];
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
    
    NSString *pubkey = [g_sdk JUB_GetMainHDNodeTRX:contextID
                                            format:JUB_NS_ENUM_PUB_FORMAT::NS_HEX];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeTRX() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"MainXpub(%@) in hex format: %@.", [sharedData currMainPath], pubkey]];
    
    BIP32Path *path = [[BIP32Path alloc] init];
    path.change = [sharedData currPath].change;;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    pubkey = [g_sdk JUB_GetHDNodeTRX:contextID
                              format:JUB_NS_ENUM_PUB_FORMAT::NS_HEX
                                path:path];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeTRX() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%ld/%ld) in hex format: %@.", [sharedData currMainPath], path.change, path.addressIndex, pubkey]];
    
    NSString* address = [g_sdk JUB_GetAddressTRX:contextID
                                            path:path
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"address(%@/%ld/%ld): %@.", [sharedData currMainPath], path.change, path.addressIndex, address]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    BIP32Path *path = [[BIP32Path alloc] init];
    path.change = [sharedData currPath].change;;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    NSString* address = [g_sdk JUB_GetAddressTRX:contextID
                                            path:path
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_TRUE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%ld/%ld) is: %@.", [sharedData currMainPath], path.change, path.addressIndex, address]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
    BIP32Path *path = [[BIP32Path alloc] init];
    path.change = [sharedData currPath].change;;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    NSString* address = [g_sdk JUB_SetMyAddressTRX:contextID
                                              path:path];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressTRX() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Set my address(%@/%lu/%ld) is: %@.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
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
                 || [JUBTRXAmount isValid:content
                                      opt:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBTRXAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBTRXAmount title:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex];
    customInputAlert.message = [JUBTRXAmount message];
    customInputAlert.textFieldPlaceholder = [JUBTRXAmount formatRules];
    customInputAlert.limitLength = [JUBTRXAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    return [JUBTRXAmount convertToProperFormat:amount
                                           opt:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex];
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
    
    if (!root["TRX"]["contracts"].isObject()) {
        return JUBR_ARGUMENTS_BAD;
    }

    TxTRX* tx = [[TxTRX alloc] init];
    tx.refBlockBytes = [NSString stringWithUTF8String:root["TRX"]["pack"]["ref_block_bytes"].asCString()];
    tx.refBlockNum = @"0";
    tx.refBlockHash = [NSString stringWithUTF8String:root["TRX"]["pack"]["ref_block_hash"].asCString()];
    tx.expiration = [NSString stringWithUTF8String:root["TRX"]["pack"]["expiration"].asCString()];
    tx.timestamp = [NSString stringWithUTF8String:root["TRX"]["pack"]["timestamp"].asCString()];
    tx.feeLimit = [NSString stringWithUTF8String:root["TRX"]["pack"]["fee_limit"].asCString()];

    TRXContract* contrTRX = [[TRXContract alloc] init];
    contrTRX.type = (JUB_NS_TRX_CONTR_TYPE)root["TRX"]["contracts"]["type"].asUInt();

    std::string strOwnerAddress = root["TRX"]["contracts"]["owner_address"].asCString();
    
    const char* sType = std::to_string((unsigned int)contrTRX.type).c_str();
    switch (contrTRX.type) {
    case JUB_NS_TRX_CONTR_TYPE::NS_XFER_CONTRACT:
    {
        contrTRX.xfer = [[TRXTransferContract alloc] init];
        contrTRX.xfer.ownerAddress = [NSString stringWithUTF8String:strOwnerAddress.c_str()];
        contrTRX.xfer.toAddress = [NSString stringWithUTF8String:root["TRX"]["contracts"][sType]["to_address"].asCString()];
        contrTRX.xfer.amount = root["TRX"]["contracts"][sType]["amount"].asUInt();
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            contrTRX.xfer.amount = [amount integerValue];
        }
        break;
    }
    case JUB_NS_TRX_CONTR_TYPE::NS_XFER_ASSET_CONTRACT:
    {
        contrTRX.assetXfer = [[TRXTransferAssetContract alloc] init];
        contrTRX.assetXfer.assetName = [NSString stringWithUTF8String:root["TRX"]["contracts"][sType]["asset_name"].asCString()];
        contrTRX.assetXfer.toAddress = [NSString stringWithUTF8String:root["TRX"]["contracts"][sType]["to_address"].asCString()];
        contrTRX.assetXfer.amount = root["TRX"]["contracts"][sType]["amount"].asUInt();
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            contrTRX.xfer.amount = [amount integerValue];
        }
        break;
    }
    case JUB_NS_TRX_CONTR_TYPE::NS_TRIG_SMART_CONTRACT:
    {
        tx.feeLimit = [NSString stringWithUTF8String:root["TRX"]["contracts"][sType]["fee_limit"].asCString()];
        
        contrTRX.triggerSmart = [[TRXTriggerSmartContract alloc] init];
        contrTRX.triggerSmart.ownerAddress = [NSString stringWithUTF8String:strOwnerAddress.c_str()];
        contrTRX.triggerSmart.contractAddress = [NSString stringWithUTF8String:root["TRX"]["contracts"][sType]["contract_address"].asCString()];
        contrTRX.triggerSmart.data = [NSString stringWithUTF8String:root["TRX"]["contracts"][sType]["data"].asCString()];
        contrTRX.triggerSmart.callValue = root["TRX"]["contracts"][sType]["call_value"].asUInt64();
        contrTRX.triggerSmart.callTokenValue = root["TRX"]["contracts"][sType]["call_token_value"].asUInt64();
        contrTRX.triggerSmart.tokenId = root["TRX"]["contracts"][sType]["token_id"].asUInt64();
        break;
    }
    case JUB_NS_TRX_CONTR_TYPE::NS_CREATE_SMART_CONTRACT:
    case JUB_NS_TRX_CONTR_TYPE::NS_TX_XRP_TYPE_NS:
    default:
        return JUBR_ARGUMENTS_BAD;
    }
    
    tx.contracts = [[NSMutableArray alloc] init];
    [tx.contracts addObject:contrTRX];
    
    NSString* packContractInPb = [g_sdk JUB_PackContractTRX:contextID
                                                         tx:tx];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_PackContractTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_PackContractTRX() OK.]"]];
    
    if (packContractInPb) {
        [self addMsgData:[NSString stringWithFormat:@"pack contract in protobuf(%lu): %@.", [packContractInPb length], packContractInPb]];
    }
    
    BIP32Path *path = [[BIP32Path alloc] init];
    path.change = (JUB_NS_ENUM_BOOL)root["TRX"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["TRX"]["bip32_path"]["addressIndex"].asUInt();
    
    NSString* rawInJSON = [g_sdk JUB_SignTransactionTRX:contextID
                                                   path:path
                                     packedContractInPb:packContractInPb];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionTRX() OK.]"]];
    
    if (rawInJSON) {
        [self addMsgData:[NSString stringWithFormat:@"tx raw in JSON: %@.", rawInJSON]];
    }
    
    return JUBR_OK;
}


@end
