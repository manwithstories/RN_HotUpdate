package com.reactnative.horsepush;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;

import java.util.List;
import java.util.Locale;

/**
 * Created by techbin on 2016/3/22 0022.
 */
public class HorsePushModule extends ReactContextBaseJavaModule {
    private static ReactApplicationContext mReactApplicationContext;


    public HorsePushModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mReactApplicationContext = reactContext;
    }

    @Override
    public String getName() {
        return "HorsePush";
    }

    //得到用户app包名列表
    @ReactMethod
    public static void getUserAppPackageNameArray(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        PackageManager packageManager = mReactApplicationContext.getPackageManager();
        List<PackageInfo> packageInfos = packageManager.getInstalledPackages(0);
        WritableArray map = Arguments.createArray();
        for (int i = 0; i < packageInfos.size(); i++) {
            PackageInfo packageInfo = packageInfos.get(i);
            if ((packageInfo.applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM) == 0) {
                //非系统应用
                map.pushString(packageInfo.packageName);
            } else {
                //系统应用　　　　　　　　
            }
        }
        callback.invoke(map);
    }


    //得到渠道号
    @ReactMethod
    public static void getUmengChannel(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        String channel="";
        try {
            PackageManager localPackageManager = mReactApplicationContext.getPackageManager();
            ApplicationInfo localApplicationInfo = localPackageManager.getApplicationInfo(mReactApplicationContext.getPackageName(), 128);
            if (localApplicationInfo != null) {
                Object value = localApplicationInfo.metaData.get("UMENG_CHANNEL");
                if (value != null)
                    channel= String.valueOf(value);
            }
        } catch (Exception e) {  }
        callback.invoke(channel);
    }


    @ReactMethod
    public static void getVersionCode(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        String vCode = "0";
        try {
            PackageManager t = mReactApplicationContext.getPackageManager();
            PackageInfo pi = t.getPackageInfo(mReactApplicationContext.getPackageName(), 0);
            vCode = String.valueOf(pi.versionCode);
        } catch (Throwable v) {
        }


        callback.invoke(vCode);
    }

    @ReactMethod
    public static void getVersion(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        String vName = "1.0";
        try {
            PackageManager t = mReactApplicationContext.getPackageManager();
            PackageInfo pi = t.getPackageInfo(mReactApplicationContext.getPackageName(), 0);
            vName = pi.versionName;
        } catch (Throwable v) {
        }
        callback.invoke(vName);
    }

    @ReactMethod
    public static void getBrand(Callback callback) {
        callback.invoke(android.os.Build.BRAND);
    }

    @ReactMethod
    public static void getDeviceType(Callback callback) {
        callback.invoke(android.os.Build.MODEL);
    }

    @ReactMethod
    public static void getOs(Callback callback) {
        callback.invoke(android.os.Build.VERSION.RELEASE);
    }

    @ReactMethod
    public static void getSDKINT(Callback callback) {
        callback.invoke(Build.VERSION.SDK_INT);
    }

    @ReactMethod
    public static void getResolution(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        callback.invoke(HorsePushUtils.getScreenSize(mReactApplicationContext));
    }


    @ReactMethod
    public void getLanguage(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        Locale locale = mReactApplicationContext.getResources().getConfiguration().locale;
        String language = locale.getLanguage();
        callback.invoke(language);
    }

    //让启动页面隐藏
    @ReactMethod
    public static void setStartPageHide() {
        try {
            HorsePushStartPage.mActivity.finish();
        } catch (Exception e) {
        }
    }

    //小型存储用的 set
    @ReactMethod
    public static void setExtraData(String value) {
        if (mReactApplicationContext == null)
            return;
        HorsePushUtils.setSharedPreferences(mReactApplicationContext, "extradata", value);
    }

    @ReactMethod
    public static void getExtraData(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        callback.invoke(HorsePushUtils.getSharedPreferences(mReactApplicationContext, "extradata"));
    }


    @ReactMethod
    public static void getIsDev(Callback callback) {
        if (mReactApplicationContext == null)
            return;
        callback.invoke(HorsePushUtils.isDev() ? "1" : "0");
    }


}
