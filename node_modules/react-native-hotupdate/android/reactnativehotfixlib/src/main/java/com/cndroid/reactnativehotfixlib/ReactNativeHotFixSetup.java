package com.cndroid.reactnativehotfixlib;

/**
 * Created by jinbangzhu on 03/01/2017.
 */
public class ReactNativeHotFixSetup {
    private static ReactNativeHotFixSetup ourInstance = new ReactNativeHotFixSetup();

    public static ReactNativeHotFixSetup getInstance() {
        return ourInstance;
    }

    private ReactNativeHotFixSetup() {
    }

    public void initial() {
        setExtraJSPath(getExtraBundleRootPath() + "index.android.jsbundle");
        setExtraZipBoundPath(getExtraBundleRootPath() + "android.zip");
        setExtraInfoPath(getExtraBundleRootPath() + "info.json");
    }


    public String getExtraBundleRootPath() {
        return extraBundleRootPath;
    }

    public void setExtraBundleRootPath(String extraBundleRootPath) {
        this.extraBundleRootPath = extraBundleRootPath;
    }

    public String getExtraZipBoundPath() {
        return extraZipBoundPath;
    }

    private void setExtraZipBoundPath(String extraZipBoundPath) {
        this.extraZipBoundPath = extraZipBoundPath;
    }

    public String getExtraJSPath() {
        return extraJSPath;
    }

    private void setExtraJSPath(String extraJSPath) {
        this.extraJSPath = extraJSPath;
    }

    public String getExtraInfoPath() {
        return extraInfoPath;
    }

    private void setExtraInfoPath(String extraInfoPath) {
        this.extraInfoPath = extraInfoPath;
    }

    /**
     * local bundle path where is index.android.bundle
     */
    private String extraBundleRootPath;
    private String extraZipBoundPath;
    private String extraJSPath;
    private String extraInfoPath;
}
