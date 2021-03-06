/**
 *  UdpSocketsModule.java
 *  react-native-udp
 *
 *  Created by Andy Prock on 9/24/15.
 */

package com.quectel.sockets;


import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.quectel.sockets.tcp.TcpSocketModule;
import com.quectel.sockets.udp.UdpSockets;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public final class QuecAppSocketsModule implements ReactPackage {

    @Override
    public List<NativeModule> createNativeModules(
            ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<NativeModule>();

        modules.add(new UdpSockets(reactContext));
        modules.add(new TcpSocketModule(reactContext));
        return modules;
    }

    @Override
    public List<ViewManager> createViewManagers(
            ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

    /**
     * 已经弃用
     *
     * @return JavaScriptModule
     */
    // Deprecated from RN 0.47
    public List<Class<? extends JavaScriptModule>> createJSModules() {
        return Collections.emptyList();
    }
}
