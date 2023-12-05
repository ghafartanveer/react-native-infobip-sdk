import React
import AVFAudio
import PushKit
import Foundation
import InfobipRTC

typealias IncomingCompletion = ()->Void

@objc(InfobipSdkManager)

final class InfobipSdkManager: RCTEventEmitter, PhoneCallEventListener, IncomingApplicationCallEventListener{
    
    var identity: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    static var pushCredentials: PKPushCredentials?
    static var isUserLoggedIn: Bool = false
    static var incomingPayload: PKPushPayload?
    var incomingCompletion: IncomingCompletion?
    var infobipRTC: InfobipRTC {
        get {
            return getInfobipRTCInstance()
        }
    }
    let audioDeviceManager = AudioDeviceManager()
    private var hasListeners : Bool = false
    var outgoingCall: ApplicationCall?
    var incomingApplicationCall: IncomingApplicationCall?
    
    static var shared: InfobipSdkManager?
    
    override init() {
        super.init()
        audioDeviceManager.delegate = self
        InfobipSdkManager.shared = self
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
        hasListeners = true
        super.startObserving()
    }
    
    override func stopObserving() {
        hasListeners = false
        super.stopObserving()
    }
    
    @objc static func checkIfLoggedIn() -> Bool{
        return InfobipSdkManager.isUserLoggedIn
    }
    
    // This function used to initiate the outgoing call
    @objc func call(_ apiKey: String, token: String, environment: String, identity: String, contactId: String, destination: String, caller: String) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if(granted){
                let callApplicationRequest = CallApplicationRequest(token, applicationId: environment, applicationCallEventListener: InfobipSdkManager.shared!)
                
                let customData = ["contactId": contactId, "fromNumber": caller, "toNumber": destination]
                let applicationCallOptions = ApplicationCallOptions(audio: true, customData: customData, entityId: identity)
                
                do {
                    InfobipSdkManager.shared!.outgoingCall = try InfobipSdkManager.shared!.infobipRTC.callApplication(callApplicationRequest, applicationCallOptions)
                } catch let ex {
                    print("outgoingCall (error) ===> ", ex.localizedDescription);
                }
            }else{
                InfobipSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
            }
        }
    }
    
    //This fucntion used to convert string into dictionary
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
    
    //This function used to convert payload into dictionary
    func convertIncomingCallToObject(_ payload: PKPushPayload!) -> [String: Any] {
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
    
    
    // This function used to handle incoming call from CallKit intent
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
    
    // This funciton used to handle in app incoming call
    @objc static func handleIncomingCall(_ payload: PKPushPayload, completion: @escaping IncomingCompletion) {
        InfobipSdkManager.shared?.incomingCompletion = completion
        if ((InfobipSdkManager.shared?.infobipRTC.isIncomingApplicationCall(payload)) != nil) {
            
            InfobipSdkManager.incomingPayload = payload
            shared?.infobipRTC.handleIncomingApplicationCall(payload, shared!)
        }
    }
    
    // This funciton will answer the incomging call
    @objc func answer() {
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            incomingCall.accept()
        }
    }
    
    // This funciton used to reject the call
    @objc func reject() {
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            incomingCall.decline(DeclineOptions(true))
        }
    }
    
    // This funciton used to mute the call
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
    
    // This funciton used to unmute the call
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
    
    // This funciton used to hangup outgoing or incoming call
    @objc func hangup() {
        if let incomingCall = InfobipSdkManager.shared?.incomingApplicationCall {
            incomingCall.hangup()
        } else if let outgoingCall = InfobipSdkManager.shared?.outgoingCall {
            outgoingCall.hangup()
        }
    }
    
    // This function used to set the audio input
    @objc func setAudioDevice(_ device: Int) {
        InfobipSdkManager.shared?.audioDeviceManager.setAudioDevice(type: device)
    }
    
    @objc func disablePushNotification(_ token: String) {
        InfobipSdkManager.isUserLoggedIn = false;
        InfobipSdkManager.shared?.infobipRTC.disablePushNotification(token)
    }
    
    // This fucntion used to register the push notification
    @objc func registerPushNotification(_ token: String, pushConfigId: String) {
        if let credentials = InfobipSdkManager.pushCredentials{
            InfobipSdkManager.isUserLoggedIn = true;
            InfobipSdkManager.shared?.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: isDebug(), pushConfigId: pushConfigId) { result in
            }
        }else{
            print("pushCredentials are null")
        }
        
    }
    @objc static func registerPushCredentials(_ credentials: PKPushCredentials) {
        InfobipSdkManager.pushCredentials = credentials
    }
    
    // This function used to set the incoming call event listener
    func onIncomingApplicationCall(_ incomingApplicationCallEvent: IncomingApplicationCallEvent) {
        let body = convertIncomingCallToObject(InfobipSdkManager.incomingPayload)
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCall", body: body);
        
        InfobipSdkManager.shared?.incomingApplicationCall = incomingApplicationCallEvent.incomingApplicationCall
        if let block = InfobipSdkManager.shared?.incomingCompletion {
            block()
        }
        InfobipSdkManager.shared?.incomingApplicationCall!.applicationCallEventListener = IncomingCallListener(InfobipSdkManager.shared!.incomingApplicationCall!)
    }
    
    @objc func isDebug() -> Bool {
#if DEBUG
        return true
        //        return false
#else
        return false
#endif
    }
}



extension InfobipSdkManager: WebrtcCallEventListener, ApplicationCallEventListener {
    func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {
        
    }
    func onConferenceJoined(_ conferenceJoinedEvent: ConferenceJoinedEvent) {

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
    
    func onRinging(_ callRingingEvent: CallRingingEvent) {
        
    }
    
    func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
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
        
    }
    
}

extension InfobipSdkManager: AudioDeviceManagerDelegate {
    func didChangeHeadphonesState(connected: Bool) {
        sendEvent(withName: "headphonesStateChanged", body: ["connected": connected])
    }
}

@objc(IncomingCallListener)

class IncomingCallListener: RCTEventEmitter, ApplicationCallEventListener{
    
    let incomingCall: IncomingApplicationCall
    static var shared: WebrtcCallListener?
    private var hasListeners : Bool = false
    
    init(_ incomingCall: IncomingApplicationCall) {
        self.incomingCall = incomingCall
        super.init()
        IncomingCallListener.shared = self
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
        hasListeners = true
        
        super.startObserving()
    }
    
    override func stopObserving() {
        hasListeners = false
        
        super.stopObserving()
    }
    
    func onRinging(_ callRingingEvent: CallRingingEvent) {
    }
    
    func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCallAnswered", body: "");
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            InfobipSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
        }
    }
    
    func onHangup(_ callHangupEvent: CallHangupEvent) {
        let body = InfobipSdkManager.shared?.convertIncomingCallToObject(InfobipSdkManager.incomingPayload)
        InfobipSdkManager.shared?.sendEvent(withName: "onIncomingCallHangup", body: body)
    }
    
    func onError(_ errorEvent: ErrorEvent) {
        
    }
    
    func onConferenceJoined(_ conferenceJoinedEvent: ConferenceJoinedEvent) {
        
    }
    
    func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
        
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
}
