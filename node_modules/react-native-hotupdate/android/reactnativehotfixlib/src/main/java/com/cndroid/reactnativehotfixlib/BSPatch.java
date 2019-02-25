package com.cndroid.reactnativehotfixlib;

/**
 * Created by jinbangzhu on 09/11/2016.
 */

public class BSPatch {
    static {
        System.loadLibrary("DroidBSDiff");
    }

    public native int bspatch(String old_file, String new_file, String patch_file);
}
