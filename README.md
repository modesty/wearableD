# wearableD
A Swift project to enable wearable data transfer between iOS devices and Apple Watch.

This project provides capabilities of transferring token of sensitive data with iOS's proximity security, it integrates with [OAuth2
](http://oauth.net/2/), paired devices of [Bluetooth LE](http://en.wikipedia.org/wiki/Bluetooth_low_energy) for encrypted communication, 
and [iOS WatchKit](https://developer.apple.com/watchkit/) (work in progress...).

## Reusable Modules in Swift

Three main Swift modules/codes are developed with reusability: Bluetooth LE, including Central, Peripheral and chunked data tansferring;
OAuth2 client, including access token exchange with keychain cache and refreshing; and lastly, the common pattern of integrating OAuth2
protected RESTful APIs with custom headers and error handlings.

### Bluetooth LE Wrapper

Two main reusable Swift class, BLECentral and BLEPeripheral together with two main delegates: BLECentralDelegate and BLEPeripheralDelegate.

### EZ OAuth2 Client

Four Swift files underneath SimpleOAuth2 folder can be drag and drop to your Swift project if you need to integrate with OAuth2, the 
implementation follows the standard OAuth2 client spec, it's indented to work with any standard OAuth2 providers.

### Swift RESTful API Calls

Code examples of calling OAuth2 protected RESTful API with custom headers and error handling.

## WatchKit
(no code committed yet, work in progress...) 
  

