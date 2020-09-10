//
//  JUBETHController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/4/28.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBETHController.h"

#import "JubSDKCore/JubSDKCore+DEV.h"
#import "JubSDKCore/JubSDKCore+COIN_ETH.h"

#import "JUBETHAmount.h"

@interface JUBETHController ()

@end


@implementation JUBETHController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ETH options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_ETH;
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_ETH,
        BUTTON_TITLE_ETH_ERC20,
//        BUTTON_TITLE_ETC
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinETHOpt:(NSUInteger)deviceID {
    
    const char* json_file = "";
    switch (self.selectedMenuIndex) {
    case JUB_NS_ENUM_ETH_COIN::BTN_ETH:
    {
        json_file = JSON_FILE_ETH;
        break;
    }
    case JUB_NS_ENUM_ETH_COIN::BTN_ETH_ERC20:
    {
        json_file = JSON_FILE_ETH;
        break;
    }
    case JUB_NS_ENUM_ETH_COIN::BTN_ETC:
    {
        json_file = JSON_FILE_ETC;
        break;
    }
    default:
        break;
    }   // switch (self.selectedMenuIndex) end
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self ETH_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - ETH applet
- (void) ETH_test:(NSUInteger)deviceID
             root:(Json::Value)root
           choice:(int)choice {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    try {
        NSUInteger contextID = 0;
        
        ContextConfigETH *cfg = [[ContextConfigETH alloc] init];
        cfg.mainPath = [NSString stringWithUTF8String:(char*)root["main_path"].asCString()];
        cfg.chainID = root["chainID"].asInt();
        contextID = [g_sdk JUB_CreateContextETH:deviceID
                                            cfg:cfg];
        rv = [g_sdk lastError];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextETH() OK.]"]];
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
    
    NSString* pubkey = [g_sdk JUB_GetMainHDNodeETH:contextID
                                            format:NS_HEX];
    rv = (long)[g_sdk JUB_LastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeETH() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"MainXpub(%@) in hex format: %@.", [sharedData currMainPath], pubkey]];
    
    pubkey = [g_sdk JUB_GetMainHDNodeETH:contextID
                                  format:NS_XPUB];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeETH() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"MainXpub(%@) in xpub format: %@.", [sharedData currMainPath], pubkey]];
    
    pubkey = [g_sdk JUB_GetHDNodeETH:contextID
                              format:NS_HEX
                                path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeETH() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%ld/%ld) in hex format: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], pubkey]];
    
    pubkey = [g_sdk JUB_GetHDNodeETH:contextID
                              format:NS_XPUB
                                path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeETH() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%ld/%ld) in xpub format: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], pubkey]];
    
    NSString* address = [g_sdk JUB_GetAddressETH:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_FALSE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressETH() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"address(%@/%ld/%ld): %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    NSString *address = [g_sdk JUB_GetAddressETH:contextID
                                            path:[sharedData currPath]
                                           bShow:JUB_NS_ENUM_BOOL::BOOL_NS_TRUE];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressETH() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%ld/%ld) is: %@.", [sharedData currMainPath], [[sharedData currPath] change], [[sharedData currPath] addressIndex], address]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    NSUInteger rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
    NSString *address = [g_sdk JUB_SetMyAddressETH:contextID
                                              path:[sharedData currPath]];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressETH() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"set my address is: %@.", address]];
    
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
                 || [JUBETHAmount isValid:content]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBETHAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBETHAmount title:(JUB_NS_ENUM_ETH_COIN)self.selectedMenuIndex];
    customInputAlert.message = [JUBETHAmount message];
    customInputAlert.textFieldPlaceholder = [JUBETHAmount formatRules];
    customInputAlert.limitLength = [JUBETHAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // Convert to the smallest unit
    return [JUBETHAmount convertToProperFormat:amount
                                           opt:(JUB_NS_ENUM_ETH_COIN)self.selectedMenuIndex];
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                amount:(NSString*)amount
                  root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    switch(self.selectedMenuIndex) {
    case JUB_NS_ENUM_ETH_COIN::BTN_ETH_ERC20:
        rv = [self transactionERC20_proc:contextID
                                  amount:amount
                                    root:root];
        break;
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
    
    BIP32Path* path = [[BIP32Path alloc] init];
    path.change = (JUB_NS_ENUM_BOOL)root["ETH"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["ETH"]["bip32_path"]["addressIndex"].asUInt();
    
    //ETH Test
    NSUInteger nonce = root["ETH"]["nonce"].asUInt();//.asDouble();
    NSUInteger gasLimit = root["ETH"]["gasLimit"].asUInt();//.asDouble();
    NSString* gasPriceInWei = [NSString stringWithUTF8String:(char*)root["ETH"]["gasPriceInWei"].asCString()];
    NSString* valueInWei = [NSString stringWithUTF8String:(char*)root["ETH"]["valueInWei"].asCString()];
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        valueInWei = amount;
    }
    NSString* to = [NSString stringWithUTF8String:(char*)root["ETH"]["to"].asCString()];
    NSString* data = [NSString stringWithUTF8String:(char*)root["ETH"]["data"].asCString()];
    
    NSString* raw = [g_sdk JUB_SignTransactionETH:contextID
                                             path:path
                                            nonce:nonce
                                         gasLimit:gasLimit
                                    gasPriceInWei:gasPriceInWei
                                               to:to
                                       valueInWei:valueInWei
                                            input:data];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionETH() OK.]"]];
    
    if (raw) {
        size_t txLen = [raw length]/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %@.", txLen, raw]];
    }
    
    return rv;
}


//ERC-20 Test
- (NSUInteger) transactionERC20_proc:(NSUInteger)contextID
                              amount:(NSString*)amount
                                root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    NSString* tokenName = [NSString stringWithUTF8String:(char*)root["ERC20"]["tokenName"].asCString()];
    NSUInteger unitDP = root["ERC20"]["dp"].asUInt();
    NSString* contractAddress = [NSString stringWithUTF8String:(char*)root["ERC20"]["contract_address"].asCString()];
    NSString* to = [NSString stringWithUTF8String:(char*)root["ERC20"]["contract_address"].asCString()];
    NSString* token_to = [NSString stringWithUTF8String:(char*)root["ERC20"]["token_to"].asCString()];
    NSString* token_value = [NSString stringWithUTF8String:(char*)root["ERC20"]["token_value"].asCString()];
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        token_value = amount;
    }
    
    NSString* abi = [g_sdk JUB_BuildERC20AbiETH:contextID
                                      tokenName:tokenName
                                         unitDP:unitDP
                                contractAddress:contractAddress
                                        tokenTo:token_to
                                     tokenValue:token_value];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildERC20AbiETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildERC20AbiETH() OK.]"]];
    
    if (abi) {
        size_t abiLen = [abi length]/2;
        [self addMsgData:[NSString stringWithFormat:@"erc20 raw[%lu]: %@.", abiLen, abi]];
    }
    
    BIP32Path* path = [[BIP32Path alloc] init];
    path.change = (JUB_NS_ENUM_BOOL)root["ERC20"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["ERC20"]["bip32_path"]["addressIndex"].asUInt();
    NSUInteger nonce = root["ERC20"]["nonce"].asUInt();//.asDouble();
    NSUInteger gasLimit = root["ERC20"]["gasLimit"].asUInt();//.asDouble();
    NSString* gasPriceInWei = [NSString stringWithUTF8String:(char*)root["ERC20"]["gasPriceInWei"].asCString()];
    NSString* valueInWei = @""; //"" and "0" ara also OK
    NSString* raw = [g_sdk JUB_SignTransactionETH:contextID
                                             path:path
                                            nonce:nonce
                                         gasLimit:gasLimit
                                    gasPriceInWei:gasPriceInWei
                                               to:to
                                       valueInWei:valueInWei
                                            input:abi];
    rv = [g_sdk lastError];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionETH() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionETH() OK.]"]];
    
    if (raw) {
        size_t txLen = [raw length]/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %@.", txLen, raw]];
    }
    
    return rv;
}


@end
