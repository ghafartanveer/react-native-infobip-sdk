import React
import PushKit
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
// 10EA4686-9CDF-4E58-8F7F-D599A023482C
// }

@objc(InfobipSdkManager)

final class InfobipSdkManager: RCTEventEmitter, PhoneCallEventListener{
    
    
    
    
    
    var identity: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    static var pushCredentials: PKPushCredentials?
    
    var infobipRTC: InfobipRTC {
        get {
            return getInfobipRTCInstance()
        }
    }
    
    private let audioDeviceManager = AudioDeviceManager()
    
    private var hasListeners : Bool = false
    var incomingWebrtcCall: IncomingWebrtcCall?
//    var outgoingCall: PhoneCall?
    var outgoingCall: ApplicationCall?
    
    
    @objc static func shared() -> InfobipSdkManager {
        return InfobipSdkManager()
    }
    
    override func supportedEvents() -> [String] {
        return [
            "onLogin",
            "onLoginFailed",
            "onLogout",
            "onIncomingCall",
            "onIncomingCallHangup",
            "onIncomingCallRejected",
            "onIncomingCallAnswered",
            "onIncomingCallInvalid",
            "onOutgoingCall",
            "onOutgoingCallAnswered",
            "onOutgoingCallRinging",
            "onOutgoingCallRejected",
            "onOutgoingCallHangup",
            "onOutgoingCallInvalid",
            "headphonesStateChanged"
        ]
    }
    
    override func startObserving() {
        print("InfobipSdk ReactNativeEventEmitter startObserving")
        
        hasListeners = true
        
        super.startObserving()
    }
    
    override func stopObserving() {
        print("InfobipSdk ReactNativeEventEmitter stopObserving")
        
        hasListeners = false
        
        super.stopObserving()
    }
    //    1EF75BA5-C229-4B96-9730-28DBECFFBF72
    
    @objc func call(_ apiKey: String, token: String, identity: String, contactId: String, destination: String, caller: String) {
        print("contactId: \(contactId)")
        //        print("identity: \(identity)")
//        print("push identity: \(self.identity)")
//        print("destination: \(destination)")
//        print("caller: \(caller)")
        
        
        // Old method...
        //        let callPhoneRequest = CallPhoneRequest(token, destination: destination, phoneCallEventListener: self)
        
        let callApplicationRequest = CallApplicationRequest(token, applicationId: "staging", applicationCallEventListener: self)//CallApplicationRequest(token, applicationId: "staging", phoneCallEventListener: self)
        
        // Old method...
        //        let phoneCallOptions = PhoneCallOptions(from: caller)
        
        let customData = ["contactId": contactId, "fromNumber": caller, "toNumber": destination]
        let applicationCallOptions = ApplicationCallOptions(audio: true, customData: customData, entityId: identity)
        
        
//        do {
            // Old method...
//            self.outgoingCall = try self.infobipRTC.callPhone(callApplicationRequest, applicationCallOptions)
            
            // New method...
//            self.outgoingCall = try self.infobipRTC.callApplication(callApplicationRequest, applicationCallOptions)
//        } catch let ex {
//            print(ex.localizedDescription)
//        }
    }
    
    @objc func handleIncomingCall(payload: PKPushPayload) {
        if self.infobipRTC.isIncomingCall(payload) {
            infobipRTC.handleIncomingCall(payload, self)
        }
    }
    
    @objc func answer() {
        if let incomingCall = self.incomingWebrtcCall {
            incomingCall.accept()
        }
    }
    
    @objc func reject() {
        if let incomingCall = self.incomingWebrtcCall {
            incomingCall.decline()
        }
    }
    
    @objc func mute() {
        if let incomingCall = self.incomingWebrtcCall {
            do {
                try incomingCall.mute(true)
            } catch _ {
                
            }
        } else if let outgoingCall = self.outgoingCall {
            do {
                try outgoingCall.mute(true)
            } catch _ {
                
            }
        }
    }
    
    @objc func unmute() {
        if let incomingCall = self.incomingWebrtcCall {
            do {
                try incomingCall.mute(false)
            } catch _ {
                
            }
        } else if let outgoingCall = self.outgoingCall {
            do {
                try outgoingCall.mute(false)
            } catch _ {
                
            }
        }
    }
    
    @objc func hangup() {
        print("hangup called...")
        if let incomingCall = self.incomingWebrtcCall {
            incomingCall.hangup()
        } else if let outgoingCall = self.outgoingCall {
            outgoingCall.hangup()
        }
    }
    
    //        @objc func registerPushNotification(_ apiKey: String, deviceToken: String, identity: String) {
    //            print("registerPushNotification called...")
    //            APIManager.obtainToken(apiKey: apiKey, parameters: ["identity": "\(identity)"]) { APIResponse in
    //                    switch APIResponse {
    //                    case .Success(let identity):
    //                        if let token = identity?.token {
    //                            let debug = self.isDebug()
    //                            self.infobipRTC.enablePushNotification(token, deviceToken: deviceToken, debug: true, pushConfigId: UUID().uuidString)
    //                        }
    //                    case .Failure(let error):
    //                        print("error: \(error)")
    //                    }
    //                }
    //            }
    
    //    @objc func enablePushNotification(_ apiKey: String, token: String, pushCredentials: PKPushCredentials, pushConfigId: String) {
    
    // commented just to store the pk credentials in the veriable in the same new method
    @objc func registerPushNotification(_ token: String, pushConfigId: String) {
        if let credentials = InfobipSdkManager.pushCredentials{
            //            let configId = "768d1685-cde7-4a8e-b22d-317e9a9faff9"
            print("push identity: \(self.identity)")
            let debug = true//self.isDebug()
            //                    self.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: debug, pushConfigId: configId)
            self.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: debug, pushConfigId: pushConfigId) { result in
                print("enablePushNotification result : \(result.status)")
                print("enablePushNotification result : \(result.message)")
                
            }
        }else{
            print("pushCredentials are null")
        }
        
    }
    @objc func registerPushCredentials(_ credentials: PKPushCredentials) {
        InfobipSdkManager.pushCredentials = credentials
        //        let configId = "768d1685-cde7-4a8e-b22d-317e9a9faff9"
        //        print("push identity: \(self.identity)")
        //        let debug = true//self.isDebug()
        ////                    self.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: debug, pushConfigId: configId)
        //                    self.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: debug, pushConfigId: configId) { result in
        //                        print("enablePushNotification result : \(result.status)")
        //                        print("enablePushNotification result : \(result.message)")
        //
        //                    }
    }
    
    @objc func isDebug() -> Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
}



extension InfobipSdkManager: WebrtcCallEventListener, ApplicationCallEventListener {
    func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {
        
    }
    func onConferenceJoined(_ conferenceJoinedEvent: ConferenceJoinedEvent) {
        print("event triggered: ", conferenceJoinedEvent)
    }
    
    func onConferenceLeft(_ conferenceLeftEvent: ConferenceLeftEvent) {
        print("conferenceLeftEvent triggered: ", conferenceLeftEvent)
    }
    
    func onParticipantJoining(_ participantJoiningEvent: ParticipantJoiningEvent) {
        print("participantJoiningEvent triggered: ", participantJoiningEvent)
    }
    
    func onParticipantJoined(_ participantJoinedEvent: ParticipantJoinedEvent) {
        print("participantJoinedEvent triggered: ", participantJoinedEvent)
    }
    
    func onParticipantLeft(_ participantLeftEvent: ParticipantLeftEvent) {
        print("participantLeftEvent triggered: ", participantLeftEvent)
    }
    
    func onParticipantCameraVideoAdded(_ participantCameraVideoAddedEvent: ParticipantCameraVideoAddedEvent) {
        print("participantCameraVideoAddedEvent triggered: ", participantCameraVideoAddedEvent)
    }
    
    func onParticipantCameraVideoRemoved(_ participantCameraVideoRemovedEvent: ParticipantCameraVideoRemovedEvent) {
        print("participantCameraVideoRemovedEvent triggered: ", participantCameraVideoRemovedEvent)
    }
    
    func onParticipantScreenShareAdded(_ participantScreenShareAddedEvent: ParticipantScreenShareAddedEvent) {
        print("participantScreenShareAddedEvent triggered: ", participantScreenShareAddedEvent)
    }
    
    func onParticipantScreenShareRemoved(_ participantScreenShareRemovedEvent: ParticipantScreenShareRemovedEvent) {
        print("participantScreenShareRemovedEvent triggered: ", participantScreenShareRemovedEvent)
    }
    
    func onParticipantMuted(_ participantMutedEvent: ParticipantMutedEvent) {
        print("participantMutedEvent triggered: ", participantMutedEvent)
    }
    
    func onParticipantUnmuted(_ participantUnmutedEvent: ParticipantUnmutedEvent) {
        print("participantUnmutedEvent triggered: ", participantUnmutedEvent)
    }
    
    func onParticipantDeaf(_ participantDeafEvent: ParticipantDeafEvent) {
        print("participantDeafEvent triggered: ", participantDeafEvent)
    }
    
    func onParticipantUndeaf(_ participantUndeafEvent: ParticipantUndeafEvent) {
        print("participantUndeafEvent triggered: ", participantUndeafEvent)
    }
    
    func onParticipantStartedTalking(_ participantStartedTalkingEvent: ParticipantStartedTalkingEvent) {
        print("participantStartedTalkingEvent triggered: ", participantStartedTalkingEvent)
    }
    
    func onParticipantStoppedTalking(_ participantStoppedTalkingEvent: ParticipantStoppedTalkingEvent) {
        print("participantStoppedTalkingEvent triggered: ", participantStoppedTalkingEvent)
    }
    
    func onDialogJoined(_ dialogJoinedEvent: DialogJoinedEvent) {
        print("dialogJoinedEvent triggered: ", dialogJoinedEvent)
    }
    
    func onDialogLeft(_ dialogLeftEvent: DialogLeftEvent) {
        print("dialogLeftEvent triggered: ", dialogLeftEvent)
    }
    
    func onReconnecting(_ callReconnectingEvent: CallReconnectingEvent) {
        print("callReconnectingEvent triggered: ", callReconnectingEvent)
    }
    
    func onReconnected(_ callReconnectedEvent: CallReconnectedEvent) {
        print("callReconnectedEvent triggered: ", callReconnectedEvent)
    }
    
    func onRinging(_ callRingingEvent: CallRingingEvent) {
        print("on ringing outgoing")
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
        print("hangup CallHangupEvent called...")
        // RCTEventEmitter().sendEvent(withName: "onOutgoingCallHangup", body: "")
        sendEvent(withName: "onOutgoingCallHangup", body: "")
        //        sendEvent(withName: "Infobip-onOutgoingCallHangup", body: data)
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
        print("on ringing")
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

