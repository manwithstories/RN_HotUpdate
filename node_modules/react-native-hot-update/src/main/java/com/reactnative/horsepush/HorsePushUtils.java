package com.reactnative.horsepush;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.Point;
import android.os.Build;
import android.preference.PreferenceManager;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;

import java.io.File;
import java.lang.reflect.Method;

/**
 * Created by techbin on 16-6-15.
 */
public class HorsePushUtils {

    private static String HORSEPUSH = "HorsePush";

    //得到屏幕分辨率
    public static String getScreenSize(Context mContext) {
        String tempScreenSize = getScreenSize(mContext, false);
        return tempScreenSize;
    }


    public static String getScreenSize(Context mContext, boolean isOnlyGetWidth) {
        //first method
        if (Build.VERSION.SDK_INT < 17) {
            DisplayMetrics dm2 = mContext.getResources().getDisplayMetrics();
            // 竖屏
            if (mContext.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
                return isOnlyGetWidth ? dm2.widthPixels + "" : dm2.widthPixels + "x" + dm2.heightPixels;
            } else {// 横屏
                return isOnlyGetWidth ? dm2.heightPixels + "" : dm2.heightPixels + "x" + dm2.widthPixels;
            }
        } else {
            WindowManager windowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
            Display display = windowManager.getDefaultDisplay();
            Point size = new Point();
            try {
                Method method = display.getClass().getMethod("getRealSize", Point.class);
                method.invoke(display, size);
            } catch (Exception e) {
                e.printStackTrace();
            }
            int screenWidth = size.x;
            int screenHeight = size.y;
            if (mContext.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
                return isOnlyGetWidth ? screenWidth + "" : screenWidth + "x" + screenHeight;
            } else {
                return isOnlyGetWidth ? screenHeight + "" : screenHeight + "x" + screenWidth;
            }
        }
    }


    //是否为开发者
    public static boolean isDev() {
        try {
            File f = new File("/sdcard/horsepush.d");
            if (!f.exists()) {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
        return true;
    }



    public static String getExtraData(Context context) {
        return getSharedPreferences(context, HORSEPUSH + "extradata");
    }

    //调用小型存储用的
    public static String getSharedPreferences(Context context, String key) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        return sharedPreferences.getString(HORSEPUSH + key, "");
    }
    //调用小型存储用的
    public static void setSharedPreferences(Context context, String key, String value) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(HORSEPUSH + key, value);
        editor.commit();
    }

}
