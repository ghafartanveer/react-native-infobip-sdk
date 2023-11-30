package com.infobipsdk;

import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.infobip.webrtc.sdk.api.InfobipRTC;
import com.infobip.webrtc.sdk.api.call.ApplicationCall;
import com.infobip.webrtc.sdk.api.event.call.CallEarlyMediaEvent;
import com.infobip.webrtc.sdk.api.event.call.CallEstablishedEvent;
import com.infobip.webrtc.sdk.api.event.call.CallHangupEvent;
import com.infobip.webrtc.sdk.api.event.call.CallRingingEvent;
import com.infobip.webrtc.sdk.api.event.call.CameraVideoAddedEvent;
import com.infobip.webrtc.sdk.api.event.call.CameraVideoUpdatedEvent;
import com.infobip.webrtc.sdk.api.event.call.ConferenceJoinedEvent;
import com.infobip.webrtc.sdk.api.event.call.ConferenceLeftEvent;
import com.infobip.webrtc.sdk.api.event.call.DialogJoinedEvent;
import com.infobip.webrtc.sdk.api.event.call.DialogLeftEvent;
import com.infobip.webrtc.sdk.api.event.call.ErrorEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantCameraVideoAddedEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantCameraVideoRemovedEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantDeafEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantJoinedEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantJoiningEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantLeftEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantMutedEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantScreenShareAddedEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantScreenShareRemovedEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantStartedTalkingEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantStoppedTalkingEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantUndeafEvent;
import com.infobip.webrtc.sdk.api.event.call.ParticipantUnmutedEvent;
import com.infobip.webrtc.sdk.api.event.call.ReconnectedEvent;
import com.infobip.webrtc.sdk.api.event.call.ReconnectingEvent;
import com.infobip.webrtc.sdk.api.event.call.ScreenShareAddedEvent;
import com.infobip.webrtc.sdk.api.event.call.ScreenShareRemovedEvent;
import com.infobip.webrtc.sdk.api.event.listener.ApplicationCallEventListener;
import com.infobip.webrtc.sdk.api.exception.ActionFailedException;
import com.infobip.webrtc.sdk.api.exception.IllegalStatusException;
import com.infobip.webrtc.sdk.api.exception.MissingPermissionsException;
import com.infobip.webrtc.sdk.api.options.ApplicationCallOptions;
import com.infobip.webrtc.sdk.api.request.CallApplicationRequest;

import java.util.HashMap;
import java.util.Map;

@ReactModule(name = InfobipSdkModule.NAME)
public class InfobipSdkModule extends ReactContextBaseJavaModule implements ApplicationCallEventListener {
    public static final String NAME = "InfobipSdkManager";

    private final ReactApplicationContext reactContext;
    private final InfobipRTC infobipRTC;
    private ApplicationCall outgoingCall;
    private AudioManager myAudioManager;

//    private Endpoint endpoint;
//    private Incoming incomingCall;
//    private Outgoing outgoingCall;

    public static HashMap<String, Object> options = new HashMap<String, Object>() {
        {
            put("debug", true);
            put("enableTracking", true);
        }
    };

    public InfobipSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.infobipRTC = InfobipRTC.getInstance();
        myAudioManager = (AudioManager)this.reactContext.getSystemService(Context.AUDIO_SERVICE);
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {

        Log.w(InfobipSdkModule.NAME, "sendEvent: " + eventName);

        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void login(String username, String password, String fcmToken, String certificateId) {
//        endpoint.login(username, password, fcmToken, certificateId);
    }

    @ReactMethod
    public void reconnect() {
    }

    @ReactMethod
    public void logout() {
//        endpoint.logout();
    }

    @ReactMethod
    public void call(String apiKey, String token, String environment, String identity, String contactId, String destination, String caller) {
        CallApplicationRequest callApplicationRequest = new CallApplicationRequest(token, this.reactContext, environment, this);

        String[] customDataKeys = {"contactId", "fromNumber", "toNumber"};
        String[] customDataValues = {contactId, caller, destination};

        Map<String, String> customData = new HashMap<>();

        for (int i = 0; i < customDataKeys.length; i++) {
            customData.put(customDataKeys[i], customDataValues[i]);
        }

        ApplicationCallOptions applicationCallOptions = ApplicationCallOptions.builder().audio(true).entityId(identity).customData(customData).build();

        try {
            this.outgoingCall = this.infobipRTC.callApplication(callApplicationRequest, applicationCallOptions);
        } catch (Exception e) {
            Log.e(NAME, "call: " + e.getMessage());
        }
    }

    @ReactMethod
    public void answer() {
//        if (incomingCall != null) {
//            incomingCall.answer();
//        } else {
//            Log.w(PlivoSdkModule.NAME, "Incoming call is not exist in incomingMap");
//        }
    }

    @ReactMethod
    public void reject() {
//        if (incomingCall != null) {
//            incomingCall.reject();
//        } else {
//            Log.w(PlivoSdkModule.NAME, "Incoming call is not exist in incomingMap");
//        }
    }

    @ReactMethod
    public void mute() {
//        if (incomingCall != null) {
//            incomingCall.mute();
//            return;
//        }
//
        if (this.outgoingCall != null) {
            try {
                this.outgoingCall.mute(true);
            } catch (Exception e) {
                Log.e(NAME, "mute: " + e.getMessage());
            }
        }
    }

    @ReactMethod
    public void unmute() {
//        if (incomingCall != null) {
//            incomingCall.unmute();
//            return;
//        }
//
        if (this.outgoingCall != null) {
            try {
                this.outgoingCall.mute(false);
            } catch (Exception e) {
                Log.e(NAME, "unmute: " + e.getMessage());
            }
        }
    }

    @ReactMethod
    public void hangup() {
//        if (incomingCall != null) {
//            incomingCall.hangup();
//            return;
//        }
//
        if (this.outgoingCall != null) {
            try {
                this.outgoingCall.hangup();
            } catch (Exception e) {
                Log.e(NAME, "hangup: " + e.getMessage());
            }
        }
    }

    // Plivo code...

    @ReactMethod
    public void setAudioDevice(int device) {
        switch (device) {
            case 0: // 0 - Phone
                this.myAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                this.myAudioManager.stopBluetoothSco();
                this.myAudioManager.setBluetoothScoOn(false);
                this.myAudioManager.setSpeakerphoneOn(false);
                break;
            case 1: // 1 - Speaker
                this.myAudioManager.setMode(AudioManager.MODE_NORMAL);
                this.myAudioManager.stopBluetoothSco();
                this.myAudioManager.setBluetoothScoOn(false);
                this.myAudioManager.setSpeakerphoneOn(true);
                break;
            case 2: // 2 - Bluetooth
                this.myAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                this.myAudioManager.startBluetoothSco();
                this.myAudioManager.setBluetoothScoOn(true);
                break;
            default:
                Log.i(NAME, "setAudioDevice unknown device ==> " + device);
        }
    }

    @Override
    public void onRinging(CallRingingEvent callRingingEvent) {

    }

    @Override
    public void onEarlyMedia(CallEarlyMediaEvent callEarlyMediaEvent) {

    }

    @Override
    public void onEstablished(CallEstablishedEvent callEstablishedEvent) {
        sendEvent(this.reactContext, "onOutgoingCallAnswered", null);
    }

    @Override
    public void onHangup(CallHangupEvent callHangupEvent) {
        sendEvent(this.reactContext, "onOutgoingCallHangup", null);
    }

    @Override
    public void onError(ErrorEvent errorEvent) {

    }

    @Override
    public void onCameraVideoAdded(CameraVideoAddedEvent cameraVideoAddedEvent) {

    }

    @Override
    public void onCameraVideoUpdated(CameraVideoUpdatedEvent cameraVideoUpdatedEvent) {

    }

    @Override
    public void onCameraVideoRemoved() {

    }

    @Override
    public void onScreenShareAdded(ScreenShareAddedEvent screenShareAddedEvent) {

    }

    @Override
    public void onScreenShareRemoved(ScreenShareRemovedEvent screenShareRemovedEvent) {

    }

    @Override
    public void onConferenceJoined(ConferenceJoinedEvent conferenceJoinedEvent) {

    }

    @Override
    public void onConferenceLeft(ConferenceLeftEvent conferenceLeftEvent) {

    }

    @Override
    public void onParticipantJoining(ParticipantJoiningEvent participantJoiningEvent) {

    }

    @Override
    public void onParticipantJoined(ParticipantJoinedEvent participantJoinedEvent) {

    }

    @Override
    public void onParticipantLeft(ParticipantLeftEvent participantLeftEvent) {

    }

    @Override
    public void onParticipantCameraVideoAdded(ParticipantCameraVideoAddedEvent participantCameraVideoAddedEvent) {

    }

    @Override
    public void onParticipantCameraVideoRemoved(ParticipantCameraVideoRemovedEvent participantCameraVideoRemovedEvent) {

    }

    @Override
    public void onParticipantScreenShareAdded(ParticipantScreenShareAddedEvent participantScreenShareAddedEvent) {

    }

    @Override
    public void onParticipantScreenShareRemoved(ParticipantScreenShareRemovedEvent participantScreenShareRemovedEvent) {

    }

    @Override
    public void onParticipantMuted(ParticipantMutedEvent participantMutedEvent) {

    }

    @Override
    public void onParticipantUnmuted(ParticipantUnmutedEvent participantUnmutedEvent) {

    }

    @Override
    public void onParticipantDeaf(ParticipantDeafEvent participantDeafEvent) {

    }

    @Override
    public void onParticipantUndeaf(ParticipantUndeafEvent participantUndeafEvent) {

    }

    @Override
    public void onParticipantStartedTalking(ParticipantStartedTalkingEvent participantStartedTalkingEvent) {

    }

    @Override
    public void onParticipantStoppedTalking(ParticipantStoppedTalkingEvent participantStoppedTalkingEvent) {

    }

    @Override
    public void onDialogJoined(DialogJoinedEvent dialogJoinedEvent) {

    }

    @Override
    public void onDialogLeft(DialogLeftEvent dialogLeftEvent) {

    }

    @Override
    public void onReconnecting(ReconnectingEvent reconnectingEvent) {

    }

    @Override
    public void onReconnected(ReconnectedEvent reconnectedEvent) {

    }

//    @Override
//    public void onLogin() {
//        sendEvent(reactContext, "Plivo-onLogin", null);
//    }
//
//    @Override
//    public void onLogout() {
//        sendEvent(reactContext, "Plivo-onLogout", null);
//    }
//
//    @Override
//    public void onLoginFailed() {
//        sendEvent(reactContext, "Plivo-onLoginFailed", null);
//    }
//
//    @Override
//    public void onLoginFailed(String message) {
//
//    }
//
//    @Override
//    public void onIncomingDigitNotification(String s) {
//
//    }
//
//    @Override
//    public void onIncomingCall(Incoming incoming) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", incoming.getCallId());
//        sendEvent(reactContext, "Plivo-onIncomingCall", params);
//    }
//
//    @Override
//    public void onIncomingCallConnected(Incoming incoming) {
//
//    }
//
//    @Override
//    public void onIncomingCallHangup(Incoming incoming) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", incoming.getCallId());
//        sendEvent(reactContext, "Plivo-onIncomingCallHangup", params);
//    }
//
//    @Override
//    public void onIncomingCallRejected(Incoming incoming) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", incoming.getCallId());
//        sendEvent(reactContext, "Plivo-onIncomingCallRejected", params);
//    }
//
//    @Override
//    public void onIncomingCallInvalid(Incoming incoming) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", incoming.getCallId());
//        sendEvent(reactContext, "Plivo-onIncomingCallInvalid", params);
//    }
//
//    @Override
//    public void onOutgoingCall(Outgoing outgoing) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", outgoing.getCallId());
//        sendEvent(reactContext, "Plivo-onOutgoingCall", params);
//    }
//
//    @Override
//    public void onOutgoingCallRinging(Outgoing outgoing) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", outgoing.getCallId());
//        sendEvent(reactContext, "Plivo-onOutgoingCallRinging", params);
//    }
//
//    @Override
//    public void onOutgoingCallAnswered(Outgoing outgoing) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", outgoing.getCallId());
//        sendEvent(reactContext, "Plivo-onOutgoingCallAnswered", params);
//    }
//
//    @Override
//    public void onOutgoingCallHangup(Outgoing outgoing) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", outgoing.getCallId());
//        sendEvent(reactContext, "Plivo-onOutgoingCallHangup", params);
//    }
//
//    @Override
//    public void onOutgoingCallRejected(Outgoing outgoing) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", outgoing.getCallId());
//        sendEvent(reactContext, "Plivo-onOutgoingCallRejected", params);
//    }
//
//    @Override
//    public void onOutgoingCallInvalid(Outgoing outgoing) {
//        WritableMap params = Arguments.createMap();
//        params.putString("callId", outgoing.getCallId());
//        sendEvent(reactContext, "Plivo-onOutgoingCallInvalid", params);
//    }
//
//    @Override
//    public void mediaMetrics(HashMap hashMap) {
//
//    }
//
//    @Override
//    public void onPermissionDenied(String message) {
//
//    }
}
