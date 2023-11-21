import React
import AVFAudio
import PushKit
import Foundation
import InfobipRTC

typealias IncomingCompletion = ()->Void

@objc(InfobipSdkManager)

final class InfobipSdkManager: RCTEventEmitter, PhoneCallEventListener, IncomingApplicationCallEventListener{

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func convertIncomingCallToObject(_ payload: PKPushPayload!) -> [String: Any] {
        let objCall = payload.dictionaryPayload
        
        
        let callId = objCall["callId"] as? String;
        let callerName = objCall["displayName"] as? String;
        let callerPhone = objCall["source"] as? String;
        let customDataString = objCall["customData"] as? String ?? "";
        
        let customData = convertToDictionary(text: customDataString)
        let contactId = customData?["contactId"] as? String ?? ""
        
        
        let body: [String: Any] = [
            "callId": callId ?? "",
            "callerPhone": callerPhone ?? "",
            "callerName": callerName ?? "",
            "callerId": contactId ,
        ];
        
        return body;
    }
    
    var identity: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    static var pushCredentials: PKPushCredentials?
    static var incomingPayload: PKPushPayload?
    var incomingCompletion: IncomingCompletion?
    
    var infobipRTC: InfobipRTC {
        get {
            return getInfobipRTCInstance()
        }
    }
    
     let audioDeviceManager = AudioDeviceManager()
    
    override init() {
        super.init()
        audioDeviceManager.delegate = self
        InfobipSdkManager.shared = self
    }
    
    
    private var hasListeners : Bool = false
    var outgoingCall: ApplicationCall?
    var incomingApplicationCall: IncomingApplicationCall?
    
    static var shared: InfobipSdkManager?
    
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
    
    @objc func call(_ apiKey: String, token: String, environment: String, identity: String, contactId: String, destination: String, caller: String) {
//        AVAudioSession.sharedInstance().requestRecordPermission { granted in
//            if(granted){
                let callApplicationRequest = CallApplicationRequest(token, applicationId: environment, applicationCallEventListener: InfobipSdkManager.shared!)
                
                let customData = ["contactId": contactId, "fromNumber": caller, "toNumber": destination]
                let applicationCallOptions = ApplicationCallOptions(audio: true, customData: customData, entityId: identity)
                
                do {
                    InfobipSdkManager.shared!.outgoingCall = try InfobipSdkManager.shared!.infobipRTC.callApplication(callApplicationRequest, applicationCallOptions)
                } catch let ex {
                    print("outgoingCall (error) ===> ", ex.localizedDescription);
                }
//            }else{
//                print("Microphone permission not granted")
//                InfobipSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
//            }
//        }
    }
    
    @objc func handleIncomingCallFromCallKeep() {
        let payload = InfobipSdkManager.incomingPayload
        if InfobipSdkManager.shared!.infobipRTC.isIncomingApplicationCall(payload!) {

            InfobipSdkManager.incomingPayload = payload
            InfobipSdkManager.shared?.infobipRTC.handleIncomingApplicationCall(payload!, InfobipSdkManager.shared!)
        }
    }
    @objc static func setPushPayload(_ payload: PKPushPayload) {
        InfobipSdkManager.incomingPayload = payload
    }
    @objc static func handleIncomingCall(_ payload: PKPushPayload, completion: @escaping IncomingCompletion) {
        shared?.incomingCompletion = completion
        if shared!.infobipRTC.isIncomingApplicationCall(payload) {

            InfobipSdkManager.incomingPayload = payload
            shared?.infobipRTC.handleIncomingApplicationCall(payload, shared!)
        }
    }
    
    @objc func answer() {
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            incomingCall.accept()
        }
    }
    
    @objc func reject() {
//        sendEvent(withName: "onIncomingCallRejected", body: data);
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            incomingCall.decline()
        }
    }
    
    @objc func mute() {
            if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            do {
                try incomingCall.mute(true)
            } catch _ {
                
            }
        } else if let outgoingCall = InfobipSdkManager.shared?.outgoingCall {
            do {
                try outgoingCall.mute(true)
            } catch _ {
                
            }
        }
    }
    
    @objc func unmute() {
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            do {
                try incomingCall.mute(false)
            } catch _ {
                
            }
        } else if let outgoingCall = InfobipSdkManager.shared?.outgoingCall {
            do {
                try outgoingCall.mute(false)
            } catch _ {
                
            }
        }
    }
    
    @objc func hangup() {
        print("hangup called...")
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            incomingCall.hangup()
        } else if let outgoingCall = InfobipSdkManager.shared?.outgoingCall {
            outgoingCall.hangup()
        }
    }
    
    @objc func setAudioDevice(_ device: Int) {
        InfobipSdkManager.shared?.audioDeviceManager.setAudioDevice(type: device)
    }

    @objc func registerPushNotification(_ token: String, pushConfigId: String, debug: String) {
        if let credentials = InfobipSdkManager.pushCredentials{
            InfobipSdkManager.shared?.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: debug == "1", pushConfigId: pushConfigId) { result in
                print("enablePushNotification result : \(result.status)")
                print("enablePushNotification result : \(result.message)")
                
            }
        }else{
            print("pushCredentials are null")
        }
        
    }
    @objc static func registerPushCredentials(_ credentials: PKPushCredentials) {
        InfobipSdkManager.pushCredentials = credentials
    }
    
    func onIncomingApplicationCall(_ incomingApplicationCallEvent: IncomingApplicationCallEvent) {
        let body = convertIncomingCallToObject(InfobipSdkManager.incomingPayload)
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCall", body: body);

        InfobipSdkManager.shared?.incomingApplicationCall = incomingApplicationCallEvent.incomingApplicationCall
        if let block = InfobipSdkManager.shared?.incomingCompletion {
            block()
        }
        InfobipSdkManager.shared?.incomingApplicationCall!.applicationCallEventListener = WebrtcCallListener(InfobipSdkManager.shared!.incomingApplicationCall!)
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
        print("callEarlyMediaEvent triggered ==> ", callEarlyMediaEvent)
        InfobipSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
        InfobipSdkManager.shared?.sendEvent(withName: "onOutgoingCallRinging", body: "");
    }
    
    func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
        InfobipSdkManager.shared?.sendEvent(withName: "onOutgoingCallAnswered", body: "");
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
        InfobipSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
    }
    
    func onError(_ errorEvent: ErrorEvent) {
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCallInvalid", body: "");
    }
}

extension InfobipSdkManager: IncomingCallEventListener {
    
    func onIncomingWebrtcCall(_ incomingWebrtcCallEvent: IncomingWebrtcCallEvent) {
//        self.incomingWebrtcCall = incomingWebrtcCallEvent.incomingWebrtcCall
//        self.incomingWebrtcCall!.webrtcCallEventListener = WebrtcCallListener(self.incomingWebrtcCall!)
    }
    
    
    
}

extension InfobipSdkManager: AudioDeviceManagerDelegate {
    func didChangeHeadphonesState(connected: Bool) {
        sendEvent(withName: "headphonesStateChanged", body: ["connected": connected])
    }
}

@objc(WebrtcCallListener)

class WebrtcCallListener: RCTEventEmitter, ApplicationCallEventListener{
    func onRinging(_ callRingingEvent: CallRingingEvent) {
        print("incoming call on ringing")
    }
    
    func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
        print("on call established...")
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCallAnswered", body: "");
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            InfobipSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
        }
    }
    
    func onHangup(_ callHangupEvent: CallHangupEvent) {
        print("incoming call hang up")
//        sendEvent(withName: "onIncomingCallHangup", body: "")
//        WebrtcCallListener.shared?.sendEvent(withName: "onIncomingCallHangup", body: "")
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCallHangup", body: "")
    }
    
    func onError(_ errorEvent: ErrorEvent) {
        print("on error (incoming...)");
    }
    
    func onConferenceJoined(_ conferenceJoinedEvent: ConferenceJoinedEvent) {
        print("on joined (incoming...)");
    }
    
    func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
        print("on EarlyMedia (incoming...)");
    }
    
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
    
    func onConferenceLeft(_ conferenceLeftEvent: ConferenceLeftEvent) {
        
    }
    
    func onParticipantJoining(_ participantJoiningEvent: ParticipantJoiningEvent) {
        
    }
    
    func onParticipantJoined(_ participantJoinedEvent: ParticipantJoinedEvent) {
        
    }
    
    func onParticipantLeft(_ participantLeftEvent: ParticipantLeftEvent) {
        
    }
    
    func onParticipantCameraVideoAdded(_ participantCameraVideoAddedEvent: ParticipantCameraVideoAddedEvent) {
        
    }
    
    func onParticipantCameraVideoRemoved(_ participantCameraVideoRemovedEvent: ParticipantCameraVideoRemovedEvent) {
        
    }
    
    func onParticipantScreenShareAdded(_ participantScreenShareAddedEvent: ParticipantScreenShareAddedEvent) {
        
    }
    
    func onParticipantScreenShareRemoved(_ participantScreenShareRemovedEvent: ParticipantScreenShareRemovedEvent) {
        
    }
    
    func onParticipantMuted(_ participantMutedEvent: ParticipantMutedEvent) {
        
    }
    
    func onParticipantUnmuted(_ participantUnmutedEvent: ParticipantUnmutedEvent) {
        
    }
    
    func onParticipantDeaf(_ participantDeafEvent: ParticipantDeafEvent) {
        
    }
    
    func onParticipantUndeaf(_ participantUndeafEvent: ParticipantUndeafEvent) {
        
    }
    
    func onParticipantStartedTalking(_ participantStartedTalkingEvent: ParticipantStartedTalkingEvent) {
        
    }
    
    func onParticipantStoppedTalking(_ participantStoppedTalkingEvent: ParticipantStoppedTalkingEvent) {
        
    }
    
    func onDialogJoined(_ dialogJoinedEvent: DialogJoinedEvent) {
        
    }
    
    func onDialogLeft(_ dialogLeftEvent: DialogLeftEvent) {
        
    }
    
    func onReconnecting(_ callReconnectingEvent: CallReconnectingEvent) {
        
    }
    
    func onReconnected(_ callReconnectedEvent: CallReconnectedEvent) {
        
    }
    
    let webrtcCall: IncomingApplicationCall
    
    static var shared: WebrtcCallListener?
    
    init(_ webrtcCall: IncomingApplicationCall) {
        self.webrtcCall = webrtcCall
        super.init()
        WebrtcCallListener.shared = self
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
    
    private var hasListeners : Bool = false
    
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
}
