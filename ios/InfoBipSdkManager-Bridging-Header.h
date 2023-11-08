#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>
#import <PushKit/PushKit.h>

@interface InfobipSdkManager : RCTEventEmitter <RCTBridgeModule>

//TODO: Need to identify where these methods are defined...
//TODO: These methods will be used to initialize the SDK...

// @interface PlivoSdkManager : RCTEventEmitter <RCTBridgeModule>
// + (void)loginWithUsername:(NSString *)username
//                  password:(NSString *)password
//               deviceToken:(NSString *)deviceToken
//             certificateId:(NSString *)certificateId;

// + (void)relayVoipPushNotification:(NSDictionary *)pushInfo;
- (void)handleIncomingCall:(NSDictionary *)pushInfo;
- (void)registerPushNotification:(PKPushCredentials *)credentials;
//+ (InfobipSdkManager *)shared;
@property (class, retain) InfobipSdkManager *shared;



// @interface TelnyxSdkManager : RCTEventEmitter <RCTBridgeModule>
// + (void)processVoIPNotification:(NSString *)callId
//                    pushMetaData:(NSDictionary *)pushMetaData;
// + (void)cancelAllCalls;
@end
