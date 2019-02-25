### install
```
npm install react-native-hotupdate --save
```

###iOS project
```
pod 'ReactNativeHotFix', :path => '../node_modules/react-native-hotupdate/ios'

pod 'SSZipArchive'
```
```
NSURL *upgradeUrl = [NSURL URLWithString:@"http://localhost:8000/v0.0.1_v0.0.2.json"];
NSURL *patchUrl = [NSURL URLWithString:@"http://localhost:8000/v0.0.1_v0.0.2"];

// built-in resource
NSURL* defaultRootLocation = [[NSBundle mainBundle] URLForResource:@"rnbundle" withExtension:@""];
NSString *defaultRootPath = [[defaultRootLocation absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];

// file resource
NSString *extraRootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];


ReactNativeHotFix *hotFixInstance =[ReactNativeHotFix sharedInstance];
[hotFixInstance setDelegate:self];
[hotFixInstance init:defaultRootPath extraRootPath:extraRootPath upgradeUrl:upgradeUrl patchUrl:patchUrl];


NSURL *jsbundleUrl = [hotFixInstance getUrl];


NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];


RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsbundleUrl
                                                  moduleName:@"YourModuleName"
                                           initialProperties:nil
                                               launchOptions:launchOptions];
rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
UIViewController *rootViewController = [UIViewController new];
rootViewController.view = rootView;
self.window.rootViewController = rootViewController;
[self.window makeKeyAndVisible];
```

###Android project

#####settings.gradle
```
include 'reactnativehotfixlib'
project(':reactnativehotfixlib').projectDir = new File('../node_modules/react-native-hotupdate/android/reactnativehotfixlib')
```
#####app.gradle
```
//add reactnativehotfixlib to dependencies
dependencies {
    compile project(":reactnativehotfixlib")
    ...
}
```
```
class MyHandler extends Handler {
    @Override
    public void handleMessage(Message msg) {
        super.handleMessage(msg);
        switch (msg.what) {
            case ReactNativeHotFix.CODE_FAIL:
                Toast.makeText(getApplicationContext(), "fail", Toast.LENGTH_LONG).show();
                break;
            case ReactNativeHotFix.CODE_SUCCESS:
                Toast.makeText(getApplicationContext(), "success", Toast.LENGTH_LONG).show();
                break;
        }
    }
}

@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MyHandler handler = new MyHandler();
    setContentView(R.layout.main);

    String extraBundleRootPath = Environment.getExternalStorageDirectory().getPath() + "/remoteReact/";
	String upgradeUrl = "http://127.0.0.1:8000/v0.0.1_v0.0.2.json";
	String patchDownloadurl = "http://127.0.0.1:8000/v0.0.1_v0.0.2";
    reactNativeHotFix = ReactNativeHotFix.create(this)
            .setExtraBundleRootPath(extraBundleRootPath)
            .setUpgradeUrl(upgradeUrl)
            .setPatchUrl(patchDownloadurl)
            .setHandler(handler);

    reactNativeHotFix.start();
}

@Override
protected void onDestroy() {
    super.onDestroy();
    reactNativeHotFix.stop();
    Log.d("main", "onDestroy");
}
```
#### react-native project package.json
```
"scripts": {
    "start": "node node_modules/react-native/local-cli/cli.js start",
    "test": "jest",
    ...
    "bundle-release": "python ./node_modules/react-native-hotupdate/release_tools/generate_bundles.py",
    "bundle-patches": "python ./node_modules/react-native-hotupdate/release_tools/generate_patches.py"
  },
```

### run scripts
```
npm run bundle-release
```
