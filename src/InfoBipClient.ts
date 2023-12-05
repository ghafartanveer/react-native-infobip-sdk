import { Platform } from 'react-native';
import { InfoBipNativeSdk } from './InfoBipNativeSdk';
import { emitter } from './events';

enum CallState {
  DIALING = 0,
  RINGING = 1,
  ONGOING = 2,
  TERMINATED = 3,
}

interface InfoBipLoginEvent {}
interface InfoBipLogoutEvent {}

interface InfoBipOutgoingEvent {
  callId: string;
  state: CallState;
  isOnHold: boolean;
  muted: boolean;
}

interface InfoBipIncomingEvent {
  callId: string;
  state: CallState;
  isOnHold: boolean;
  muted: boolean;
}

type Handler<T> = (data: T) => void;

const createListener = <T>(event: string, handler: Handler<T>) => {
  // const listener = emitter.addListener(`InfoBip-${event}`, handler);
  const listener = emitter.addListener(`${event}`, handler);
  return () => listener.remove();
};

export class InfoBipClient {
  private _isLoggedIn = false;

  login(
    username: string,
    password: string,
    fcmToken: string,
    certificateId: string
  ) {
    return InfoBipNativeSdk.login(username, password, fcmToken, certificateId);
  }
  registerPushNotification(token: string, pushConfigId: string) {
    return InfoBipNativeSdk.registerPushNotification(token, pushConfigId);
  }
  registerAndroidPushNotification(
    fcmToken: string,
    token: string,
    pushConfigId: string
  ) {
    return InfoBipNativeSdk.registerAndroidPushNotification(
      fcmToken,
      token,
      pushConfigId
    );
  }
  call(
    apiKey: string,
    webRTCToken: string,
    environment: string,
    identity: string,
    contactId: string,
    destination: string,
    caller: string
  ) {
    console.log(
      'calling ==> ',
      apiKey,
      webRTCToken,
      environment,
      identity,
      contactId,
      destination,
      caller
    );
    return InfoBipNativeSdk.call(
      apiKey,
      webRTCToken,
      environment,
      identity,
      contactId,
      destination,
      caller
    );
  }

  reconnect() {
    InfoBipNativeSdk.reconnect();
  }

  logout(token: string) {
    InfoBipNativeSdk.disablePushNotification(token);
    this._isLoggedIn = false;
  }

  setAudioDevice(device: number) {
    InfoBipNativeSdk.setAudioDevice(device);
  }

  mute() {
    InfoBipNativeSdk.mute();
  }

  unmute() {
    InfoBipNativeSdk.unmute();
  }

  answer() {
    InfoBipNativeSdk.answer();
  }

  handleIncomingCall(payload) {
    if (Platform.OS === 'android') {
      InfoBipNativeSdk.handleIncomingCall(payload);
    } else {
      InfoBipNativeSdk.handleIncomingCallFromCallKeep();
    }
  }

  hangup() {
    InfoBipNativeSdk.hangup();
  }

  reject() {
    InfoBipNativeSdk.reject();
  }

  isLoggedIn() {
    return this._isLoggedIn;
  }

  onLogin(handler: Handler<InfoBipLoginEvent>) {
    return createListener('onLogin', (event: InfoBipLoginEvent) => {
      this._isLoggedIn = true;

      handler(event);
    });
  }

  onLogout(handler: Handler<InfoBipLogoutEvent>) {
    return createListener('onLogout', (event: InfoBipLogoutEvent) => {
      this._isLoggedIn = false;

      handler(event);
    });
  }

  onLoginFailed(handler: Handler<InfoBipLoginEvent>) {
    return createListener('onLoginFailed', handler);
  }

  onIncomingCall(handler: Handler<InfoBipIncomingEvent>) {
    return createListener('onIncomingCall', handler);
  }

  onIncomingCallHangup(handler: Handler<InfoBipIncomingEvent>) {
    return createListener('onIncomingCallHangup', handler);
  }

  onIncomingCallRejected(handler: Handler<InfoBipIncomingEvent>) {
    return createListener('onIncomingCallRejected', handler);
  }

  onIncomingCallInvalid(handler: Handler<InfoBipIncomingEvent>) {
    return createListener('onIncomingCallInvalid', handler);
  }

  onIncomingCallAnswered(handler: Handler<InfoBipIncomingEvent>) {
    return createListener('onIncomingCallAnswered', handler);
  }

  onOutgoingCall(handler: Handler<InfoBipOutgoingEvent>) {
    return createListener('onOutgoingCall', handler);
  }

  onOutgoingCallRinging(handler: Handler<InfoBipOutgoingEvent>) {
    return createListener('onOutgoingCallRinging', handler);
  }

  onOutgoingCallAnswered(handler: Handler<InfoBipOutgoingEvent>) {
    return createListener('onOutgoingCallAnswered', handler);
  }

  onOutgoingCallRejected(handler: Handler<InfoBipOutgoingEvent>) {
    return createListener('onOutgoingCallRejected', handler);
  }

  onOutgoingCallHangup(handler: Handler<InfoBipOutgoingEvent>) {
    return createListener('onOutgoingCallHangup', handler);
  }

  onOutgoingCallInvalid(handler: Handler<InfoBipOutgoingEvent>) {
    return createListener('onOutgoingCallInvalid', handler);
  }

  onHeadphonesStateChanged(handler: Handler<{ connected: boolean }>) {
    return createListener('headphonesStateChanged', handler);
  }
}
