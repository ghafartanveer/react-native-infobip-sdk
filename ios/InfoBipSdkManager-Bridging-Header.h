#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>

@interface InfoBipSdkManager : RCTEventEmitter <RCTBridgeModule>

//TODO: Need to identify where these methods are defined...
//TODO: These methods will be used to initialize the SDK...

// @interface PlivoSdkManager : RCTEventEmitter <RCTBridgeModule>
+ (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
              deviceToken:(NSString *)deviceToken
            certificateId:(NSString *)certificateId;

+ (void)relayVoipPushNotification:(NSDictionary *)pushInfo;

// @interface TelnyxSdkManager : RCTEventEmitter <RCTBridgeModule>
+ (void)processVoIPNotification:(NSString *)callId
                   pushMetaData:(NSDictionary *)pushMetaData;
+ (void)cancelAllCalls;
@end
