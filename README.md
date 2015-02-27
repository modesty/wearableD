# wearableD
A Swift project to enable wearable data transfer among iOS devices and Apple Watch.

This project provides capabilities of transferring token of sensitive data with iOS's proximity security, it integrates with [OAuth2
](http://oauth.net/2/), paired devices of [Bluetooth LE](http://en.wikipedia.org/wiki/Bluetooth_low_energy) for encrypted communication, 
and [iOS WatchKit](https://developer.apple.com/watchkit/) (work in progress...).

## What we're building

The use case we're covering is to enable sensitive data transfering between 'requester' and 'sharer' by short token via Bluetooth LE on iOS devices.
The 'data requester' can initiate a request by tapping on 'request a document' button, a 'data sharer' within Bluetooth proximity can start sharing
by tapping on 'share a document' button. The document provider will ask 'data sharer' to login with OAuth2, after authentication and consent, 
the 'data sharer' gets an OAuth2 access token, if the sharer's [peripheral] (https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html)
detects the requester's [central](https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html)
advertising, bluetooth will connect, after paired, the access token will be sent to central. After central side receives the token, it can make 
data provider's API calls on behave of the user to grab the requested document, essentially transferring a document from sharer to requester without
actually sending the document but with a token.

The request can be initiated from Apple Watch, notifications on sharing and transfering status can also be helpful on Apple Watch. 
(WatchKit work is in progress...).

The goal for this project is to provide reusable Swift components: Bluetooth LE central and peripheral for chunk-ed data transferring,
 a generic Swift OAuth2 Client and code examples for integrating with RESTful services without 3rd party dependencies.

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
  

