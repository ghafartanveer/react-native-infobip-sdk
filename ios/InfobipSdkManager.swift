import React
import Foundation
import PlivoVoiceKit // TODO: Replace with InfoBip

// TODO: Replace with InfoBip
protocol TelnyxEventHandling: AnyObject {
    // Login
    func onLogin()
    func onLoginFailed()
    func onLogout()
    func onLoginFailedWithError(_ error: Error!)
    // Outgoing call
    func onCalling(_ data: [String: Any])
    func onOutgoingCallRejected(_ data: [String: Any])
    func onOutgoingCallInvalid(_ data: [String: Any])
    func onOutgoingCallRinging(_ data: [String: Any])
    func onOutgoingCallHangup(_ data: [String: Any])
    func onOutgoingCallAnswered(_ data: [String: Any])
    // Incoming call
    func onIncomingCall(_ data: [String: Any])
    func onIncomingCallHangup(_ data: [String: Any])
    func onIncomingCallAnswered(_ data: [String: Any])
    func onIncomingCallInvalid(_ data: [String: Any])
    func onIncomingCallRejected(_ data: [String: Any])
}

@objc(InfobipSdkManager)
// final class PlivoSdkManager: RCTEventEmitter, PlivoSdkDelegate {
final class TelnyxSdkManager: RCTEventEmitter, TelnyxEventHandling {
// TODO: Update InfobipSdkManager class...
// final class InfobipSdkManager: NSObject {

  private let shared = TelnyxSdk.shared
    private let audioDeviceManager = AudioDeviceManager()

    private var hasListeners : Bool = false

    override init() {
        super.init()

        TelnyxSdk.shared.delegate = self
        audioDeviceManager.delegate = self
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

  // @objc(multiply:withB:withResolver:withRejecter:)
  // func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
  //   resolve(a*b)
  // }

// TODO: Not sure what the '!' means here...
// override func supportedEvents() -> [String]! {
    override func supportedEvents() -> [String] {
      // TODO: Replace with InfoBip
        return [
            "Telnyx-onLogin",
            "Telnyx-onLoginFailed",
            "Telnyx-onLogout",
            "Telnyx-onIncomingCall",
            "Telnyx-onIncomingCallHangup",
            "Telnyx-onIncomingCallRejected",
            "Telnyx-onIncomingCallAnswered",
            "Telnyx-onIncomingCallInvalid",
            "Telnyx-onOutgoingCall",
            "Telnyx-onOutgoingCallAnswered",
            "Telnyx-onOutgoingCallRinging",
            "Telnyx-onOutgoingCallRejected",
            "Telnyx-onOutgoingCallHangup",
            "Telnyx-onOutgoingCallInvalid",
            "Telnyx-headphonesStateChanged"
        ]
    }

    override func startObserving() {
        print("TelnyxSdk ReactNativeEventEmitter startObserving")

        hasListeners = true

        super.startObserving()
    }


    override func stopObserving() {
        print("TelnyxSdk ReactNativeEventEmitter stopObserving")

        hasListeners = false

        super.stopObserving()
    }

    @objc(login:password:token:)

    @objc static func relayVoipPushNotification(_ pushInfo: [AnyHashable : Any]) {
        PlivoSdk.shared.relayVoipPushNotification(pushInfo: pushInfo)
    }

    @objc(login:password:token:certificateId:)

    func login(
        withUserName userName: String,
        andPassword password: String,
        deviceToken token: String,
        certificateId: String
        )
        -> Void {
            PlivoSdk.shared.login(withUserName: userName,
                                  andPassword: password,
                                  deviceToken: token,
                                  certificateId: certificateId)
    }

    @objc static func processVoIPNotification(_ callId: String, pushMetaData: [String: Any]) {
        TelnyxSdk.shared.processVoIPNotification(callId: callId, pushMetaData: pushMetaData)
    }

    @objc static func cancelAllCalls() {
        TelnyxSdk.shared.hangup()
    }

    @objc(call:headers:)
    func call(withDest dest: String, andHeaders headers: [AnyHashable: Any]) -> PlivoOutgoing? {
        return shared.call(withDest: dest, andHeaders: headers)
    }

     @objc func reconnect() {
        shared.reconnect()
    }

    @objc func logout() {
        shared.logout()
    }

    @objc func mute() {
        shared.mute()
    }

    @objc func unmute() {
        shared.unmute()
    }

    @objc func answer() {
        shared.answer()
    }

    @objc func hangup() {
        shared.hangup()
    }

    @objc func reject() {
        shared.reject()
    }

    @objc func setAudioDevice(_ device: Int) {
        audioDeviceManager.setAudioDevice(type: device)
    }

    func onLogin() {
        sendEvent(withName: "Plivo-onLogin", body:nil);
    }

    func onLoginFailed() {
        sendEvent(withName: "Plivo-onLoginFailed", body:nil);
    }

    func onLogout() {
        sendEvent(withName: "Plivo-onLogout", body:nil);
    }

    // func onLoginFailedWithError(_ error: Error!) {
    //     let body = ["error": error.localizedDescription]
    //     sendEvent(withName: "Telnyx-onLoginFailed", body: body);
    // }

    func onLoginFailedWithError(_ error: Error!) {
        sendEvent(withName: "Plivo-onLoginFailed", body:nil);
    }

    func onCalling(_ data: [String: Any]) {
        audioDeviceManager.isBluetoothDeviceConnected()
        sendEvent(withName: "Plivo-onOutgoingCall", body: data);
    }

    func onOutgoingCallRejected(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onOutgoingCallRejected", body: data);
    }

    func onOutgoingCallInvalid(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onOutgoingCallInvalid", body: data);
    }

    func onOutgoingCallRinging(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onOutgoingCallRinging", body: data);
    }

    func onOutgoingCallHangup(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onOutgoingCallHangup", body: data);
    }

    func onOutgoingCallAnswered(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onOutgoingCallAnswered", body: data);
    }

    func onIncomingCall(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onIncomingCall", body: data);
    }

    func onIncomingCallHangup(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onIncomingCallHangup", body: data);
    }

    func onIncomingCallAnswered(_ data: [String: Any]) {
        audioDeviceManager.isBluetoothDeviceConnected()
        sendEvent(withName: "Plivo-onIncomingCallAnswered", body: data);
    }

    func onIncomingCallInvalid(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onIncomingCallInvalid", body: data);
    }

    func onIncomingCallRejected(_ data: [String: Any]) {
        sendEvent(withName: "Plivo-onIncomingCallRejected", body: data);
    }
}

extension PlivoSdkManager: AudioDeviceManagerDelegate {
    func didChangeHeadphonesState(connected: Bool) {
        sendEvent(withName: "Plivo-headphonesStateChanged", body: ["connected": connected])
    }
}
