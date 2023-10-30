// import TelnyxRTC
import React
import CallKit

import Foundation
import PlivoVoiceKit
import Security

protocol PlivoSdkDelegate: AnyObject {
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

// final class TelnyxSdk: NSObject {
final class InfobipSdk: NSObject, PlivoEndpointDelegate {
// final class PlivoSdk: NSObject, PlivoEndpointDelegate {
    
    // static let shared = TelnyxSdk()
    // weak var delegate: TelnyxEventHandling?
    // private let telnyxClient: TxClient = TxClient()

    static let shared = PlivoSdk()

    weak var delegate: PlivoSdkDelegate?

    private let credentialsManager = CredentialsManager()
    private var isLoggedIn: Bool = false
    private var pendingPushInfo: [AnyHashable : Any]?

    private var endpoint: PlivoEndpoint? = PlivoEndpoint(["debug" : true, "enableTracking":true])


    // private var outgoingCall: Call?
    // private var incomingCall: Call?
    private var incomingCall: PlivoIncoming?
    private var outgoingCall: PlivoOutgoing?

    // override init() {
    //     super.init()

    //     telnyxClient.delegate = self
    // }

    private override init() {
        print("PlivoSdk ReactNativeEventEmitter init")
        super.init()
        endpoint?.delegate = self
    }

    // func login(username: String, password: String, deviceToken: String) -> Void {
    //     guard incomingCall == nil && callKitCallId == nil else { return }
    //     let txConfig = TxConfig(sipUser: username, password: password, pushDeviceToken: deviceToken)

    //     do {
    //         try telnyxClient.connect(txConfig: txConfig)
    //         credentialsManager.saveCredentials(username, password, deviceToken)
    //     } catch let error {
    //         delegate?.onLoginFailedWithError(error)
    //         print("(telnyx): connect error: \(error)")
    //     }
    // }

    func login(
        withUserName userName: String,
        andPassword password: String,
        deviceToken token: String,
        certificateId: String
        )
        -> Void {
            // converrt hex string token to Data
            let tokenData: Data = Data(convertHex(token.unicodeScalars, i: token.unicodeScalars.startIndex, appendTo: []))

            credentialsManager.saveCredentials(userName, password, token, certificateId)
            endpoint?.login(userName, andPassword: password, deviceToken: tokenData, certificateId: certificateId);
    }

    // func reconnect() {
    //     guard incomingCall == nil && outgoingCall == nil && callKitCallId == nil else { return }
    //     guard let username = credentialsManager.username,
    //           let password = credentialsManager.password,
    //           let deviceToken = credentialsManager.deviceToken else {
    //         return
    //     }

    //     let txConfig = TxConfig(sipUser: username,
    //                             password: password,
    //                             pushDeviceToken: deviceToken)

    //     do {
    //         try telnyxClient.connect(txConfig: txConfig)
    //     } catch let error {
    //         print("(telnyx): connect error: \(error)")
    //     }
    // }

    func reconnect() {
        guard incomingCall == nil && outgoingCall == nil else { return }
        
        if let username = credentialsManager.username,
           let password = credentialsManager.password,
           let deviceToken = credentialsManager.deviceToken,
           let certificateId = credentialsManager.certificateId {
            let tokenData: Data = Data(convertHex(deviceToken.unicodeScalars, i: deviceToken.unicodeScalars.startIndex, appendTo: []))

            endpoint?.login(username, andPassword: password, deviceToken: tokenData, certificateId: certificateId);
        }
    }

    // func logout() {
    //     telnyxClient.disconnect()
    //     telnyxClient.disablePushNotifications()
    //     credentialsManager.deleteCredentials()
    //     telnyxClient.delegate = nil
    // }

    // deinit {
    //     hangup()
    // }

    func logout() {
        credentialsManager.deleteCredentials()
        endpoint?.logout()
    }

    // func processVoIPNotification(callId: String, pushMetaData: [String: Any]) {
    //     callKitCallId = callId.uppercased()

    //     guard let username = credentialsManager.username,
    //           let password = credentialsManager.password,
    //           let deviceToken = credentialsManager.deviceToken else {
    //         return
    //     }
    //     let txConfig = TxConfig(sipUser: username,
    //                             password: password,
    //                             pushDeviceToken: deviceToken)
    //     let serverConfig = TxServerConfiguration(environment: .production)

    //     do {
    //         try telnyxClient.processVoIPNotification(txConfig: txConfig, serverConfiguration: serverConfig,pushMetaData:pushMetaData)
    //         print("(telnyx): processVoIPNotification config", txConfig)
    //     } catch let error {
    //         print("(telnyx): processVoIPNotification Error \(error)")
    //     }
    // }

    func relayVoipPushNotification(pushInfo: [AnyHashable : Any]) {
        if isLoggedIn {
            endpoint?.relayVoipPushNotification(pushInfo)
        } else {
            pendingPushInfo = pushInfo

            if let username = credentialsManager.username,
               let password = credentialsManager.password,
               let deviceToken = credentialsManager.deviceToken,
               let certificatedId = credentialsManager.certificateId {
                login(withUserName: username, andPassword: password, deviceToken: deviceToken, certificateId: certificatedId)
            }
        }
    }

    // func call(dest: String, headers: [AnyHashable: Any]) {
    //     let callerName = String(describing: headers["X-PH-callerName"]!)
    //     let callerNumber = String(describing: headers["X-PH-callerId"]!).replacingOccurrences(of: "+", with: "")
    //     let destinationNumber = dest.replacingOccurrences(of: "+", with: "")

    //     do {
    //         outgoingCall = try telnyxClient.newCall(callerName: callerName,
    //                                                 callerNumber: callerNumber,
    //                                                 destinationNumber: destinationNumber,
    //                                                 callId: UUID.init(),
    //                                                 clientState: "b3V0Z29pbmc=")
    //     } catch let error {
    //         print("(telnyx): call error", error)
    //     }
    // }

    func call(withDest dest: String, andHeaders headers: [AnyHashable: Any]) -> PlivoOutgoing? {
        var error: NSError?

        let domain: String = "@phone.plivo.com"

        /* construct SIP URI , where kENDPOINTURL is a contant contaning domain name details*/
        let sipUri: String = "sip:\(dest)\(domain)"

        outgoingCall = endpoint?.createOutgoingCall()
        outgoingCall?.call(sipUri, headers: headers, error: &error)

        return outgoingCall
    }

    func configureAudioSession() {
        endpoint?.configureAudioDevice()
    }

    func startAudioDevice() {
        endpoint?.startAudioDevice()
    }

    func stopAudioDevice() {
        endpoint?.stopAudioDevice()
    }

    // @objc(mute)
    // func mute() {
    //     if (outgoingCall != nil) {
    //         outgoingCall?.muteAudio()
    //     }

    //     if (incomingCall != nil) {
    //         incomingCall?.muteAudio()
    //     }
    // }

    // @objc(unmute)
    // func unmute() {
    //     if (outgoingCall != nil) {
    //         outgoingCall?.unmuteAudio()
    //     }

    //     if (incomingCall != nil) {
    //         incomingCall?.unmuteAudio()
    //     }
    // }

    // @objc(answer)
    // func answer() {
    //     if (incomingCall != nil) {
    //         incomingCall?.answer()
    //     }
    // }

    func mute() {
        if (outgoingCall != nil) {
            outgoingCall?.mute()
        }

        if (incomingCall != nil) {
            incomingCall?.mute()
        }
    }

    func unmute() {
        if (outgoingCall != nil) {
            outgoingCall?.unmute()
        }

        if (incomingCall != nil) {
            incomingCall?.unmute()
        }
    }

    // answer incoming call
    func answer() {
        if (incomingCall != nil) {
            incomingCall?.answer()
        }
    }

    // @objc(hangup)
    // func hangup() {
    //     if (outgoingCall != nil) {
    //         outgoingCall?.hangup()
    //         outgoingCall = nil
    //     }

    //     if (incomingCall != nil) {
    //         incomingCall?.hangup()
    //         incomingCall = nil
    //     }
    // }

    // @objc(reject)
    // func reject() {
    //     if (incomingCall != nil) {
    //         incomingCall?.hangup()
    //         incomingCall = nil
    //     }
    // }

    // hangup ONGOING call
    func hangup() {
        if (outgoingCall != nil) {
            outgoingCall?.hangup()
            outgoingCall = nil
        }

        if (incomingCall != nil) {
            incomingCall?.hangup()
            incomingCall = nil
        }
    }

    // reject incoming call
    func reject() {
        if (incomingCall != nil) {
            incomingCall?.reject()
            incomingCall = nil
        }
    }

    func onLogin() {
        delegate?.onLogin()
        isLoggedIn = true
        if let pushInfo = pendingPushInfo {
            endpoint?.relayVoipPushNotification(pushInfo)
            pendingPushInfo = nil
        }
    }

    func onLoginFailed() {
        delegate?.onLoginFailed()
    }

    func onLogout() {
        delegate?.onLogout()
    }

    func onLoginFailedWithError(_ error: Error!) {
        delegate?.onLoginFailedWithError(error)
    }

    //    onOutgoingCalling
    func onCalling(_ outgoing: PlivoOutgoing!) {
        outgoingCall = outgoing;
        configureAudioSession()
        startAudioDevice()
        delegate?.onCalling(convertOutgoingCallToObject(outgoing))
    }

    func onOutgoingCallRejected(_ outgoing: PlivoOutgoing) {
        delegate?.onOutgoingCallRejected(convertOutgoingCallToObject(outgoing))
    }

    func onOutgoingCallInvalid(_ outgoing: PlivoOutgoing) {
        delegate?.onOutgoingCallInvalid(convertOutgoingCallToObject(outgoing))
    }

    func onOutgoingCallRinging(_ outgoing: PlivoOutgoing!) {
        delegate?.onOutgoingCallRinging(convertOutgoingCallToObject(outgoing))
    }

    func onOutgoingCallHangup(_ outgoing: PlivoOutgoing!) {
        outgoingCall = nil;

        delegate?.onOutgoingCallHangup(convertOutgoingCallToObject(outgoing))
    }

    func onOutgoingCallAnswered(_ outgoing: PlivoOutgoing!) {
        delegate?.onOutgoingCallAnswered(convertOutgoingCallToObject(outgoing))
    }

    func onIncomingCall(_ incoming: PlivoIncoming!) {
        incomingCall = incoming
        configureAudioSession()
        delegate?.onIncomingCall(convertIncomingCallToObject(incoming))
    }

    func onIncomingCallAnswered(_ incoming: PlivoIncoming!) {
        startAudioDevice()
        delegate?.onIncomingCallAnswered(convertIncomingCallToObject(incoming))
    }

    func onIncomingCallRejected(_ incoming: PlivoIncoming!) {
        delegate?.onIncomingCallRejected(convertIncomingCallToObject(incoming))

        dismissCallKitUI { [weak self] error in
            if error == nil {
                self?.incomingCall = nil
            }
        }
    }

    func onIncomingCallHangup(_ incoming: PlivoIncoming!) {
        delegate?.onIncomingCallHangup(convertIncomingCallToObject(incoming))
        incomingCall = nil
        stopAudioDevice()
    }

    func onIncomingCallInvalid(_ incoming: PlivoIncoming!) {
        delegate?.onIncomingCallInvalid(convertIncomingCallToObject(incoming))
    }

    private func convertOutgoingCallToObject(_ call: PlivoOutgoing!) -> [String: Any] {
        let body: [String: Any] = [
            "callId": call.callId ?? "",
            "state": call.state.rawValue,
            "muted": call.muted,
            "isOnHold": call.isOnHold
        ];

        return body;
    }

    private func convertIncomingCallToObject(_ call: PlivoIncoming!) -> [String: Any] {
          let callId = call.extraHeaders["X-PH-Original-Call-Id"] as? String;
          let callerName = call.extraHeaders["X-PH-Contact"] as? String;
          let callerId = call.extraHeaders["X-PH-Contact-Id"] as? String;

          let body: [String: Any] = [
              "callId": normalizeHeaderValue(value:callId) ?? "",
              "callerPhone": call.fromUser ?? "",
              "callerName": normalizeHeaderValue(value:callerName) ?? "",
              "callerId": normalizeHeaderValue(value:callerId) ?? "",
              "state": call.state.rawValue,
              "muted": call.muted,
              "isOnHold": call.isOnHold
          ];

          return body;
      }

    private func normalizeHeaderValue(value: String?) -> String? {
        return value?.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: " ", with: "")
    }

    private func dismissCallKitUI(_ completion: @escaping (Error?) -> Void) {
        let callController = CXCallController()

        guard let originalCallId = incomingCall?.extraHeaders["X-PH-Original-Call-Id"] as? String,
              let callId = normalizeHeaderValue(value: originalCallId),
              let uuid = UUID(uuidString: callId)
        else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid UUID"]))
            return
        }

        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)

        callController.request(transaction) { error in
            completion(error)
        }
    }
}

// extension TelnyxSdk: TxClientDelegate {
//     /// When the client has successfully connected to the Telnyx Backend.
//     func onSocketConnected() {
//         print("(telnyx): onSocketConnected")
//     }

//     /// This function will be executed when a sessionId is received.
//     func onSessionUpdated(sessionId: String)  {
//         print("(telnyx): onSessionUpdated")
//     }

//     /// When the client disconnected from the Telnyx backend.
//     func onSocketDisconnected() {
//         print("(telnyx): onSocketDisconnected")
//     }

//     /// You can start receiving incoming calls or start making calls once the client was fully initialized.
//     func onClientReady()  {
//         delegate?.onLogin()
//         print("(telnyx): onClientReady")
//     }

//     /// Something went wrong.
//     func onClientError(error: Error)  {
//         delegate?.onLoginFailedWithError(error)
//         print("(telnyx): onClientError", error.localizedDescription, error)
//     }

//     /// This delegate method will be called when the app is in foreground and the Telnyx Client is connected.
//     func onIncomingCall(call: Call)  {
//         incomingCall = call
//         print("(telnyx): INCOMING CALL")

//         delegate?.onIncomingCall(convertCallInfoToDict(call, shouldDisplayCallUI: true))
//     }

//     /// If you have configured Push Notifications and app is in background or the Telnyx Client is disconnected this delegate method will be called after the push notification is received.
//     func onPushCall(call: Call) {
//         incomingCall = call
//         print("(telnyx): PUSH CALL")
//         delegate?.onIncomingCall(convertCallInfoToDict(call))
//     }

//     /// Call has been removed internally.
//     func onRemoteCallEnded(callId: UUID) {
//         if outgoingCall != nil {
//             delegate?.onOutgoingCallHangup(["callId": callId.uuidString])
//         }

//         if incomingCall != nil {
//             delegate?.onIncomingCallHangup(["callId": callId.uuidString])
//             dismissCallKitUI { [weak self] error in
//                 self?.incomingCall = nil
//                 self?.callKitCallId = nil
//             }
//         }
//         print("(telnyx): onRemoteCallEnded")
//     }

//     /// You can update your UI from here based on the call states.
//     /// Check that the callId is the same as your current call.
//     func onCallStateUpdated(callState: CallState, callId: UUID) {
//       switch (callState) {
//       case .CONNECTING:
//           print("(telnyx): connecting")
//           delegate?.onCalling(["callId": callId.uuidString])
//           break

//       case .RINGING:
//           print("(telnyx): ringing")
//           delegate?.onOutgoingCallRinging(["callId": callId.uuidString])
//           break

//       case .NEW:
//           print("(telnyx): new")
//           break

//       case .ACTIVE:
//           print("(telnyx): active")
//           telnyxClient.isAudioDeviceEnabled = true
//           if outgoingCall != nil {
//               delegate?.onOutgoingCallAnswered(["callId": callId.uuidString])
//           }
//           if incomingCall != nil {
//               delegate?.onIncomingCallAnswered(["callId": callId.uuidString])
//           }
//           break

//       case .DONE:
//           print("(telnyx): done")
//           telnyxClient.isAudioDeviceEnabled = false
//           if outgoingCall != nil {
//               delegate?.onOutgoingCallHangup(["callId": callId.uuidString])
//           }
//           if incomingCall != nil {
//               delegate?.onIncomingCallHangup(["callId": callId.uuidString])
//           }
//           break

//       case .HELD:
//           print("(telnyx): held")
//           break
//       }
//     }

//     func onPushDisabled(success: Bool, message: String) {
//         print("telnyx: onPushDisabled")
//     }

//     private func convertCallInfoToDict(_ call: Call, shouldDisplayCallUI: Bool = false) -> [String: Any] {
//         let data: [String] = call.callInfo?.callerName?.components(separatedBy: "~~") ?? [];

//         // Since telnyx sometimes sends different callIds in push notification and onPushCall, using callKitCallId as callId, to be able to end call.
//         // If call received in onIncomingCall method, using callId from call.
//         let callId = callKitCallId ?? call.callInfo?.callId.uuidString

//         let body: [String: Any] = [
//             "callId": callId ?? "",
//             "callerName": data[0],
//             "callerPhone": call.callInfo?.callerNumber ?? "",
//             "callerId" : data[1],
//             "shouldDisplayCallUI": shouldDisplayCallUI
//         ]

//         return body
//     }

//     private func dismissCallKitUI(_ completion: @escaping (Error?) -> Void) {
//         let callController = CXCallController()

//         let callId = callKitCallId ?? incomingCall?.callInfo?.callId.uuidString

//         guard let callId = callId,
//               let uuid = UUID(uuidString: callId)
//         else {
//             completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid UUID"]))
//             return
//         }

//         let endCallAction = CXEndCallAction(call: uuid)
//         let transaction = CXTransaction(action: endCallAction)

//         callController.request(transaction) { error in
//             completion(error)
//         }
//     }
// }