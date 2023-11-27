#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>
#import <PushKit/PushKit.h>

@interface InfobipSdkManager : RCTEventEmitter <RCTBridgeModule>

+ (void)handleIncomingCall:(PKPushPayload *)pushInfo completion:(void (^)(void))completion;
+ (void)setPushPayload:(PKPushPayload *)pushInfo;
+ (void)registerPushCredentials:(PKPushCredentials *)credentials;
+ (BOOL)checkIfLoggedIn;

@end
