//
//  GameClientHotFix.h
//  ReactNativeHotFix
//
//  Created by JinBangzhu on 06/02/2017.
//  Copyright © 2017 kimber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+MD5.h"
#import "bspatch.h"
#import "SSZipArchive.h"

@class GameClientHotFix;

@protocol GameClientHotFixDelegate <NSObject>

-(void)GameClientHotFix:(GameClientHotFix *)gameClientHotFix updateSuccess:(NSString *) message;
-(void)GameClientHotFix:(GameClientHotFix *)gameClientHotFix updateFailed:(NSString *) error;

@end

@interface GameClientHotFix : NSObject


@property (weak) id<GameClientHotFixDelegate> delegate;
@property NSString *defaultRootPath;
@property NSString *extraRootPath;

@property NSString *defaultGameClientZipFilePath;
@property NSString *extraGameClientZipFilePath;
@property NSString *extraGameClientPath;

@property NSURL *upgradeUrl;
@property NSURL *patchUrl;

+(id) sharedInstance;

-(void) init:(NSString *)defaultRootPath extraRootPath:(NSString *) extraRootPath upgradeUrl:(NSURL *) upgradeUrl;
-(void) start;

-(NSString *) getDefaultVersion;
-(NSString *) getExtraVersion;

@end
