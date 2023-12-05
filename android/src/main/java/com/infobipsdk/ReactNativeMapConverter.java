package com.infobipsdk;

import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.ReadableType;

import java.util.HashMap;
import java.util.Map;

public class ReactNativeMapConverter {
    public static Map<String, String> convertReadableMapToMap(ReadableNativeMap readableMap) {
        Map<String, String> resultMap = new HashMap<>();

        if (readableMap != null) {
            // Iterate through all keys in the ReadableMap
            for (String key : readableMap.toHashMap().keySet()) {
                // Check if the value associated with the key is of type String
                if (readableMap.getType(key) == ReadableType.String) {
                    // Add the key-value pair to the result map
                    resultMap.put(key, readableMap.getString(key));
                } else {
                    // Handle other types if necessary
                    // For example, you can convert other types to String
                    // or skip non-String values
                }
            }
        }

        return resultMap;
    }
}
