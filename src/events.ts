import { NativeEventEmitter } from 'react-native';

import { InfoBipNativeSdk } from './InfoBipNativeSdk';

export const emitter = new NativeEventEmitter(InfoBipNativeSdk);
