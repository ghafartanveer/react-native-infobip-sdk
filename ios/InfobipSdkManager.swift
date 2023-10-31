import React
import Foundation
import InfobipRTC

// TODO: Replace with InfoBip
// protocol TelnyxEventHandling: AnyObject {
//     // Login
//     func onLogin()
//     func onLoginFailed()
//     func onLogout()
//     func onLoginFailedWithError(_ error: Error!)
//     // Outgoing call
//     func onCalling(_ data: [String: Any])
//     func onOutgoingCallRejected(_ data: [String: Any])
//     func onOutgoingCallInvalid(_ data: [String: Any])
//     func onOutgoingCallRinging(_ data: [String: Any])
//     func onOutgoingCallHangup(_ data: [String: Any])
//     func onOutgoingCallAnswered(_ data: [String: Any])
//     // Incoming call
//     func onIncomingCall(_ data: [String: Any])
//     func onIncomingCallHangup(_ data: [String: Any])
//     func onIncomingCallAnswered(_ data: [String: Any])
//     func onIncomingCallInvalid(_ data: [String: Any])
//     func onIncomingCallRejected(_ data: [String: Any])
// }

@objc(InfobipSdkManager)

final class InfobipSdkManager {
var infobipRTC: InfobipRTC {
            get {
                return getInfobipRTCInstance()
            }
        }

    var incomingWebrtcCall: IncomingWebrtcCall?
    

    @objc func call() {
        APIManager.obtainToken(parameters: ["identity": "Alice"]) { APIResponse in
            switch APIResponse {
            case .Success(let identity):
                let callPhoneRequest = CallPhoneRequest(token, destination: "41793026727", phoneCallEventListener: self)
                    let phoneCallOptions = PhoneCallOptions(from: "33755531044")
                    let phoneCall = try? self.infobipRTC.callPhone(callPhoneRequest, phoneCallOptions)
            case .Failure(let error):
                print("error: \(error)")
            }
    }

     @objc func handleIncomingCall(payload: PKPushPayload) {
        if self.infobipRTC.isIncomingCall(payload) {
            infobipRTC.handleIncomingCall(payload, self)
        }
    }

    @objc func acceptCall() {
        if let incomingCall = self.incomingWebrtcCall {
            incomingCall.accept()
        }
    }
    
    @objc func declineCall() {
        if let incomingCall = self.incomingWebrtcCall {
            incomingCall.decline()
        }
    }
    
    @objc func muteCall() {
        if let incomingCall = self.incomingWebrtcCall {
            do {
                try incomingCall.mute(true)
            } catch _ {
                
            }
        }
    }
    
    @objc func unMuteCall() {
        if let incomingCall = self.incomingWebrtcCall {
            do {
                try incomingCall.mute(false)
            } catch _ {
                
            }
        }
    }
    
    @objc func hangupCall() {
        if let incomingCall = self.incomingWebrtcCall {
            incomingCall.hangup()
        }
    }

    func isDebug() -> Bool {
    #if DEBUG
            return true
    #else
            return false
    #endif
        }

}

extension InfobipSdkManager: WebrtcCallEventListener {
    func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {
        
    }
    
    func onRinging(_ callRingingEvent: CallRingingEvent) {
       print("on ringing")
    }
    
    func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
        
    }
    
    func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
        
    }
    
    func onCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
    }
    
    func onCameraVideoUpdated(_ cameraVideoUpdatedEvent: CameraVideoUpdatedEvent) {
        
    }
    
    func onCameraVideoRemoved() {
        
    }
    
    func onScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
    }
    
    func onScreenShareRemoved() {
        
    }
    
    func onRemoteCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
    }
    
    func onRemoteCameraVideoRemoved() {
        
    }
    
    func onRemoteScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
    }
    
    func onRemoteScreenShareRemoved() {
        
    }
    
    func onRemoteMuted() {
        
    }
    
    func onRemoteUnmuted() {
        
    }
    
    func onHangup(_ callHangupEvent: CallHangupEvent) {
        
    }
    
    func onError(_ errorEvent: ErrorEvent) {
        
    }
}

extension InfobipSdkManager: IncomingCallEventListener {   
        
    func onIncomingWebrtcCall(_ incomingWebrtcCallEvent: IncomingWebrtcCallEvent) {
        self.incomingWebrtcCall = incomingWebrtcCallEvent.incomingWebrtcCall
        self.incomingWebrtcCall!.webrtcCallEventListener = WebrtcCallListener(self.incomingWebrtcCall!)
    }
    
}

class WebrtcCallListener:  WebrtcCallEventListener{
    func onCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
    }
    
    func onCameraVideoUpdated(_ cameraVideoUpdatedEvent: CameraVideoUpdatedEvent) {
        
    }
    
    func onCameraVideoRemoved() {
        
    }
    
    func onScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
    }
    
    func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {
        
    }
    
    func onRemoteCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
    }
    
    func onRemoteCameraVideoRemoved() {
        
    }
    
    func onRemoteScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
    }
    
    func onRemoteScreenShareRemoved() {
        
    }
    
    func onRemoteMuted() {
        
    }
    
    func onRemoteUnmuted() {
        
    }
    
    func onRinging(_ callRingingEvent: CallRingingEvent) {
        
    }
    
    func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
        
    }
    
    func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
        
    }
    
    func onHangup(_ callHangupEvent: CallHangupEvent) {
        
    }
    
    func onError(_ errorEvent: ErrorEvent) {
        
    }
    
    let webrtcCall : WebrtcCall
    
    init(_ webrtcCall: WebrtcCall) {
        self.webrtcCall = webrtcCall
    }
}

// // final class PlivoSdkManager: RCTEventEmitter, PlivoSdkDelegate {
// final class TelnyxSdkManager: RCTEventEmitter, TelnyxEventHandling {
// // TODO: Update InfobipSdkManager class...
// // final class InfobipSdkManager: NSObject {

//   private let shared = TelnyxSdk.shared
//     private let audioDeviceManager = AudioDeviceManager()

//     private var hasListeners : Bool = false

//     override init() {
//         super.init()

//         TelnyxSdk.shared.delegate = self
//         audioDeviceManager.delegate = self
//     }

//     override static func requiresMainQueueSetup() -> Bool {
//         return true
//     }

//   // @objc(multiply:withB:withResolver:withRejecter:)
//   // func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
//   //   resolve(a*b)
//   // }

// // TODO: Not sure what the '!' means here...
// // override func supportedEvents() -> [String]! {
//     override func supportedEvents() -> [String] {
//       // TODO: Replace with InfoBip
//         return [
//             "Telnyx-onLogin",
//             "Telnyx-onLoginFailed",
//             "Telnyx-onLogout",
//             "Telnyx-onIncomingCall",
//             "Telnyx-onIncomingCallHangup",
//             "Telnyx-onIncomingCallRejected",
//             "Telnyx-onIncomingCallAnswered",
//             "Telnyx-onIncomingCallInvalid",
//             "Telnyx-onOutgoingCall",
//             "Telnyx-onOutgoingCallAnswered",
//             "Telnyx-onOutgoingCallRinging",
//             "Telnyx-onOutgoingCallRejected",
//             "Telnyx-onOutgoingCallHangup",
//             "Telnyx-onOutgoingCallInvalid",
//             "Telnyx-headphonesStateChanged"
//         ]
//     }

//     override func startObserving() {
//         print("TelnyxSdk ReactNativeEventEmitter startObserving")

//         hasListeners = true

//         super.startObserving()
//     }


//     override func stopObserving() {
//         print("TelnyxSdk ReactNativeEventEmitter stopObserving")

//         hasListeners = false

//         super.stopObserving()
//     }

//     @objc(login:password:token:)

//     @objc static func relayVoipPushNotification(_ pushInfo: [AnyHashable : Any]) {
//         PlivoSdk.shared.relayVoipPushNotification(pushInfo: pushInfo)
//     }

//     @objc(login:password:token:certificateId:)

//     func login(
//         withUserName userName: String,
//         andPassword password: String,
//         deviceToken token: String,
//         certificateId: String
//         )
//         -> Void {
//             PlivoSdk.shared.login(withUserName: userName,
//                                   andPassword: password,
//                                   deviceToken: token,
//                                   certificateId: certificateId)
//     }

//     func callNew() {
//         let infobipRTC: InfobipRTC = getInfobipRTCInstance()
        
//     }

    


//     @objc static func processVoIPNotification(_ callId: String, pushMetaData: [String: Any]) {
//         TelnyxSdk.shared.processVoIPNotification(callId: callId, pushMetaData: pushMetaData)
//     }

//     @objc static func cancelAllCalls() {
//         TelnyxSdk.shared.hangup()
//     }

//     // @objc(call:headers:)
//     // func call(withDest dest: String, andHeaders headers: [AnyHashable: Any]) -> PlivoOutgoing? {
//     //     return shared.call(withDest: dest, andHeaders: headers)
//     // }

//      @objc func reconnect() {
//         shared.reconnect()
//     }

//     @objc func logout() {
//         shared.logout()
//     }

//     @objc func mute() {
//         shared.mute()
//     }

//     @objc func unmute() {
//         shared.unmute()
//     }

//     @objc func answer() {
//         shared.answer()
//     }

//     @objc func hangup() {
//         shared.hangup()
//     }

//     @objc func reject() {
//         shared.reject()
//     }

//     @objc func setAudioDevice(_ device: Int) {
//         audioDeviceManager.setAudioDevice(type: device)
//     }

//     func onLogin() {
//         sendEvent(withName: "Plivo-onLogin", body:nil);
//     }

//     func onLoginFailed() {
//         sendEvent(withName: "Plivo-onLoginFailed", body:nil);
//     }

//     func onLogout() {
//         sendEvent(withName: "Plivo-onLogout", body:nil);
//     }

//     // func onLoginFailedWithError(_ error: Error!) {
//     //     let body = ["error": error.localizedDescription]
//     //     sendEvent(withName: "Telnyx-onLoginFailed", body: body);
//     // }

//     func onLoginFailedWithError(_ error: Error!) {
//         sendEvent(withName: "Plivo-onLoginFailed", body:nil);
//     }

//     func onCalling(_ data: [String: Any]) {
//         audioDeviceManager.isBluetoothDeviceConnected()
//         sendEvent(withName: "Plivo-onOutgoingCall", body: data);
//     }

//     func onOutgoingCallRejected(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onOutgoingCallRejected", body: data);
//     }

//     func onOutgoingCallInvalid(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onOutgoingCallInvalid", body: data);
//     }

//     func onOutgoingCallRinging(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onOutgoingCallRinging", body: data);
//     }

//     func onOutgoingCallHangup(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onOutgoingCallHangup", body: data);
//     }

//     func onOutgoingCallAnswered(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onOutgoingCallAnswered", body: data);
//     }

//     func onIncomingCall(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onIncomingCall", body: data);
//     }

//     func onIncomingCallHangup(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onIncomingCallHangup", body: data);
//     }

//     func onIncomingCallAnswered(_ data: [String: Any]) {
//         audioDeviceManager.isBluetoothDeviceConnected()
//         sendEvent(withName: "Plivo-onIncomingCallAnswered", body: data);
//     }

//     func onIncomingCallInvalid(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onIncomingCallInvalid", body: data);
//     }

//     func onIncomingCallRejected(_ data: [String: Any]) {
//         sendEvent(withName: "Plivo-onIncomingCallRejected", body: data);
//     }
// }

// extension PlivoSdkManager: AudioDeviceManagerDelegate {
//     func didChangeHeadphonesState(connected: Bool) {
//         sendEvent(withName: "Plivo-headphonesStateChanged", body: ["connected": connected])
//     }
// }

