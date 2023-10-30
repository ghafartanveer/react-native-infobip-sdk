#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(AwesomeModule, NSObject)

RCT_EXTERN_METHOD(call)

// TODO: Copied from PlivoSdkManager
RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(add:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(login:(nonnull NSString *)userName
                  password:(nonnull NSString *)password
                  token:(nonnull NSString *)token
                  certificateId:(nonnull NSString *)certificateId
                  )
RCT_EXTERN_METHOD(reconnect)
RCT_EXTERN_METHOD(logout)

RCT_EXTERN_METHOD(call:(nonnull NSString *)dest
                    headers:(NSDictionary *)headers
                  )

RCT_EXTERN_METHOD(mute)
RCT_EXTERN_METHOD(unmute)
RCT_EXTERN_METHOD(hangup)
RCT_EXTERN_METHOD(reject)
RCT_EXTERN_METHOD(answer)

RCT_EXTERN_METHOD(setAudioDevice:(NSInteger *)device)


// TODO: Copied from TelnyxSdkManager
RCT_EXTERN_METHOD(configureAudioSession)
RCT_EXTERN_METHOD(startAudioDevice)
RCT_EXTERN_METHOD(stopAudioDevice)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
