//
//  ReactNativeHotFix.h
//  ReactNativeHotFix
//
//  Created by JinBangzhu on 11/11/2016.
//  Copyright © 2016 kimber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+MD5.h"
#import "bspatch.h"
#import "SSZipArchive.h"


@class ReactNativeHotFix;

@protocol ReactNativeHotFixDelegate <NSObject>

- (void)ReactNativeHotFix:(ReactNativeHotFix *)reactNativeHotFix updateSuccess:(NSString *) message;
- (void)ReactNativeHotFix:(ReactNativeHotFix *)reactNativeHotFix updateFailed:(NSString *)error;

@end


@interface ReactNativeHotFix : NSObject


@property (weak) id<ReactNativeHotFixDelegate> delegate;

@property NSString *defaultaJSPath;
@property NSString *extraJSPath;

@property NSURL *upgradeUrl;
@property NSURL *patchUrl;

@property NSString *defaultRootPath;
@property NSString *extraRootPath;

@property NSString *defaultZipBundlePath;
@property NSString *extraZipBundlePath;

@property NSString *defaultaAssetsPath;
@property NSString *extraAssetsPath;

+ (id)sharedInstance;
/**
  defaultBudnleFile: inner app 
  extraBundleFile: sdcard
  upgradeUrl: the url for check update
  patchUrl: the url for download patch
 */

-(void) init:(NSString *)defaultRootPatch extraRootPath:(NSString *) extraRootPath upgradeUrl:(NSURL *) upgradeUrl patchUrl:(NSURL *) patchUrl;

-(NSURL *) getUrl;

-(void) start;
-(void) start: (NSString *) originFileMd5 targetFileMd5:(NSString *) targetFileMd5 patchFileMd5:(NSString *) patchFileMd5;
-(void) bspatch:(NSString *) oldFile newFile:(NSString *) newFile patchFile:(NSString *) patchFile;
-(NSString *) getDefaultVersion;
-(NSString *) getExtraVersion;


@end
