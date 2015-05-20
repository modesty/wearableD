# wearableD
A Swift project that enables data transfer between iOS devices and Apple Watch via Bluetooth LE.

This project provides capabilities of putting iOS devices into discoverable (Bluetooth LE Peripheral) and discovery (Bluetooth LE Central) mode, transferring data between devices and Apple Watch with iOS's proximity security. The actual use case is to use peripheral mode to initiate OAuth flow and sending OAuth2 access token via bluetooth LE, while utilizing central mode to  discover, connect and receive data from nearby periperal device, also using the token making API calls on behave of periperal. 

In general, this project allows different users of the same app to shairing (authenticate and consent via OAuth2) and receving  data via BLuetooth, and using access token to get data by calling REST APIs. Either shairing or receiving action can be initiated from Apple Watch.

It integrates with [OAuth2](http://oauth.net/2/), can navigate to different modes [Bluetooth LE](http://en.wikipedia.org/wiki/Bluetooth_low_energy) with encrypted communication, has chunked data trasnferring between iOS devices via Bluetooth LE, making secure REST API calls with OAuth2 access token, showing resulting PDF and have Apple Watch extension app [iOS WatchKit](https://developer.apple.com/watchkit/) for initiating action and receving notifications.

## What we're building

The use case we're covering is to enable sensitive data transfering between 'requester' and 'sharer' by OAuth2 access token via Bluetooth LE on iOS devices.
The data 'requester' can initiate a request by tapping on 'request a document' button, the app will enter to "central" mode snd waiting for connection; At the same time, a data 'sharer' within Bluetooth proximity can start sharing
by tapping on 'share a document' button, the app enters into "periperal" mode and initiates OAuth2 login and consent flow. 

In peripheral mode, the identity/data provider asks the 'sharer' to login with their credentials, then consent with data sharing,   
the data 'sharer' gets an OAuth2 access token. If the sharer's [peripheral] (https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html)
detects the requester's [central](https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html)
advertising, bluetooth LE will connect, the access token will be sent to central in chunks. 

After central side receives the data chunks, it reconstruct the access token, then calling 
identity/data provider's REST API on behave of the user ('sharer') to retrieve the requested document, then show the PDF content. 

Essentially, this data excahnge is transferring sensitive and protected data from sharer to requester without
actually sending the document bits but with a access token.

The request/sharing can be initiated from Apple Watch, notifications on data sharing can also be helpful on Apple Watch. 

The goal for this project is to provide reusable Swift components: 

* Bluetooth LE central and peripheral wrapper classes for advertising, discovering and connecting with chunked data transferring
* A generic Swift OAuth2 Client Framework 
* Code examples for integrating with RESTful services with OAuth2 bearer token
* Apple Watch initiated action that result in parent application responses
* Swift code animation for waiting and loading

## Reusable Modules in Swift

Three main Swift modules/codes are developed with reusability: Bluetooth LE, including Central, Peripheral and chunked data tansferring; OAuth2 client framework, including access token exchange with keychain cache and refreshing; and lastly, the common pattern of integrating OAuth2 protected RESTful APIs with custom headers and error handlings.

### Bluetooth LE Wrapper

Two main reusable Swift class, BLECentral and BLEPeripheral together with two main delegates: BLECentralDelegate and BLEPeripheralDelegate.

### SimpleOAuth2 Client Framework

This project includes a reusable Swift Framework target for generic OAuth2 consent flow integration.

Four Swift files underneath SimpleOAuth2 folder can be drag and drop to your Swift project if you need to integrate with OAuth2, the implementation follows the standard OAuth2 client spec, it's indented to work with any standard OAuth2 providers.

### Swift RESTful API Calls

Code examples of calling OAuth2 protected RESTful API with custom headers and error handling.

## WatchKit

Similar to the home view controller in iPhone app, the watch app has "Request a Doc" and "Share a Doc" buttons. Tap on the button, the watch app will communicate with parent application, not only launch the iPhone app, but also auto-navigate to different ViewController: either central or peripheral. Then OAuth2 flows on iPhone app in Peripheral mode for sharing, while Bluetoothe LE starts advertisting and waiting to connect in Central mode. 
  

