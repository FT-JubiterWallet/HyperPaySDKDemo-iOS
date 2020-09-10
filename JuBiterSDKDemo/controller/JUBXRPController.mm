//
//  JUBXRPController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBXRPController.h"
#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+COIN_XRP.h"

#import "JUBXRPAmount.h"

@interface JUBXRPController ()

@end


@implementation JUBXRPController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"XRP options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_XRP;
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_XRP
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinXRPOpt:(NSUInteger)deviceID {
    
    const char* json_file = JSON_FILE_XRP;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self XRP_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - XRP applet
- (void) XRP_test:(NSUInteger)deviceID
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
        
        ContextConfigXRP *cfg = [[ContextConfigXRP alloc] init];
        cfg.mainPath = [NSString stringWithUTF8String:root["main_path"].asCString()];
        contextID = [g_sdk JUB_CreateContextXRP:deviceID
                                            cfg:cfg];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextXRP() OK.]"]];
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
    
    NSString *mainXpub = [g_sdk JUB_GetMainHDNodeXRP:contextID
                                              format:JUB_NS_ENUM_PUB_FORMAT::NS_HEX];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"MainXpub in hex format: %@.", mainXpub]];
    
    NSString *xpub = [g_sdk JUB_GetHDNodeXRP:contextID
                                      format:JUB_NS_ENUM_PUB_FORMAT::NS_HEX
                                        path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%ld/%ld) in hex format: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], xpub]];
    
    NSString *address = [g_sdk JUB_GetAddressXRP:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"address(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString *address = [g_sdk JUB_GetAddressXRP:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_TRUE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%ld/%ld) is: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
    NSString *address = [g_sdk JUB_SetMyAddressXRP:contextID
                                              path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressXRP() OK.]"]];
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
                 || [JUBXRPAmount isValid:content]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBXRPAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBXRPAmount title:JUB_NS_ENUM_XRP_COIN::BTN_XRP];
    customInputAlert.message = [JUBXRPAmount message];
    customInputAlert.textFieldPlaceholder = [JUBXRPAmount formatRules];
    customInputAlert.limitLength = [JUBXRPAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // Convert to the smallest unit
    return [JUBXRPAmount convertToProperFormat:amount
                                           opt:JUB_NS_ENUM_XRP_COIN::BTN_XRP];
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
    path.change = (JUB_NS_ENUM_BOOL)root["XRP"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["XRP"]["bip32_path"]["addressIndex"].asUInt();
    
    //@interface TxXRP : NSObject
    //@property (atomic, copy  ) NSString* _Nonnull account;
    //@property (atomic, assign) JUB_NS_XRP_TX_TYPE type;
    //@property (atomic, copy  ) NSString* _Nonnull fee;
    //@property (atomic, copy  ) NSString* _Nonnull sequence;
    //@property (atomic, copy  ) NSString* _Nonnull accountTxnID;
    //@property (atomic, copy  ) NSString* _Nonnull flags;
    //@property (atomic, copy  ) NSString* _Nonnull lastLedgerSequence;
    //@property (atomic, strong) XRPMemo* _Nonnull memo;
    //@property (atomic, copy  ) NSString* _Nonnull sourceTag;
    //@property (atomic, strong) PaymentXRP* _Nonnull pymt;
    //@end
    TxXRP *xrp = [[TxXRP alloc] init];
    xrp.type = (JUB_NS_XRP_TX_TYPE)root["XRP"]["type"].asUInt();
    xrp.memo.type   = [NSString stringWithUTF8String:root["XRP"]["memo"]["type"].asCString()];
    xrp.memo.data   = [NSString stringWithUTF8String:root["XRP"]["memo"]["data"].asCString()];
    xrp.memo.format = [NSString stringWithUTF8String:root["XRP"]["memo"]["format"].asCString()];
    switch (xrp.type) {
    case JUB_NS_XRP_TX_TYPE::NS_PYMT:
    {
        xrp.account  = [NSString stringWithUTF8String:root["XRP"]["account"].asCString()];
        xrp.fee      = [NSString stringWithUTF8String:root["XRP"]["fee"].asCString()];
        xrp.flags    = [NSString stringWithUTF8String:root["XRP"]["flags"].asCString()];
        xrp.sequence = [NSString stringWithUTF8String:root["XRP"]["sequence"].asCString()];
        xrp.lastLedgerSequence = [NSString stringWithUTF8String:root["XRP"]["lastLedgerSequence"].asCString()];
        break;
    }
    default:
        return JUBR_ARGUMENTS_BAD;
    }   // switch (xrp.type) end
    
    //@interface PaymentXRP : NSObject
    //@property (atomic, assign) JUB_NS_XRP_PYMT_TYPE type;
    //@property (atomic, strong) PymtAmount* _Nonnull amount;
    //@property (atomic, copy  ) NSString* _Nonnull destination;
    //@property (atomic, copy  ) NSString* _Nonnull destinationTag;
    //@property (atomic, copy  ) NSString* _Nonnull invoiceID;    // [Optional]
    //@property (atomic, strong) PymtAmount* _Nonnull sendMax;    // [Optional]
    //@property (atomic, strong) PymtAmount* _Nonnull deliverMin; // [Optional]
    //@end
    const char* sType = std::to_string((unsigned int)xrp.type).c_str();
    xrp.pymt = [[PaymentXRP alloc] init];
    xrp.pymt.type = (JUB_NS_XRP_PYMT_TYPE)root["XRP"][sType]["type"].asUInt();
    switch (xrp.pymt.type) {
    case JUB_NS_XRP_PYMT_TYPE::NS_DXRP:
    {
        xrp.pymt.amount = [[PymtAmount alloc] init];
        xrp.pymt.destination    = [NSString stringWithUTF8String:root["XRP"][sType]["destination"].asCString()];
        xrp.pymt.amount.value   = [NSString stringWithUTF8String:root["XRP"][sType]["amount"]["value"].asCString()];
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            xrp.pymt.amount.value = amount;
        }
        xrp.pymt.destinationTag = [NSString stringWithUTF8String:root["XRP"][sType]["destinationTag"].asCString()];
        break;
    }
    default:
        return JUBR_ARGUMENTS_BAD;
    }   // switch (xrp.pymt.type) end
    
    NSString* raw = [g_sdk JUB_SignTransactionXRP:contextID
                                             path:path
                                               tx:xrp];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionXRP() OK.]"]];
    
    if (raw) {
        size_t txLen = [raw length]/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %@.", txLen, raw]];
    }
    
    return rv;
}


@end
