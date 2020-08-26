# HyperPaySDKDemo-iOS
> Demo on iOS for JuBitSDK, supports for NFC and bluetooth(not finished yet) devices.

> Depends on:
> - jsoncpp([1.8.4](https://github.com/open-source-parsers/jsoncpp.git))
> - HyperPay-Jub_SDK_CXX
([dev_g2 branch](https://github.com/FT-JubiterWallet/HyperPay-Jub_SDK_CXX.git))


## submodule
```bash
cd deps
git submodule add           https://github.com/open-source-parsers/jsoncpp.git jsoncpp
git submodule add -b dev_g2 https://github.com/FT-JubiterWallet/HyperPay-Jub_SDK_CXX.git HyperPaySDK
```

```bash
cd deps/jsoncpp
git checkout 1.8.4
```


## init & update submodule
```bash
git submodule update --init --recursive
```


## HyperPaySDKDemo
>  However, supports for bluetooth devices is not complete yet.

Using 'JuBiterSDKDemo.xcworkspace' to build.
