import { InfoBipNativeSdk } from './InfoBipNativeSdk';
import { emitter } from './events';

enum CallState {
  DIALING = 0,
  RINGING = 1,
  ONGOING = 2,
  TERMINATED = 3,
}

interface PlivoLoginEvent {}
interface PlivoLogoutEvent {}

interface PlivoOutgoingEvent {
  callId: string;
  state: CallState;
  isOnHold: boolean;
  muted: boolean;
}

interface PlivoIncomingEvent {
  callId: string;
  state: CallState;
  isOnHold: boolean;
  muted: boolean;
}

type Handler<T> = (data: T) => void;

const createListener = <T>(event: string, handler: Handler<T>) => {
  const listener = emitter.addListener(`Plivo-${event}`, handler);
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

  call(phoneNumber: string, headers: Record<string, string>) {
    return InfoBipNativeSdk.call(phoneNumber, headers);
  }

  reconnect() {
    InfoBipNativeSdk.reconnect();
  }

  logout() {
    InfoBipNativeSdk.logout();
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

  hangup() {
    InfoBipNativeSdk.hangup();
  }

  reject() {
    InfoBipNativeSdk.reject();
  }

  isLoggedIn() {
    return this._isLoggedIn;
  }

  onLogin(handler: Handler<PlivoLoginEvent>) {
    return createListener('onLogin', (event: PlivoLoginEvent) => {
      this._isLoggedIn = true;

      handler(event);
    });
  }

  onLogout(handler: Handler<PlivoLogoutEvent>) {
    return createListener('onLogout', (event: PlivoLogoutEvent) => {
      this._isLoggedIn = false;

      handler(event);
    });
  }

  onLoginFailed(handler: Handler<PlivoLoginEvent>) {
    return createListener('onLoginFailed', handler);
  }

  onIncomingCall(handler: Handler<PlivoIncomingEvent>) {
    return createListener('onIncomingCall', handler);
  }

  onIncomingCallHangup(handler: Handler<PlivoIncomingEvent>) {
    return createListener('onIncomingCallHangup', handler);
  }

  onIncomingCallRejected(handler: Handler<PlivoIncomingEvent>) {
    return createListener('onIncomingCallRejected', handler);
  }

  onIncomingCallInvalid(handler: Handler<PlivoIncomingEvent>) {
    return createListener('onIncomingCallInvalid', handler);
  }

  onIncomingCallAnswered(handler: Handler<PlivoIncomingEvent>) {
    return createListener('onIncomingCallAnswered', handler);
  }

  onOutgoingCall(handler: Handler<PlivoOutgoingEvent>) {
    return createListener('onOutgoingCall', handler);
  }

  onOutgoingCallRinging(handler: Handler<PlivoOutgoingEvent>) {
    return createListener('onOutgoingCallRinging', handler);
  }

  onOutgoingCallAnswered(handler: Handler<PlivoOutgoingEvent>) {
    return createListener('onOutgoingCallAnswered', handler);
  }

  onOutgoingCallRejected(handler: Handler<PlivoOutgoingEvent>) {
    return createListener('onOutgoingCallRejected', handler);
  }

  onOutgoingCallHangup(handler: Handler<PlivoOutgoingEvent>) {
    return createListener('onOutgoingCallHangup', handler);
  }

  onOutgoingCallInvalid(handler: Handler<PlivoOutgoingEvent>) {
    return createListener('onOutgoingCallInvalid', handler);
  }

  onHeadphonesStateChanged(handler: Handler<{connected: boolean}>) {
    return createListener('headphonesStateChanged', handler);
  }
}
