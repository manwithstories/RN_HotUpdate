//
//  JSFRNFileCacher.h
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JFSRNFileOperation.h"


typedef void(^JFSRNFileCacheCompletionBlock)(NSString * _Nonnull fileName);

@interface JFSRNFileCacher : NSObject
+ (nonnull instancetype)sharedImageCacheWithCachPath:(NSString *_Nonnull)cachePath;

- (BOOL)hasCacheByPath:(NSString *_Nullable)path;

- (_Nonnull id <JFSRNFileOperation>)getDataByCachePath:(NSString *_Nonnull)path
                         progress:(nullable JFSRNFileLoadProgressBlock )progressBlock
                        completed:(nullable JFSRNFileLoadCompletionBlock)completedBlock;

- (void)cacheData:(nonnull NSData *)data
       byFileName:(nonnull NSString *)fileName
        completed:(nullable JFSRNFileCacheCompletionBlock)cacheCompletedBlock;

@end
