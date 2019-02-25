package com.cndroid.reactnativehotfixlib;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;

import com.android.volley.Cache;
import com.android.volley.Network;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.BasicNetwork;
import com.android.volley.toolbox.DiskBasedCache;
import com.android.volley.toolbox.HurlStack;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.ref.WeakReference;


/**
 * Created by jinbangzhu on 10/11/2016.
 */

public class ReactNativeHotFix {
    public static final String EXTRAROOTBUNDLEPATH = "extraBundleRootPath";
    public static final int CODE_FAIL = 980;
    public static final int CODE_SUCCESS = 981;


    private static final String TAG = "ReactNativeHotFix";

    private RequestQueue mRequestQueue;  // Assume this exists.

    private WeakReference<Context> weakReferenceContext;
    /**
     * url for upgrade
     */
    private String upgradeUrl;
    private String patchUrl;
    private ReactNativeHotFixSetup reactNativeHotFixSetup;


    private Handler handler;

    private long startTime;

    public static ReactNativeHotFix create(Context context) {
        ReactNativeHotFix fix = new ReactNativeHotFix();
        fix.weakReferenceContext = new WeakReference<>(context);
        fix.reactNativeHotFixSetup = ReactNativeHotFixSetup.getInstance();
        fix.initNetwork();
        return fix;
    }

    private void initNetwork() {
        if (weakReferenceContext.get() == null) return;
        // Instantiate the cache
        Cache cache = new DiskBasedCache(weakReferenceContext.get().getCacheDir(), 1024 * 1024); // 1MB cap

        // Set up the network to use HttpURLConnection as the HTTP client.
        Network network = new BasicNetwork(new HurlStack());

        // Instantiate the RequestQueue with the cache and network.
        mRequestQueue = new RequestQueue(cache, network);

        // Start the queue
        mRequestQueue.start();
    }

    public ReactNativeHotFix setUpgradeUrl(String url) {
        this.upgradeUrl = url;
        return this;
    }

    public ReactNativeHotFix setPatchUrl(String patchUrl) {
        this.patchUrl = patchUrl;
        return this;
    }

    public ReactNativeHotFix setHandler(Handler handler) {
        this.handler = handler;
        return this;
    }

    public void start() {
        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                if (TextUtils.isEmpty(reactNativeHotFixSetup.getExtraBundleRootPath())
                        || TextUtils.isEmpty(reactNativeHotFixSetup.getExtraInfoPath())
                        || TextUtils.isEmpty(reactNativeHotFixSetup.getExtraJSPath())) {
                    sendMessageWithFail("not initial");
                } else {
                    initialResource();
                    doStart();
                }
                return null;
            }
        }.execute();
    }


    public void initialResource() {
        // copy zip file to sdcard
        getBundleZipFile();


        // unzip it if need
        unzipItIfNeed();
    }

    private void unzipItIfNeed() {
        File jsFile = new File(reactNativeHotFixSetup.getExtraJSPath());

        if (!jsFile.exists()) {
            FileUtils.deleteFileOrFolderSilently(jsFile);

            try {
                FileUtils.unzipFile(new File(reactNativeHotFixSetup.getExtraZipBoundPath()), reactNativeHotFixSetup.getExtraBundleRootPath());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * call this method manual, the MD5 string should from server
     *
     * @param originFileMd5 the old zip file md5
     * @param targetFileMd5 the new zip file md5
     * @param patchFileMd5  the patch file md5
     * @param patchUrl      the patch url on server
     */
    public void start(String originFileMd5, String targetFileMd5, String patchFileMd5, String patchUrl) {
        Log.d(TAG, "originFileMd5:" + originFileMd5);

        File originFile = getBundleZipFile();
        if (originFile.exists()) {
            // get old file md5
            String oldOriginFileMd5 = MD5Helper.calculateMD5(originFile);
            if (!TextUtils.isEmpty(oldOriginFileMd5)) {
                // check md5
                if (oldOriginFileMd5.equals(originFileMd5)) {
                    downloadFile(patchUrl, targetFileMd5, patchFileMd5);
                } else {
                    sendMessageWithFail("oldOriginFileMd5 not equal originFileMd5");
                    Log.d(TAG, "oldOriginFileMd5 not equal originFileMd5");
                }
            } else {
                sendMessageWithFail("oldOriginFileMd5 is null");
                Log.d(TAG, "oldOriginFileMd5 is null");
            }
        } else {
            sendMessageWithFail("originFile not exists");
            Log.d(TAG, "originFile not exists");
        }

    }

    private void doStart() {


        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET, upgradeUrl, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject jsonObject) {
                /**
                 {
                 "ok": true,
                 "md5": {
                 "patchFileMd5": "3dd617405e51c97cacf73e3b3cbf1328",
                 "originFileMd5": "d3f55a8dc827bf760e3588a8c4e5e8ef",
                 "targetFileMd5": "f12cd950240cad066e2eea92e1c9752b"
                 },
                 "patch_url": "/rn_patch/v0.0.8/patches/ios/v0.0.6_v0.0.8"
                 }
                 */


                try {
                    boolean ok = jsonObject.getBoolean("ok");
                    String message = "unknown";
                    if(jsonObject.has("msg")){
                        message = jsonObject.getString("msg");
                    }

                    if (ok) {
                        JSONObject md5 = jsonObject.getJSONObject("md5");

                        String originFileMd5 = md5.getString("originFileMd5");
                        String targetFileMd5 = md5.getString("targetFileMd5");
                        String patchFileMd5 = md5.getString("patchFileMd5");

                        patchUrl = jsonObject.getString("patch_url");
                        start(originFileMd5, targetFileMd5, patchFileMd5, patchUrl);
                    } else {
                        sendMessageWithFail(message);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                    sendMessageWithFail(e.getMessage());
                }

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                error.printStackTrace();
                sendMessageWithFail(error.getMessage());
            }

        });

        jsonObjectRequest.setTag(getClass().getSimpleName());
        // Add the request to the RequestQueue.
        if (null != mRequestQueue)
            mRequestQueue.add(jsonObjectRequest);

    }

    private File getBundleZipFile() {
        File extraBundleZipFile = new File(reactNativeHotFixSetup.getExtraZipBoundPath());
        if (extraBundleZipFile.exists()) {
            upgradeExtraBundleIFNeed(extraBundleZipFile);
            return extraBundleZipFile;
        } else {
            // copy assets bundleZipFile to sdcard

            createDirsForBundleRoot();
            copyAssetZipToSDcard(extraBundleZipFile);
        }

        return extraBundleZipFile;
    }

    /**
     * upgrade extra bundle
     *
     * @param extraBundleZipFile
     */
    private void upgradeExtraBundleIFNeed(File extraBundleZipFile) {
        if (getDefaultVersionCode() > getExtraVersionCode()) {
            FileUtils.deleteFileOrFolderSilently(extraBundleZipFile);
            removeOldFiles();

            extraBundleZipFile = new File(reactNativeHotFixSetup.getExtraZipBoundPath());
            copyAssetZipToSDcard(extraBundleZipFile);

            try {
                FileUtils.unzipFile(extraBundleZipFile, reactNativeHotFixSetup.getExtraBundleRootPath());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * get int version code
     *
     * @return int
     */
    public int getDefaultVersionCode() {
        String version = getDefaultVersion();
        if (TextUtils.isEmpty(version)) return -1;

        return Integer.parseInt(getDefaultVersion().replace(".", ""));
    }

    /**
     * get version
     *
     * @return
     */
    public String getDefaultVersion() {
        InputStream inputStream;
        try {
            inputStream = weakReferenceContext.get().getAssets().open("info.json");
            String jsonInfo = convertStreamToString(inputStream);

            JSONObject jsonObject = new JSONObject(jsonInfo);

            return jsonObject.getString("version");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * extraVersionCode
     * e.g 23
     *
     * @return version code
     */
    public static int getExtraVersionCode() {
        String version = getExtraVersion();
        if (TextUtils.isEmpty(version)) return -1;

        return Integer.parseInt(version.replace(".", ""));
    }

    /**
     * extraVersion
     * e.g 0.2.3
     *
     * @return version name
     */
    public static String getExtraVersion() {
        try {
            FileInputStream fileInputStream = new FileInputStream(ReactNativeHotFixSetup.getInstance().getExtraInfoPath());
            String jsonInfo = convertStreamToString(fileInputStream);
            JSONObject jsonObject = new JSONObject(jsonInfo);

            return jsonObject.getString("version");
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    private static String convertStreamToString(InputStream is) throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();
        String line = null;
        while ((line = reader.readLine()) != null) {
            sb.append(line).append("\n");
        }
        reader.close();
        return sb.toString();
    }


    private void copyAssetZipToSDcard(File extraBundleZipFile) {
        if (null != weakReferenceContext.get()) {
            try {
                InputStream inputStream = weakReferenceContext.get().getAssets().open("android.zip");
                OutputStream outputStream = new FileOutputStream(extraBundleZipFile);

                FileUtils.copyFile(inputStream, outputStream);

                inputStream.close();

                outputStream.flush();
                outputStream.close();

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void createDirsForBundleRoot() {
        File extraRoot = new File(reactNativeHotFixSetup.getExtraBundleRootPath());
        if (!extraRoot.exists()) extraRoot.mkdirs();
    }


    private void sendMessageWithFail(String message) {
        if (null != handler) handler.sendEmptyMessage(CODE_FAIL);
    }


    private void downloadFile(String url, final String targetFileMd5, final String patchFileMd5) {
        InputStreamVolleyRequest inputStreamVolleyRequest = new InputStreamVolleyRequest(Request.Method.GET, url, new Response.Listener<byte[]>() {
            @Override
            public void onResponse(byte[] response) {
                try {
                    if (response != null) {
                        savePatchFile(response, patchFileMd5, targetFileMd5);
                    } else {
                        Log.d(TAG, "download file failed");
                        sendMessageWithFail("download file failed");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    sendMessageWithFail(e.getMessage());
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                sendMessageWithFail(volleyError.getMessage());
                volleyError.printStackTrace();
            }
        }, null);

        inputStreamVolleyRequest.setTag(getClass().getSimpleName());

        if (null != mRequestQueue)
            mRequestQueue.add(inputStreamVolleyRequest);
    }


    private void savePatchFile(byte[] response, String patchFileMd5, String targetFileMd5) throws IOException {
        startTime = System.currentTimeMillis();


        String patchFile = reactNativeHotFixSetup.getExtraBundleRootPath() + "_patch";
        FileOutputStream outputStream = new FileOutputStream(patchFile);
        outputStream.write(response);
        outputStream.flush();
        outputStream.close();


        String downloadPatchFileMd5 = MD5Helper.calculateMD5(new File(patchFile));
        if (!TextUtils.isEmpty(downloadPatchFileMd5)) {
            // check file md5
            if (downloadPatchFileMd5.equals(patchFileMd5)) {
                applyPatch(targetFileMd5, patchFile);
            } else {
                sendMessageWithFail("patchFileMd5 not equal downloadPatchFileMd5");
                Log.d(TAG, "patchFileMd5 not equal downloadPatchFileMd5");
            }
        } else {
            sendMessageWithFail("patchFile is null");
            Log.d(TAG, "patchFile is null");

        }
    }

    private void applyPatch(String targetFileMd5, String patchFile) {

        String bundleFilePathTemp = reactNativeHotFixSetup.getExtraZipBoundPath() + "_temp";

        BSPatch bsPatch = new BSPatch();
        bsPatch.bspatch(reactNativeHotFixSetup.getExtraZipBoundPath(), bundleFilePathTemp, patchFile);

        File zipFileTemp = new File(bundleFilePathTemp);

        String generatedTargetFileMd5 = MD5Helper.calculateMD5(zipFileTemp);

        assert generatedTargetFileMd5 != null;

        if (generatedTargetFileMd5.equals(targetFileMd5)) {

            // delete old zip file
            FileUtils.deleteFileOrFolderSilently(new File(reactNativeHotFixSetup.getExtraZipBoundPath()));

            // rename to real bundle
            zipFileTemp.renameTo(new File(reactNativeHotFixSetup.getExtraZipBoundPath()));

            // delete patch file
            FileUtils.deleteFileOrFolderSilently(new File(patchFile));
            removeOldFiles();

            try {
                FileUtils.unzipFile(new File(reactNativeHotFixSetup.getExtraZipBoundPath()), reactNativeHotFixSetup.getExtraBundleRootPath());

                Log.d(TAG, "success" + reactNativeHotFixSetup.getExtraBundleRootPath() + " wastTime=" + (System.currentTimeMillis() - startTime));

                if (null != handler)
                    handler.sendEmptyMessage(CODE_SUCCESS);
            } catch (IOException e) {
                e.printStackTrace();
                sendMessageWithFail(e.getMessage());
            }

        } else {
            Log.d(TAG, "generatedTargetFileMd5 not equal targetFileMd5");
            sendMessageWithFail("generatedTargetFileMd5 not equal targetFileMd5");
        }
    }

    private void removeOldFiles() {
        FileUtils.deleteFileOrFolderSilently(new File(reactNativeHotFixSetup.getExtraJSPath()));
        FileUtils.deleteFileOrFolderSilently(new File(reactNativeHotFixSetup.getExtraInfoPath()));
        FileUtils.deleteFileOrFolderSilently(new File(reactNativeHotFixSetup.getExtraJSPath() + ".meta"));
    }


    public void stop() {
        handler = null;
        weakReferenceContext.clear();
        mRequestQueue.cancelAll(getClass().getSimpleName());
        mRequestQueue.stop();

        mRequestQueue = null;
    }


}
